local interpolation_types = {}

function interpolation_types.nearest(k1, k2, time)
    if math.abs(k1.time - time) < math.abs(k2.time - time) then
        return 0
    else
        return 1
    end
end

function interpolation_types.linear(k1, k2, time)
    local t1, t2 = k1.time, k2.time
    return (time - t1) / (t2 - t1)
end

function interpolation_types.sigmoid(k1, k2, time)
    local s = interpolation_types.linear(k1, k2, time)
    local r_low, r_high = -1, 3
    s = r_low * (1 - s) + s * r_high
    local function f(x) return 1 / (1 + math.exp(-x)) end

    local min, max, value = f(r_low), f(r_high), f(s)

    --print(value, (value - min) / (max - min), min, max, s)
    return (value - min) / (max - min)
end

local blend_types = {}

function blend_types.Numeric(v1, v2, s)
    return v1 * (1 - s) + v2 * s
end

function blend_types.Vec2(v1, v2, s)
    return Vec2.add(v1:dot(1 - s), v2:dot(s))
end

local round_types = {
    Numeric = {ceil = math.ceil, floor = math.floor, none = OP.identity},
    Vec2 = {none = OP.identity}
}

function round_types.Vec2.ceil(v)
    return Vec2(math.ceil(v[1]), math.ceil(v[2]))
end

function round_types.Vec2.floor(v)
    return Vec2(math.floor(v[1]), math.floor(v[2]))
end

local KeyFrame = {}
KeyFrame.__index = KeyFrame

function KeyFrame.__tostring(kf)
    return string.format("KeyFrame [%f -> %s]", kf.time, tostring(kf.value))
end

function KeyFrame.create(args)
    local value, time   = args[1], args[2]
    local interpolation = args.interpolation
    local istable = type(value) == "table"
    local map = args.map or OP.identity

    local blend = istable and blend_types.Vec2 or blend_types.Numeric
    local round = istable and round_types.Vec2 or round_types.Numeric
    local this = {
        value = value, time = time, blend = blend,
        interpolation = interpolation or "linear",
        map = map
    }
    return setmetatable(this, KeyFrame)
end

function KeyFrame.interpolate(k1, k2, time)
    if not k1 and k2 then return k2.value end
    if k1 and not k2 then return k1.value end
    if k1.interpolation == "step" then return k1.value end
    local i = interpolation_types[k1.interpolation]
    local s = i(k1, k2, time)
    return k1.map(k1.blend(k1.value, k2.value, s))
end

return KeyFrame
