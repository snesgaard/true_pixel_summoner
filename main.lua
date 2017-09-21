gfx = love.graphics
require "modules/LOVEDEBUG/lovedebug"
List = require "list"
Dictionary = require "dictionary"
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

love.load = rx.Subject.create()

love.load:subscribe(
    function()
        _DebugSettings.OverlayColor = {30, 0, 50}
        _DebugSettings.HaltExecution = false
        gfx.setDefaultFilter("nearest", "nearest")
    end
)

function love.draw()
    gfx.scale(2)
    gfx.setColor(255, 255, 255)
    atelier.world:draw()
    atelier.screen_ui:draw()

    for _, a in pairs(atelier) do a:clear() end
end


require "test_battle"
