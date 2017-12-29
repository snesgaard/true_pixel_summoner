local Dictionary = require "dictionary"
local Track      = require "animation/track"

local Player = {}
Player.__index = Player

function Player.__tostring(player) return "Player" end

function Player.create()
    local this = {
        tracks       = Dictionary.create(),
        destinations = Dictionary.create(),
        event        = rx.Subject.create()
    }
    return setmetatable(this, Player)
end

function Player:add(name, track, dst)
    self.tracks[name]       = track
    self.destinations[name] = dst
    return self
end

function Player:remove(name)
    self.tracks[name]       = nil
    self.destinations[name] = nil
end

function Player:play(dt, node)
    local duration = self.tracks:values()
        :map(Track.duration)
        :reduce(math.max)

    local players  = self.tracks:map(
        function(track)
            return track:player(self.event)
        end
    )

    local time = 0
    local prevtime = 0

    local dst = self.destinations
        :map(function(ip) return node:find(ip) end)
    while prevtime < duration do
        for name, p in pairs(players) do
            local d = dst[name]
            if d then d(p(time)) end
        end
        prevtime = time
        time = time + dt
        dt = coroutine.yield()
    end
    self.event("done")
end


return Player
