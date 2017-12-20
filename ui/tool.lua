local tool  = {}

local Shape = {}
Shape.__index = Shape

function Shape.__tostring(s)
    return string.format(
        "{pos = %s, size = %s}", tostring(s.pos), tostring(s.size)
    )
end

function tool.shape(p, s)
    return setmetatable({pos = p, size = s}, Shape)
end

function tool.shrink(dx, dy)
    local v = Vec2(dx, dy)
    return function(s)
        return tool.shape(s.pos:add(v:dot(0.5)), s.size:sub(v))
    end
end

function tool.size(w, h)
    if w < 0 and h < 0 then
        return function(s)
            return s
        end
    elseif w < 0 then
        return function(s)
            return tool.shape(s.pos, Vec2(s.size[1], h))
        end
    elseif h < 0 then
        return function(s)
            return tool.shape(s.pos, Vec2(w, s.size[2]))
        end
    else
        return function(s)
            return tool.shape(p, Vec2(w, h))
        end
    end
end

function tool.move(x, y)
    local v = Vec2(x, y)
    return function(s)
        return tool.shape(s.pos:add(v), s.size)
    end
end

return tool
