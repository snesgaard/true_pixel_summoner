local INPUT = {
    "keypressed", "mousepressed", "mousereleased"
}

local Edge = {}
Edge.__index = Edge
function Edge.create(from, to)
    local self = {
        from = from, to = to, subs = {}, is_input_enabled = false
    }
    return setmetatable(self, Edge)
end

function Edge:update(enable)
    if enable == nil then return self.subs.update ~= nil end

    if self.subs.update then self.subs.update:unsubscribe() end
    local from, to = self.from, self.to
    self.subs.update = enable and from.update:subscribe(to.update) or nil
end

function Edge:input(enable)
    if enable == nil then return self.is_input_enabled end

    for _, i in pairs(INPUT) do
        self.subs[i]:unsubscribe()
        self.subs[i] = enable and self.from[i]:subscribe(self.to[i]) or nil
    end
    self.is_input_enabled = enable
end

local Node = {}
Node.__index = Node

function Node.create(setup)
    local self = {
        update = rx.Subject.create(),

        events = rx.Subject.create(),
    }
    for _, i in pairs(INPUT) do self[i] = rx.Subject.create() end

    local self = setmetatable(self, Node)

    if setup then setup(self) end

    return self
end

function Node.connect(from_node_a, to_node_b)
    return Edge.create(from_node_a, to_node_b)
end
