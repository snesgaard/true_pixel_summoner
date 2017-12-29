local Dictionary = require "dictionary"

local INPUT = {
    "keypressed", "mousepressed", "mousereleased", "mousemoved",
    "keyreleased"
}

-- TODO: CONSIDER FIXING onNext list editing bug in RX

local Node = {}
Node.__index = Node

function Node.__tostring(node)
    local name = node.name:getValue()
    return name and string.format("Node <%s>", name) or "Node"
end

function Node.create(setup, ...)
    local self = {
        update         = rx.Subject.create(),

        position       = rx.BehaviorSubject.create(Vec2(0, 0)),
        angle          = rx.BehaviorSubject.create(0),
        scale          = rx.BehaviorSubject.create(Vec2(1, 1)),

        world_position = rx.BehaviorSubject.create(Vec2(0, 0)),

        draw           = rx.Subject.create(),

        parent         = rx.BehaviorSubject.create(),

        --__named_nodes  = Dictionary.create(),

        name           = rx.BehaviorSubject.create(),
    }

    for _, name in pairs(INPUT) do self[name] = rx.Subject.create() end

    self = setmetatable(self, Node)

    local function unregister_cb(p, n)
        p:unregister(n)
    end

    local function register_cb(p, n)
        p:register(n, self)
    end

    local function check_name_parent(p, n)
        return p ~= nil and n ~= nil
    end



    self.parent
        :scan(
            function(agg, parent)
                agg.prev = agg.next
                agg.next = parent
                return agg
            end,
            {}
        )
        :map(function(agg) return agg.prev end)
        :with(self.name)
        :filter(check_name_parent)
        :subscribe(unregister_cb)

    self.parent
        --:skipUntil(self.name)
        :with(self.name)
        :filter(check_name_parent)
        :subscribe(register_cb)

    self.name
        --:skipUntil(self.parent)
        :scan(
            function(agg, parent)
                agg.prev = agg.next
                agg.next = parent
                return agg
            end,
            {}
        )
        :map(function(agg) return agg.prev end)
        :with(self.parent)
        :filter(check_name_parent)
        :subscribe(function(n, p) unregister_cb(p, n) end)

    self.name
        --:skipUntil(self.parent)
        :with(self.parent)
        :filter(check_name_parent)
        :subscribe(function(n, p) register_cb(p, n) end)


    self.parent
        :flatMapLatest(
            function(p)
                if not p then
                    return rx.Observable.never()
                else
                    return p.draw
                end
            end
        )
        :with(self.position, self.angle, self.scale)
        :subscribe(
            function(_, p, a, s)
                gfx.push()
                gfx.translate(p[1], p[2])
                gfx.rotate(a)
                gfx.scale(s[1], s[2])
                self.draw()
                gfx.pop()
            end
        )

    rx.Observable.combineLatest(
            self.parent
                :flatMapLatest(
                    function(p)
                        if not p then
                            return rx.Observable.of(Vec2(0, 0))
                        else
                            return p.world_position
                        end
                    end
                )
                :compact(),
            self.scale, self.angle, self.position
        ,
        function(o, s, a, p)
            return o:dot(s):rotate(a):add(p)
        end
    )
        :subscribe(self.world_position)

    self.parent
        :flatMapLatest(
            function(p)
                if not p then
                    return rx.Observable.never()
                else
                    return p.update
                end
            end
        )
        :subscribe(self.update)

    for _, name in pairs(INPUT) do
        self.parent
            :flatMapLatest(
                function(p)
                    if not p then
                        return rx.Observable.never()
                    else
                        return p[name]
                    end
                end
            )
            :subscribe(self[name])
    end

    if setup then setup(self, ...) end

    return self
end


function Node:find(address)
    address = string.gsub(address, '%.%.', 'parent')
    local parts = string.split(address, '/')
    local node = rx.BehaviorSubject.create(self)
    for _, name in ipairs(parts) do
        local __node = node:getValue()
        node = __node[name]
        if node == nil then return end
    end
    --print(List.create(unpack(parts)))
    return node
end

function Node:register(address, node)
    if self[address] then
        print(string.format("Named node %s already assigned", address))
        return
    end
    self[address] = rx.BehaviorSubject.create(node)
end

function Node:unregister(address)
    self[address] = nil
end

return Node
