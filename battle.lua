ResourceManager = require "resource_manager"
local animation = require "controller/animation"

local battle = {}

local DEFINE = {
    PARTY_SIZE = 4
}

local actor_types = {
    summoner = require "actor/summoner",
    wisp = require "actor/wisp"
}

local function hero_position(i)
    return Vec2(400 - 100 * i, 150)
end

local function enemy_position(i)
    return Vec2(400 + 100 * i, 150)
end

function battle.begin(hero, villian)
    local gamestate = Property.create()
        :set("party", "hero", hero)
        :set("party", "villian", villian)
    -- Init animation
    local atlas_bank = ResourceManager.create(Atlas.create)
    local all_of_them = hero:concat(villian)
    local all_of_ids = all_of_them
        :zip(List.range(#all_of_them))
        :map(
            function(arg)
                local a, id = unpack(arg)
                return a .. id
            end
        )
    local visualstate = Herald.create()
    for i, p in pairs(gamestate:get("party", "hero")) do
    end



    local all_of_types = all_of_them:map(function(a) return actor_types[a] end)

    local frame_river = all_of_types
        :zip(all_of_ids)
        :map(
            function(args)
                local t, id = unpack(args)
                local a = t.atlas(atlas_bank)
                local c = t.animation_control()
                return animation.create(id, a, c)
            end
        )

end

return battle
