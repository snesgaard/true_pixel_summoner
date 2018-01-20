local util   = require "util"
local Node   = require "node"
local Atlas  = require "atlas"
local Sprite = require "sprite"
local Tween  = require "tween"
local Misc   = require "pileomisc"
local OP     = require "op"
local Animation = require "animation"
local Menu   = require "ui/menu"

local actor_types = {
    hero     = require "test/battle/hero",
    enemy    = require "test/battle/enemy",
    selector = require "test/battle/selector",
    attack   = require "test/battle/attack",
    fire     = require "test/battle/fire"
}

local setup = {
    marker = require "test/battle/marker"
}

love.draw = rx.Subject.create()


local function __do_load()
    local w, h = gfx.getWidth(), gfx.getHeight()
    local function get_hero_pos(i)
        return Vec2(w * 0.5 - 100 * (5 - i), 600)
    end
    local function get_enemy_pos(i)
        return Vec2(w * 0.5 + 100 * i, 600)
    end

    local root = Node.create()

    local atlas = Animation.Atlas.create('res/sword_summoner')

    local function init_base(p, type)
        local base   = Node.create()
        local visual = Node.create(actor_types[type].visual, atlas)

        visual.parent(base)
        base.parent(root)

        base.position(p)

        base.name(string.format("%s %s", type, tostring(p)))
        return base
    end


    local enemy_bases = List.range(4)
        :map(get_enemy_pos)
        :map(function(p) return init_base(p, "enemy") end)
    local hero_bases = List.range(2)
        :map(get_hero_pos)
        :map(function(p) return init_base(p, "hero") end)


    root.parent(love)

    --hero_bases[2]:find('sprite').scale(Vec2(2.3, 2.3))
    hero_bases[1]:find('sprite/animation').set_animation("fencer_cast", true)

    local triggers = {}

    local cache = {}

    function triggers.begin(prev)
        local hero_selector = Node.create(
            actor_types.selector, hero_bases,
            {left = -1, right = 1, approve = "space", reject = "backspace"},
            cache.hero
        )
        hero_selector.name("Hero")
        hero_selector.parent(root)
        --if cache.hero then hero_selector.candidate() end
        hero_selector.publish:subscribe(
            function(hero, i)
                --print(hero:find("sprite/animation").set_animation("alchemist_attack", false))
                cache.hero = i
            end
        )
        hero_selector.next:subscribe(triggers.dispatch_menu)
    end
    function triggers.dispatch_menu(prev)
        local items = {"attack", "fire"}
        local node = Node.create(Menu, items)
        node.parent(prev)
        node.next:subscribe(triggers.select_enemy)
    end
    function triggers.select_enemy(prev)
        local enemy_selector = Node.create(
            actor_types.selector, enemy_bases,
            {left = -1, right = 1, approve = "space", reject = "backspace"}
        )
        enemy_selector.parent(prev)
        enemy_selector.next:subscribe(triggers.completed)
    end
    function triggers.completed(prev, results)
        local hero, move, enemy = unpack(results)
        prev.meltdown()
        local player = Node.create(actor_types[move], hero, enemy)
        player.parent(root)
        player.done:subscribe(function() triggers.begin(root) end)
    end

    triggers.begin(root)

    --[[
    enemy_selector.selection
        :filter(function(v) return v ~= nil end)
        :with(hero_selector.selection)
        :take(1)
        :subscribe(
            function(enemy, hero)
                hero_selector.parent()
                enemy_selector.parent()
                local player = Node.create(
                    actor_types.fire,
                    hero_bases[hero], enemy_bases[enemy]
                )
                player.parent(root)
            end
        )
    ]]--
    gfx.setBackgroundColor(50, 80, 100)
end

--love.draw:subscribe(function() print("draw!") end)

love.load:subscribe(__do_load)
