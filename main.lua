gfx = love.graphics
require "modules/LOVEDEBUG/lovedebug"
local list = require "list"
local OP = require "op"
local util = require "util"
Vec2 = require "vec2"
atelier = require "atelier"

rx = require "modules.rx"
ui = require "ui"
require "modules.rx-love"
Atlas = require "atlas"
Property = require "property"
Herald = require "herald"
animation_ctrl = require "controller/animation"

love.keypressed
    :filter(function(k) return k == "escape" end)
    :subscribe(love.event.quit)


function love.load()
    _DebugSettings.OverlayColor = {30, 0, 50}
    _DebugSettings.HaltExecution = false
    gfx.setDefaultFilter("nearest", "nearest")
    atlas = Atlas.create('res/sword_summoner')
    summoner = "summoner"
    -- Initialize summoner
    gamestate = Property.create()
        :set("health", summoner, 30)
        :set("damage", summoner, 25)
        :set("hero", summoner, true)
        :set("cards", summoner, list.create("smorc"))
        --:set("charge", "summoner", 0)

    visualstate = Herald.create()
    visualstate:carrier("position", summoner, Vec2(200, 200))
    visualstate:carrier("face", summoner, -1)
    --visualstate:evolve(gamestate, gamestate)

    animation_ctrl.create(summoner, atlas)

    animation_ctrl:frames()
        :map(
            function(frame, id)
                local p = visualstate:get("position", id)
                local f = visualstate:get("face", id)
                local w = visualstate:get("wooble", id) or 0
                return frame, p[1] + w, p[2], 0, f, 1
            end
        )
        :subscribe(atlas:draw_observer(atelier.world))

    animation_ctrl.request(summoner, "idle")
    animation_ctrl.events()
        :filter(
            function(id, eventtype)
                return id == summoner and eventtype == "finish"
            end
        )
        :map(function() return summoner, "idle" end)
        :subscribe(animation_ctrl.force)
    love.keypressed
        :filter(OP.curry(OP.equal, "a"))
        :map(function() return summoner, "attack", true end)
        :subscribe(animation_ctrl.request)

    love.keypressed
        :map(
            function(key)
                local dir = {left = -1, right = 1}
                return dir[key]
            end
        )
        :compact()
        :map(function(dir) return visualstate, "face", summoner, dir end)
        :subscribe(visualstate.mutate)
--[[
    love.update
        :with(visualstate.evolution)
        :map(function(dt, gamestate)
            local p = visualstate:get("position", summoner)
            local hp = gamestate:get("health", summoner)
            local dmg = gamestate:get("damage", summoner) or 0
            return p:add(Vec2(0, 15)), dmg, hp
        end)
        :subscribe(ui.health.draw_observer(atelier.screen_ui))
--]]

    love.update
        :scan(
            function(time, dt) return time + dt end, 0
        )
        :subscribe(function(time)
            atelier.world:register(
                function(x, y, _, _, _, time)
                    local function _draw(p)
                        local s = math.sin((time) * 15 - p) * 5
                        local w = 50 + s
                        local h = 100 + s
                        gfx.rectangle("line", x - w / 2, y - h / 2, w, h)
                    end
                    gfx.stencil(function()
                        gfx.rectangle("fill", x - 100, y - 25, 200,  50)
                        gfx.rectangle("fill", x - 12.5, y - 200, 25,  400)
                    end, "replace", 1)
                    gfx.setStencilTest("equal", 0)
                    gfx.setLineWidth(3)
                    for i = 1,3 do
                        gfx.setColor(50, 50, 120, 200 - i * 50)
                        _draw(3 * i / 3.14)
                    end
                end,
                100, 100, 0, 0, 0, time
            )
        end)

end

--love.update:subscribe(function(dt)
--
--end)

function love.draw()
    gfx.scale(2)
    gfx.setColor(255, 255, 255)
    atelier.world:draw()
    atelier.screen_ui:draw()

    for _, a in pairs(atelier) do a:clear() end

end
