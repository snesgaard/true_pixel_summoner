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

    print(c:find('../../B/../position'):getValue())

    A = rx.Subject.create()

    A
        :window(2)
        :compact()
        :subscribe(print)

    A(1)
    A({})
    A(2)
    A(3)
end

love.load:subscribe(__do_load)
