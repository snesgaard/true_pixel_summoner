local Node = require "node"

local function __do_load()
    local a = Node.create()
    local b = Node.create()
    local c = Node.create()


    c.parent(b)
    b.parent(a)

    a.name("A")
    b.name("B")
    c.name("C")

    a.position(Vec2(100, 100))

    print(b:find('../position'):getValue())
end

love.load:subscribe(__do_load)
