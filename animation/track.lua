local List = require "list"
local KeyFrame = require "animation/keyframe"
local Event = require "animation/event"

local Track = {}
Track.__index = Track

function  Track.__tostring(t)
    return "Track"
end

function Track.create()
    local this = {
        keyframes = List.create(),
        events    = List.create(),
    }

    return setmetatable(this, Track)
end

function Track:set_destination(dst)
    self.dst = dst
end

function Track:keyframe(args)
    self.keyframes = self.keyframes:insert(
        KeyFrame.create(args)
    )
    return self
end

function Track:event(name, time, ...)
    local args = {...}
    self.events = self.events:insert(Event.create(name, time, args))
    return self
end

function Track:duration()
    return math.max(unpack(self.keyframes:map(function(k) return k.time end)))
end

function Track:player(event_topic)
    local keyframes = {unpack(self.keyframes)}
    local events = List.create(unpack(self.events))

    return coroutine.wrap(function(time)

        local index      = 1
        local prev, next = nil, keyframes[index]


        while true do
            while next and next.time < time do
                index = index + 1
                prev = keyframes[index - 1]
                next = keyframes[index]
            end
            while prev and time < prev.time do
                index = index - 1
                prev = keyframes[index - 1]
                next = keyframes[index]
            end

            if event_topic then
                while 0 < events:size() and events:head().time < time do
                    event_topic(events:head().name, events:head().args)
                    events = events:erase(1)
                end
            end

            if not prev and next then
                time = coroutine.yield(next.value)
            elseif prev and not next then
                time = coroutine.yield(prev.value)
            else
                time = coroutine.yield(KeyFrame.interpolate(prev, next, time))
            end
        end
    end)
end

return Track
