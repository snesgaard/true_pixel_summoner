local List = require "list"

local NULL = rx.BehaviorSubject.create(List.create())

local function __safe_lookup(name)
    return function(p)
        if not p or not p[name] then return NULL end
        return p[name]
    end
end

return function(node)
    node.publish  = rx.Subject.create()
    node.result   = rx.BehaviorSubject.create()
    node.revive   = rx.Subject.create()
    node.reject   = rx.Subject.create()
    node.dormant  = rx.Observable.merge(node.publish, node.reject)
    node.next     = rx.Subject.create()
    node.meltdown = rx.Subject.create()

    local parent_res = node.parent:flatMapLatest(__safe_lookup("result"))

    rx.Observable.combineLatest(
        node.publish:startWith(NULL), parent_res:startWith(List.create()),
        function(r, rl)
            if r == NULL then
                return rl
            else
                return rl:insert(r)
            end
        end
    )
        :subscribe(node.result)

    local parent_rev = node.parent
        :map(
            function(p)
                if not p then
                    return
                else
                    return p.revive
                end
            end
        )

    node.reject
        :with(parent_rev)
        :subscribe(
            function(_, revive)
                --node.publish(NULL)
                -- TODO Consider not force removal
                node.parent()
                if revive then revive() end
            end
        )

    node.publish
        :with(node.result)
        :map(function(_, r) return node, r end)
        :subscribe(node.next)

    node.meltdown
        :with(node.parent)
        :subscribe(function(_, p)
            node.parent()
            if p and p.meltdown then p.meltdown() end
        end)
end
