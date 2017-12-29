--local Node   = require "node"

love.load:subscribe(
function()
    local a = rx.Subject.create()

    a
        :window(3)
        :subscribe(print)

    a(3)
    a(2)
    a(1)
    a(4)

    print("what!!")

    local b = rx.Subject.create()
    local c = rx.Subject.create()

    b
        :with(c)
        :subscribe(print)

    b(1)
    c(2)
    b(3)
end
)
