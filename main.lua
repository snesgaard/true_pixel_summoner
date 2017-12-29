gfx = love.graphics
--require "modules/LOVEDEBUG/lovedebug"
List = require "list"
Dictionary = require "dictionary"
OP = require "op"
local util = require "util"
Vec2 = require "vec2"
atelier = require "atelier"

rx = require "modules.rx"
ui = require "ui"
require "modules.rx-love"
Atlas = require "atlas"
Database = require "database"
Broadcaster = require "broadcaster"

love.keypressed
    :filter(function(k) return k == "escape" end)
    :subscribe(love.event.quit)

love.load = rx.Subject.create()


love.load:subscribe(
    function()
        if _DebugSettings then
            _DebugSettings.OverlayColor = {30, 0, 50}
            _DebugSettings.HaltExecution = true
        end
        gfx.setDefaultFilter("nearest", "nearest")
    end
)

love.update:subscribe(
    function()
        require("modules/lovebird/lovebird").update()
    end
)

function love.draw()
    gfx.scale(2)
    gfx.setColor(255, 255, 255)
    atelier.world:draw()
    atelier.screen_ui:draw()

    for _, a in pairs(atelier) do a:clear() end
end

local __old_printf = gfx.printf
function gfx.printf(str, x, y, w, h, align, valign, sx, sy)
    sx = sx or 1
    sy = sy or sx
    local font = gfx.getFont()
    if valign == "center" then
        y = y + h * 0.5 - font:getHeight() * 0.5 * sy
    elseif valign == "bottom" then
        y = y + h - font:getHeight() * sy
    end
    __old_printf(str, x, y, w / sx, align, 0, sx, sy)
end

_coroutine_resume = coroutine.resume
function coroutine.resume(...)
	local result = {_coroutine_resume(...)}
  local state = result[1]
	if not state then
		error( tostring(result[2]), 2 )	-- Output error message
    --print( "error:" .. tostring(result[2]))	-- Output error message
	end

	return unpack(result)
end

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function string.pad(s, size, place)
    place = place or "front"
    local l = string.len(s)
    if place == "front" then
        return string.rep(" ", size - l) .. s
    else
        return s .. string.rep(" ", size - l)
    end
end


love.slowdown = rx.BehaviorSubject.create(1)

love.dilated_update = love.update
    :with(love.slowdown)
    :map(function(dt, s) return dt * s end)

--require "test/node_test"
--require "test/test_battle"
--require "test/pos_test"
--require "test/address_test"
--require "test/battle"
--require "test/animation"
require "test/sprite"
--Node = require "node"
--Node.find(b, "../bro/so")
