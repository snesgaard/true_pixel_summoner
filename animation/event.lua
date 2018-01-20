local Event = {}
Event.__index = Event

function Event.__tostring(event)
    local s = "Event <%s>"
    return string.format(s, event.type)
end

function Event.create(type, ...)
    local this = {
        type = type, args = {...}
    }
    return setmetatable(this, Event)
end

return Event
