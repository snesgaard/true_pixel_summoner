ResourceManager = require "resource_manager"
local animation = require "controller/animation"
local ui = require "ui"
local Elector = require "controller/elector"
local util = require "util"
local OP = require "op"

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
    gibbles = require "actor/gibbles"
}

local type_count = {}

function assign_id(type)
    local count = type_count[type] or 1
    type_count[type] = count + 1
    return type .. '_ID' .. tostring(count)
end

function get_type(id)
    local __type, count = unpack(string.split(id, "_ID"))
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

    local all_of_ids = heroes:concat(villians)
    local all_of_factions = List.concat(
        heroes:map(function() return "hero" end),
        villians:map(function() return "villian" end)
    )
    -- Initialize stats
    gamestate = all_of_ids
        :reduce(
            function(gamestate, id)
                local __type = actor_types[get_type(id)]
                local row = __type.stats(id, gamestate)
                row.damage = 0
                row.armor = 0
                row.charge = 0
                row.power = 0
                row.shield = 0
                return gamestate:insert(id, row)
            end,
            Database.create('Gamestate')
        )
    local placement = List.concat(List.range(#heroes), List.range(#villians))
    for _, arg in pairs(List.zip(all_of_ids, placement, all_of_factions)) do
        local id, p, f = unpack(arg)
        gamestate = gamestate
            :write(id, "placement", p)
            :write(id, "faction", f)
    end

    broadcaster = Broadcaster.create()
        :step(gamestate)
        :map(
            function(id, row)
                local place = row.placement
                local faction = row.faction
                return {
                    position = ui.constants.battle_position(place, faction),
                    face = faction == "hero" and 1 or -1,
                    wooble = 0
                }
            end
        )
    visualstate = all_of_ids
        :reduce(
            function(visualstate, id)
                local actor = actor_types[get_type(id)]
                local row = {}
                row.atlas = actor.atlas(atlas_bank)
                row.animation = animation.create(
                    row.atlas, actor.animation_control()
                )
                return visualstate:insert(id, row)
            end,
            Database.create("Visual State")
        )

    for id, _ in pairs(broadcaster.rows) do
        ui.health.create(id, broadcaster, atelier.screen_ui)
    end


    visualstate
        :map(
            function(id, row)
                local ctrl = row.animation
                local atlas = row.atlas
                local pos = broadcaster:channel(id, "position")
                local face = broadcaster:channel(id, "face")
                local wooble = broadcaster:channel(id, "wooble")

                --ctrl.frames
                --love.update
                    --:scan(function() return 1 + 1 end, 1)
                    --:map(function(a, b) return a + b end)
                    --:subscribe(print)


                ctrl.frames
                    :with(pos, face, wooble)
                    :map(
                        function(frame, position, face, wooble)
                            local x, y = unpack(position)
                            --return frame + position
                            return frame, x + wooble, y, 0, face, 1
                        end
                    )
                    :subscribe(atlas:draw_observer(atelier.world))
                ctrl.request("idle")

                local damage = broadcaster:channel(id, "damage")
                damage
                    :window(2)
                    :filter(function(prev, next) return prev < next end)
                    :flatMapLatest(function() return util.wooble() end)
                    :subscribe(wooble)

                damage
                    :window(2)
                    :filter(function(prev, next) return prev < next end)
                    :map(List.create)
                    :with(pos)
                    :flatMap(
                        function(dmg, position)
                            local d = dmg[2] - dmg[1]
                            position = position:add(Vec2(0, -50))
                            return ui.number.damage(position, d)
                        end
                    )
                    :subscribe(atelier.screen_ui:listener())
            end
        )


    local ids = gamestate
        :filter(function(id, row) return row.faction == "hero" end)
        .rows:to_keyvalue()
        :sort(
            function(a, b)
                return gamestate.rows[a].placement < gamestate.rows[b].placement
            end
        )

    local char_elector = Elector(ids, {left = 1, right = -1})
    char_elector.election
        :map(OP.lookup(ids))
        :scan(
            function(agg, id)
                agg.prev = agg.next
                agg.next = id
                return agg
            end,
            {}
        )
        :subscribe(
            function(agg)
                if agg.prev then
                    visualstate.rows[agg.prev].animation.request("idle")
                end
                visualstate.rows[agg.next].animation.request("chant")
            end
        )
    --[[
    char_elector.election
        :flatMapLatest(
            function(index)
                local id = ids[index]
                local pos = broadcaster:channel(id, "position")
                return util.sine(0.5)
                    :with(pos)
                    :map(function(a, p) return p[1], p[2], a end )
            end
        )
        :subscribe(
            function(x, y, a)
                atelier.screen_ui:register(util.entity_target, x, y, a)
            end
        )
    ]]--

    util.sine(0.5)
        :with(
            char_elector.election
                :flatMapLatest(
                    function(index)
                        local id = ids[index]
                        return broadcaster:channel(id, "position")
                    end
                )
        )
        :filter(function(a, p) return p ~= nil end)
        :subscribe(
            function(a, p)
                atelier.screen_ui:register(util.entity_target, p[1], p[2], a)
            end
        )

    love.keypressed
        :filter(OP.curry(OP.equal, "space"))
        :tap(print)
        :subscribe(char_elector.cancel)

    local menu_elector = Elector(3, {up = -1, down = 1})
    love.update
        :with(menu_elector.election)
        :subscribe(
            function(dt, index)
                local entries = {"Foo", "Bar", "Spam"}
                atelier.screen_ui:register(ui.menu.draw, 600, 20, 100, 20, entries, index)
            end
        )


    broadcaster.rows.undine_ID1.damage(2)
end

debugger = {}




return battle
