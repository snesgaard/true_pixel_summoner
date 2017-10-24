require "math"
local palette = require "ui/palette"

local util = {}

function util.wait(timespan)
    return love.update
        :scan(function(time, dt) return time + dt end, 0)
        :filter(function(t) return timespan < t end)
end

function util.span(timespan)
    return love.update
        :scan(function(time, dt) return time + dt end, 0)
        :takeWhile(function(time) return time < timespan end)
        :map(function(time) return time / timespan end)
end

function util.sine(period, phase)
    local f = 2.0 * math.pi / period
    local p = 2.0 * math.pi * (phase or 0)
    return love.update
        :scan(function(time, dt) return time + dt end, 0)
        :map(function(time) return math.sin(f * time + p) end)
end

function util.period(period)
    return util.sine(period  * 2)
        :scan(
            function(agg, next)
                agg.prev = agg.next
                agg.next = next
                return agg
            end,
            {next = -1}
        )
        :filter(
            function(agg)
                return agg.prev * agg.next < 0
            end
        )
end

function util.wooble()
    return util.span(0.5)
        :map(
            function(t)
                local rounds = 5
                local amp = 2 * (math.exp(1 - t) - 1)
                return amp * math.sin(rounds * math.pi * 2 * t)
            end
        )
end

function util.hexcolor(hex)
    _,_,r,g,b,a = hex:find('#(%x%x)(%x%x)(%x%x)(%x%x)')
   return tonumber(r,16),tonumber(g,16),tonumber(b,16),tonumber(a,16)
end

local _old_setColor = gfx.setColor
function gfx.setColor(str, ...)
    if type(str) == "string" then
        return _old_setColor(util.hexcolor(str))
    else
        return _old_setColor(str, ...)
    end
end

util.target_corner = coroutine.wrap(
    function(x, y, _, sx, sy)
        local curve = love.math.newBezierCurve(
            {
                -15, 0,
                -3, 0,
                0, 0,
                0, -3,
                0, -15,
            }
        )
        while true do
            gfx.push()
            gfx.translate(x, y)
            gfx.scale(sx, sy)
            gfx.setLineWidth(2)
            gfx.line(curve:render())
            gfx.pop()
            x, y, _, sx, sy = coroutine.yield()
        end
    end
)

function util.entity_target(x, y, amp)
    y = y + 5
    gfx.setColor(palette.bg)
    util.target_corner(x + 25 + amp, y + amp, 0, 1, 1)
    util.target_corner(x - 25 - amp, y + amp, 0, -1, 1)
    util.target_corner(x - 25 - amp, y - 80 - amp, 0, -1, -1)
    util.target_corner(x + 25 + amp, y - 80 - amp, 0, 1, -1)
end

return util
