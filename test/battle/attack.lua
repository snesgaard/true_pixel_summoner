local Node      = require "node"
local Animation = require "animation"
local Tween     = require "tween"

local function __get_move(attacker, defender)
    local from = attacker.world_position:getValue()
    local to   = defender.world_position:getValue()
    return to:sub(from):sub(Vec2(50, 0))
end

local function __create_updater(s)
    return function(...) s(...) end
end

return function(node, attacker, defender)
    node.done = rx.Subject.create()
    local triggers = {
        start   = rx.Subject.create(),
        arrival = rx.Subject.create(),
        hit     = rx.Subject.create(),
        stop    = rx.Subject.create()
    }

    local distance = __get_move(attacker, defender)

    Tween.linear(0.6, node.update:skipUntil(triggers.start))
        :sigmoid()
        :lerp(Vec2(0, 0), distance)
        :subscribe(__create_updater(attacker:find('sprite/position')))

        attacker:find('sprite/animation').set_animation("al_dash", true)

    Tween.linear(0.3, node.update:skipUntil(triggers.start))
        :base()
        :subscribe(nil, nil, triggers.arrival)

    triggers.arrival:subscribe(
        function()
            attacker:find('sprite/animation').set_animation('alchemist_attack')
        end
    )

    attacker:find('sprite/animation/event')
        :skipUntil(triggers.arrival)
        :filter(function(e) return e.type == "done" end)
        :subscribe(triggers.hit)

    triggers.hit:subscribe(
        function()
            attacker:find('sprite/animation').set_animation('al_bdash', true)
        end
    )

    Tween.linear(0.6, node.update:skipUntil(triggers.hit))
        :sigmoid()
        :lerp(distance, Vec2(0, 0))
        :subscribe(
            __create_updater(attacker:find('sprite/position')),
            print,
            triggers.stop
        )

    Tween.linear(0.35, node.update:skipUntil(triggers.hit))
        :base()
        :subscribe(nil, nil, function()
            attacker:find('sprite/animation').set_animation('alchemist', true)
        end)

    triggers.stop:subscribe(
        function()
            --attacker:find('sprite/animation').set_animation('alchemist', true)
            node.parent()
            node.done()
        end
    )

    triggers.start()
end
