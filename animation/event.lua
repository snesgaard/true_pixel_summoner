local Event = {}
Event.__index = Event

function Event.__tostring(event)
    local s = "Event(%f) = %s"
    return string.format(s, event.time, event.name)
end

function Event.create(name, time, args)
    local this = {
        name = name, time = time, args = args
    }
    return setmetatable(this, Event)
end

return Event
