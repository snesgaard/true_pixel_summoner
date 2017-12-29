local Tween = require "tween"

return function(node)
    node.name("marker")
    node.__angle = rx.BehaviorSubject.create(0)
    node.__scale = rx.BehaviorSubject.create(1)
    node.animate = rx.Subject.create()

    node.animate
        :flatMapLatest(
        function()
            return Tween.log(0.3, node.update)
        end
        )
        :map(function(t) return math.pi * (1 - t) end)
        :subscribe(node.__angle)

    node.animate
        :map(OP.constant(1))
        :subscribe(node.__scale)

    node.animate
        :flatMapLatest(
            function()
                return Tween.sine(1.5, -0.25, node.update)
            end
        )
        :map(
            function(v)
                v = 0.5 * v + 0.5
                return 0.25 * v + 1.0
            end
        )
        --:tap(print)
        :subscribe(node.__scale)


    node.draw
        :with(node.__angle, node.__scale)
        :subscribe(function(_, a, scale)
            local s  = 6 * scale
            local s2 = s * math.sqrt(2)
            local r, g, b = 255, 255, 255
            gfx.setLineWidth(2)

            gfx.push()
            gfx.rotate(-a + math.pi * 0.25)
            gfx.setColor(r, g, b, 100)
            gfx.rectangle("fill", -s2, -s2, s2 + s2, s2 + s2, 1)
            gfx.setColor(r, g, b)
            gfx.rectangle("line", -s2, -s2, s2 + s2, s2 + s2, 1)
            gfx.pop()

            gfx.push()
            gfx.rotate(a)
            gfx.setColor(r, g, b, 100)
            gfx.rectangle("fill", -s, -s, s + s, s + s, 1)
            gfx.setColor(r, g, b)
            gfx.rectangle("line", -s, -s, s + s, s + s, 1)
            gfx.pop()
        end)

end
