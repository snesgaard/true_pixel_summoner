local Sprite = require "sprite"
local Animation = require "animation"
local Node = require "node"

local hero = {}

function hero.visual(node, atlas)
    Sprite(node, atlas)
    node.image("idle")
    node.frame(1)
    node.name("sprite")
    node.scale(Vec2(2, 2))

    local player = Node.create(Animation.Control, atlas)

    player.name("animation")
    player.parent(node)

    player.set_animation("alchemist", true)
end

return hero
