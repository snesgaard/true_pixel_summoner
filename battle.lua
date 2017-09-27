ResourceManager = require "resource_manager"
local animation = require "controller/animation"
local ui = require "ui"

local battle = {}

local DEFINE = {
    PARTY_SIZE = 4
}

local actor_types = {
    summoner = require "actor/summoner",
    wisp = require "actor/wisp",
    goblin = require "actor/goblin",
    imp = require "actor/imp",
    undine = require "actor/undine",
}

local type_count = {}

function assign_id(type)
    local count = type_count[type] or 1
    type_count[type] = count + 1
    return type .. "/" .. tostring(count)
end

function get_type(id)
    local __type, count = unpack(string.split(id, "/"))
    return __type
end

function point_inside_box(x, y, bx, by, bw, bh)
    x = x - bx
    y = y - by
    return math.abs(x) < bw and math.abs(y) < bh
end

function battle.begin(heroes, villians)
    -- Assign ids
    heroes = heroes:map(assign_id)
    villians = villians:map(assign_id)
    -- Init animation resource
    local atlas_bank = ResourceManager.create(Atlas.create)
    -- Concatenate everything to a nice list format with taction name
    local all_of_ids = heroes:concat(villians)
    local all_of_factions = List.concat(
        heroes:map(function() return "hero" end),
        villians:map(function() return "villian" end)
    )
    -- Assign placement game-wise, screen postion and orientation
    local placement = List.concat(List.range(#heroes), List.range(#villians))
    local position = List.zip(all_of_factions, placement)
        :map(
            function(args)
                local __type, __index = unpack(args)
                return ui.constants.battle_position(__index, __type)
            end
        )
        :map(rx.BehaviorSubject.create)
    local face = all_of_factions
        :map(function(__type) return __type == "hero" and 1 or -1 end)
        :map(rx.BehaviorSubject.create)
    -- Create sprites for each actor in the game
    local animation_controllers = all_of_ids
        :map(get_type)
        :map(
            function(__type)
                local actor = actor_types[__type]
                return animation.create(
                    actor.atlas(atlas_bank), actor.animation_control()
                )
            end
        )
    -- Extract atlases for each actor
    local atlases = all_of_ids
        :map(get_type)
        :map(
            function(__type)
                local actor = actor_types[__type]
                print(__type, actor.atlas(atlas_bank))
                return actor.atlas(atlas_bank)
            end
        )
    -- Bind each actors frame stream with it spatial data dn submit to the drawer
    List.zip(animation_controllers, position, face, atlases)
        :map(
            function(args)
                local ctrl, p, f, a = unpack(args)
                ctrl.frames
                    :with(p, f)
                    :map(
                        function(frame, __position, __face)
                            local x, y = unpack(__position)
                            return frame, x, y, 0, __face, 1
                        end
                    )
                    :subscribe(a:draw_observer(atelier.world))
            end
        )
    -- Initialize animations
    animation_controllers
        :map(function(ctrl) ctrl.request("idle") end)
    -- Initialize stats
    gamestate = all_of_ids
        :reduce(
            function(gamestate, id)
                local __type = actor_types[get_type(id)]
                return __type.stats(id, gamestate)
                    :set("damage", id, 0)
                    :set("armor", id, 0)
                    :set("charge", id, 0)
                    :set("power", id, 0)
                    :set("shield", id, 0)
            end,
            Property.create()
        )
    for _, arg in pairs(List.zip(all_of_ids, placement, all_of_factions)) do
        local id, p, f = unpack(arg)
        gamestate = gamestate
            :set("placement", id, p)
            :set("faction", id, f)
    end
    print(gamestate:get("placement"))
    local evolution = rx.BehaviorSubject.create(gamestate)
    -- Initialize health and status bars
    local status_ui = all_of_ids
        :map(function(id) return ui.health.create(id, evolution, atelier.screen_ui) end)

    love.keypressed
        :map(
            function(key)
                local dir = {left = 1, right = -1}
                return dir[key]
            end
        )
        :compact()
        :scan(
            function(current, dir)
                return (current + dir) % 4
            end,
            0
        )
        :flatMapLatest(
            function(index)
                local pos = ui.constants.battle_position(index + 1, "hero")
                return love.update
                    :map(function() return pos[1], pos[2] end)
            end
        )
        :subscribe(
            function(x, y)
                atelier.screen_ui:register(
                    function(x, y)
                        local w, h = 50, 100
                        gfx.setColor(255, 255, 255, 100)
                        gfx.rectangle("fill", x - w / 2, y - h + 10, w, h)
                        gfx.setColor(255, 255, 255, 255)
                    end,
                    x, y
                )
            end
        )
end

return battle
