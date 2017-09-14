gfx = love.graphics
atelier = require "atelier"

rx = require "modules.rx"
require "modules.rx-love"
Atlas = require "atlas"

love.keypressed
    :filter(function(k) return k == "escape" end)
    :subscribe(love.event.quit)


function love.load()
    gfx.setDefaultFilter("nearest", "nearest")
    atlas = Atlas.create('res/sword_summoner')
    --[[
    love.keypressed
        :map(
            function(key)
                local m = {a = "idle", b = "cast"}
                return m[key]
            end
        )
        :flatMapLatest(function(k) return atlas:play{k} end)
        :map(function(f) return f, 100, 100 end)
        :subscribe(atlas:draw_observer(atelier.world))
        -- body...

    atlas:play{"attack", from = 2, to = nil, speed = 1}
        :map(function(f) return f, 100, 100, 0, -1, 1 end)
        :subscribe(atlas:draw_observer(atelier.world))
    atlas:play{"wisp"}
        :map(function(f) return f, 300, 100 end)
        :subscribe(atlas:draw_observer(atelier.world))
    ]]--
    battle.begin()
end

--love.update:subscribe(function(dt)
--
--end)

function love.draw()
    gfx.scale(2)
    atelier.world:draw()

    atelier.world:clear()
end
