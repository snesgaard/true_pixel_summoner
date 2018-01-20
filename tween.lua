local OP = require "op"

local BaseTween = {}
BaseTween.__index = BaseTween

function BaseTween.create(base_signal)
    return setmetatable({base_signal = base_signal}, BaseTween)
end

function BaseTween:step(from, to)
    if type(from) == "table" then
        return self:step(1, #from)
            :map(function(i) return from[i] end)
    else
        local d = to - from + 1
        local function step(t)
            -- TODO Consuider inserting a math.max(to) here for defensive coding
            return math.min(math.floor(t * d) + from, to)
        end

        return self.base_signal:map(step)
    end

end

function BaseTween:ballistic(distance, height)
    if type(distance) == "table" then
        distance, height = unpack(distance)
    end
    local function get_y(t) return -4 * height * t * (t - 1) end
    local function get_x(t) return t * distance end
    local function get_pos(t) return Vec2(get_x(t), get_y(t)) end

    return self.base_signal:map(get_pos)
end

function BaseTween:sigmoid()
    local low, high = -3, 6
    local function f(x)
        x = (high - low) * x + low
        return 1 / (1 + math.exp(-x))
    end
    local min, max = f(0), f(1)
    local function normalize(s)
        return (s - min) / (max - min)
    end
    return BaseTween.create(
        self.base_signal
            :map(f)
            :map(normalize)
    )
end

function BaseTween:base() return self.base_signal end

function BaseTween:constant(value)
    return self.base_signal:take(1):map(OP.constant(value))
end

function BaseTween:lerp(from, to)
    local function __num_lerp(t)
        return from * (1 - t) + to * t
    end
    local function __vec_lerp(t)
        return Vec2.add(from:dot(1 - t), to:dot(t))
    end
    local __lerp = type(from) == "number" and __num_lerp or __vec_lerp
    return self.base_signal:map(__lerp)
end

local Tween = {}

function Tween.linear(timespan, update)
    update = update or love.update
    local function update_time(time, dt) return time + dt end
    local function check_time(time) return time < timespan end
    local function norm_time(time) return time / timespan end

    return BaseTween.create(
        update
            :scan(update_time, 0)
            :takeWhile(check_time)
            :map(norm_time)
    )
end

function Tween.loop(timespan, update)
    update = update or love.update

    local function update_time(time, dt)
        if timespan < time then
            return update_time(time - timespan, dt)
        else
            return time + dt
        end
    end
    local function norm_time(time) return time / timespan end

    return BaseTween.create(
        update
            :scan(update_time, 0)
            :map(norm_time)
    )
end

function Tween.sine(period, phase, update)
    local f, p = math.pi * 2 / period, math.pi * 2 * (phase - 0.5)
    update = update or love.update
    local function update_time(time, dt) return time + dt end
    local function sine(t) return math.cos(f * t + p) * 0.5 + 0.5 end
    return BaseTween.create(
        update
            :scan(update_time, 0)
            :map(sine)
    )
end

return Tween
