local util   = require "util"
local Node   = require "node"
local Atlas  = require "atlas"
local Sprite = require "sprite"
local Tween  = require "tween"
local Misc   = require "pileomisc"
local OP     = require "op"
local Animation = require "animation"

local actor_types = {
    hero     = require "test/battle/hero",
    enemy    = require "test/battle/enemy",
    selector = require "test/battle/selector",
    attack   = require "test/battle/attack"
}

local setup = {
    marker = require "test/battle/marker"
}

love.draw = rx.Subject.create()

local function create_animation(attacker, defender)
    local function __get_move(attacker, defender)
        local from = attacker.world_position:getValue()
        local to   = defender.world_position:getValue()
        return to:sub(from):sub(Vec2(30, 0))
    end

    local move = __get_move(attacker, defender)

    local player = Animation.Player.create()
    local attacker_motion = Animation.Track.create()
        :keyframe{Vec2(0, 0), 0, interpolation = "sigmoid"}
        :keyframe{move, 1.5, interpolation = "linear"}
        :keyframe{move, 2.5, interpolation = "sigmoid"}
        :keyframe{Vec2(0, 0), 5, interpolation = "linear"}
    local defender_motion = Animation.Track.create()
        :keyframe{Vec2(0, 0), 1.5, interpolation = "sigmoid"}
        :keyframe{Vec2(0, -50), 2.0, interpolation = "sigmoid"}
        :keyframe{Vec2(0, 0), 2.5, interpolation = "sigmoid"}
    player
        :add(
            "attack_movement", attacker_motion,
            attacker:find("visual").position
        )
        :add(
            "defender_motion", defender_motion,
            defender:find("visual").position
        )
    return player
end

local function __do_load()
    local w, h = gfx.getWidth(), gfx.getHeight()
    local function get_hero_pos(i)
        return Vec2(w * 0.5 - 100 * (5 - i), 600)
    end
    local function get_enemy_pos(i)
        return Vec2(w * 0.5 + 100 * i, 600)
    end

    local root = Node.create()

    local function init_base(p, type)
        local base   = Node.create()
        local visual = Node.create(actor_types[type].visual)

        visual.parent(base)
        base.parent(root)

        base.position(p)
        return base
    end

    local hero_bases = List.range(4)
        :map(get_hero_pos)
        :map(function(p) return init_base(p, "hero") end)

    local enemy_bases = List.range(4)
        :map(get_enemy_pos)
        :map(function(p) return init_base(p, "enemy") end)

    root.parent(love)

    local hero_selector = Node.create(
        actor_types.selector, hero_bases,
        {left = -1, right = 1, approve = "space", reject = "q"}
    )
    hero_selector.name("Hero")
    local enemy_selector = Node.create(
        actor_types.selector, enemy_bases,
        {left = -1, right = 1, approve = "space", reject = "q"}
    )


    hero_selector.parent(root)
    enemy_selector.parent(root)
    enemy_selector.active(false)
    hero_selector.active(true)

    enemy_selector.active:subscribe(print)
    root.keypressed
        :filter(function(key) return key == "r" end)
        :subscribe(function() hero_selector.active(true) end, print)
    root.keypressed
        :filter(OP.equal("w"))
        :subscribe(function() enemy_selector.active(true) end, print)

    hero_selector.selection
        :filter(function(v)
            return v ~= nil
        end)
        :subscribe(
            function(v)
                enemy_selector.active(true)
            end,
            print
        )

    enemy_selector.selection
        :filter(function(v) return v == nil end)
        :subscribe(function()
            print("revival")
            hero_selector.active(true)
        end)

    enemy_selector.selection
        :filter(function(v) return v ~= nil end)
        :with(hero_selector.selection)
        :take(1)
        :subscribe(
            function(enemy, hero)
                hero_selector.parent()
                enemy_selector.parent()
                local player = create_animation(
                    hero_bases[hero], enemy_bases[enemy]
                )
                root.update
                    :subscribe(coroutine.wrap(function(dt)
                        player:play(dt)
                        while true do coroutine.yield() end
                    end))
            end
        )

end

love.load:subscribe(__do_load)
