local marker = require "test/battle/marker"
local Misc   = require "pileomisc"
local Node   = require "node"

return function(node, targets, keymap)

    node.marker     = Node.create(marker)
    node.targets    = targets
    node.selection  = rx.BehaviorSubject.create()
    node.active     = rx.BehaviorSubject.create(true)
    node.candidates = rx.BehaviorSubject.create()

    local trottled_key = node.active
        :flatMapLatest(
            function(active)
                return active and node.keypressed or rx.Observable.never()
            end
        )

    local approve  = trottled_key
        :filter(function(key) return keymap.approve == key end)
        :filter(function() return node.candidates:getValue() end)
    local reject   = trottled_key
        :filter(function(key) return keymap.reject == key end)


    local selector = node.active
        :with(node.candidates)
        :flatMapLatest(
            function(active, candidate)
                if not active then
                    return rx.Observable.never()
                else
                    return Misc.selector(targets, keymap, candidate, node)
                end
            end
        )
        :filter(function() return node.active:getValue() end)
        :subscribe(node.candidates)


    rx.Observable.merge(approve, reject)
        :map(function() return false end)
        :subscribe(node.active)

    approve
        :with(node.candidates)
        :map(function(_, c) return c end)
        :filter(function(c) return c ~= nil end)
        :subscribe(node.selection)

    reject
        :subscribe(
            function()
                node.candidates(nil)
                node.selection(nil)
            end
        )

    node.parent
        :filter(function(p) return p == nil end)
        :subscribe(node.marker.parent)

    node.marker.position(Vec2(0, -50))
    node.candidates
        :subscribe(
            function(i)
                local target_node = targets[i]
                if target_node then
                    node.marker.parent(target_node)
                    node.marker.animate()
                else
                    node.marker.parent()
                end
            end
        )
end
