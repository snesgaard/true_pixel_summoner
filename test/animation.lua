local util     = require "util"
local Node     = require "node"
local Atlas    = require "atlas"
local Sprite   = require "sprite"
local Tween    = require "tween"
local Misc     = require "pileomisc"
local OP       = require "op"
local Animation = require "animation"

love.draw = rx.Subject.create()

local function __do_load()
    local atlas = Animation.Atlas.create('res/sword_summoner')

    local root   = Node.create()
    local sprite = Node.create(Sprite, atlas)
    local anime  = Node.create(Animation.Control, atlas)

    root.parent(love)
    sprite.parent(root)
    anime.parent(sprite)

    sprite.position(Vec2(200, 200))
    anime.set_animation("idle", true)

    love.keypressed
        :subscribe(function() anime.set_animation("chant", true) end)
    --sprite.frame:subscribe(print)
    --sprite.image:subscribe(print)
end

love.load:subscribe(__do_load)
