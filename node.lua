local INPUT = {
    "keypressed", "mousepressed", "mousereleased", "mousemoved",
    "keyreleased"
}

-- TODO: CONSIDER FIXING onNext list editing bug in RX

local Node = {}
Node.__index = Node


function Node.create(setup, ...)
    local self = {
        update        = rx.Subject.create(),

        position      = rx.BehaviorSubject.create(Vec2(0, 0)),
        angle         = rx.BehaviorSubject.create(0),
        scale         = rx.BehaviorSubject.create(Vec2(1, 1)),

        draw          = rx.Subject.create(),

        __parent_draw = rx.Subject.create(),

        bridges    = {}
    }

    for _, name in pairs(INPUT) do self[name] = rx.Subject.create() end

    self = setmetatable(self, Node)

    self.__parent_draw
        :switch()
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

    if setup then setup(self, ...) end

    return self
end

local function fetch_bridge(node, name)
    if node.bridges[name] then
        return node.bridges[name]
    end

    local bridge = rx.Subject.create()

    bridge
        :switch()
        :subscribe(node[name])
    node.bridges[name] = bridge

    return bridge
end

function Node:set_update(node)
    node = node or {}

    local bridge = fetch_bridge(self, "update")
    bridge(node.update or love.update:map(OP.mul(0)))
end

function Node:set_input(node)
    node = node or {}
    for _, name in pairs(INPUT) do
        local bridge = fetch_bridge(self, name)
        bridge(node[name] or rx.Subject.create())
    end
end

function Node:set_transform(node)
    node = node or {}
    local names = {"position", "size"}

    for _, name in pairs(names) do
        local bridge = fetch_bridge(self, name)
        bridge(node[name] or rx.Subject.create())
    end
end

function Node:set_draw(node)
    node = node or {}
    self.__parent_draw(node.draw or rx.Subject.create())
end

Node.__null = coroutine.wrap(
    function()
        local s = rx.Subject.create()
        while true do coroutine.yield(s) end
    end
)

return Node
