local Tween = require "tween"
local Node  = require "node"

local function __create_ball(node, duration)
    node.radius = rx.BehaviorSubject.create(200)
    node.done   = rx.Subject.create()

    Tween.linear(duration, node.update)
        :lerp(200, 0)
        :subscribe(
            function(r) node.radius(r) end,
            nil,
            function()
                node.parent()
                node.done()
            end
        )

    node.draw
        :with(node.radius)
        :subscribe(
            function(_, r)
                gfx.setColor(255, 0, 0)
                gfx.circle("fill", 0, 0, r, 20)
            end
        )
end

return function(node, attacker, defender)
    local ball = Node.create(__create_ball, 0.5)
    node.done = rx.Subject.create()

    ball.parent(defender)

    local att_anime = attacker:find("sprite/animation")
    att_anime.set_animation('al_cast', true)

    ball.done
        :take(1)
        :subscribe(
            function()
                att_anime.set_animation('alchemist', true)
                node.done()
            end
        )
end
