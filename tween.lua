local OP = require "op"
local tween = {}

local function __normalize(value, min, max)
    return (value - min) / (max - min)
end

function tween.sine(period, phase, update)
    local f = 2.0 * math.pi / period
    local p = 2.0 * math.pi * (phase or 0)
    update = update or love.update
    return update
        :scan(function(time, dt) return time + dt end, 0)
        :map(function(time) return math.sin(f * time + p) end)
end

function tween.linear(timespan, update)
    update = update or love.update
    return update
        :scan(
            function(state, dt)
                state.time = state.time + state.dt
                state.dt = dt
                return state
            end,
            {time = 0, dt = 0}
        )
        :takeWhile(function(state) return state.time < timespan end)
        :map(
            function(state)
                return math.min(1, (state.time + state.dt) / timespan)
            end
        )
end

function tween.log(timespan, update)
    local base = tween.linear(timespan, update)
    local function __map(t)
        return math.log(10 * t + 1)
    end
    local min, max = __map(0), __map(1)
    return base
        :map(__map)
        :map(function(v) return __normalize(v, min, max) end)
end

function tween.curve(timespan, update)
    return tween.linear(timespan, update)
        :map(OP.add(1.0))
        :map(OP.mul(math.pi))
        :map(math.cos)
        :map(OP.add(1))
        :map(OP.mul(0.5))

end

return tween
