local util     = require "util"
local Node     = require "node"
local Atlas    = require "atlas"
local Sprite   = require "sprite"
local Tween    = require "tween"
local Misc     = require "pileomisc"
local OP       = require "op"
local Track    = require "animation/track"
local KeyFrame = require "animation/keyframe"
local Player   = require "animation/player"

love.draw = rx.Subject.create()

local function __do_draw()
    gfx.setColor(255, 255, 255)
    gfx.rectangle("fill", -25, -25, 50, 50)
end

local function __do_load()
    local root = Node.create()
    root.draw:subscribe(__do_draw)
    root.parent(love)

    local root2 = Node.create()
    root2.draw:subscribe(__do_draw)
    root2.parent(love)

    local t = Track.create()
        :keyframe{Vec2(100, 200), 0, interpolation = "sigmoid", map = hacker}
        :keyframe{Vec2(1000, 200), 2, interpolation = "sigmoid"}

    local t2 = Track.create()
        :keyframe{Vec2(100, 400), 0, interpolation = "linear"}
        :keyframe{Vec2(1000, 400), 2, interpolation = "linear"}
        :event("tag1", 0.5)
        :event("tag2", 1.5)

    player = Player.create()
        :add("sig", t, root.position)
        :add("line", t2, root2.position)

    player.event:subscribe(print)
    root.update
        :subscribe(coroutine.wrap(function(dt)
            player:play(dt)
            while true do coroutine.yield() end
        end))
end

love.load:subscribe(__do_load)
