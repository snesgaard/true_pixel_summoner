local timer = {}

function timer.span(timespan)
    return love.update
        :scan(function(time, dt) return time + dt end, 0)
        :takeWhile(function(time) return time < timespan end)
        :map(function(time) return time / timespan end)
end

return timer
