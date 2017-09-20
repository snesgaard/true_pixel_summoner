local util = {}

function util.span(timespan)
    return love.update
        :scan(function(time, dt) return time + dt end, 0)
        :takeWhile(function(time) return time < timespan end)
        :map(function(time) return time / timespan end)
end

function util.wooble(visualstate, id)
    util.span(0.5)
        :map(
            function(t)
                local rounds = 5
                local amp = 2 * (math.exp(1 - t) - 1)
                return amp * math.sin(rounds * math.pi * 2 * t)
            end
        )
        :subscribe(function(w) visualstate:mutate("wooble", id, w) end)
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

return util
