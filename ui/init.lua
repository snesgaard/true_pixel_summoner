local ui = {
    health = require "ui/health",
    constants = require "ui/constants",
    palette = require "ui/palette",
    menu = require "ui/menu",
    number = require "ui/number"
}

function ui.shrink(dx, y)
    local v = Vec2(dx, dy)
    return function(pos, size)
        return pos:add(v:dot(0.5)), size:sub(v)
    end
end

local function size(w, h)
    if w < 0 and h < 0 then
        return function(p, s)
            return p, s
        end
    elseif w < 0 then
        return function(p, s)
            return p, vec2(s[1], h)
        end
    elseif h < 0 then
        return function(p, s)
            return p, vec2(w, s[2])
        end
    else
        return function(p, s)
            return p, vec2(w, h)
        end
    end
end

local function move(x, y)
    local v = vec2(x, y)
    return function(p, s)
        return p:add(v), s
    end
end

return ui
