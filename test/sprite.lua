local Animation  = require "animation"
local Sprite     = require "sprite"
local Node       = require "node"

love.draw = rx.Subject.create()

local function __do_load()
    --print("what?!?!")
    local atlas  = Animation.Atlas.create('res/sword_summoner')
    local root   = Node.create()
    local base   = Node.create()
    local sprite = Node.create(Sprite, atlas)
    local anime  = Node.create(Animation.Node, atlas:animations())

    root.parent(love)
    base.parent(root)
    sprite.parent(base)
    anime.parent(sprite)

    sprite.name("sprite")
    anime.name("yo")

    sprite.image("idle")
    anime:set_animation("cast")

    base.position(Vec2(200, 200))
end

love.load:subscribe(__do_load)
