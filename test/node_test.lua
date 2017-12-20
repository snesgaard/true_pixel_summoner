local util   = require "util"
local Node   = require "node"
local Atlas  = require "atlas"
local Sprite = require "sprite"


love.draw = rx.Subject.create()

local function load_test()
    local atlas = Atlas.create('res/sword_summoner/')
    local node = Node.create()
    node:set_update(love)
    node:set_draw(love)
    node:set_input(love)
    --node.scale(Vec2(2, 2))

    local sprite = Node.create(Sprite.setup, atlas)
    sprite:set_update(node)
    sprite:set_draw(node)
    sprite.play("gibbles")
    sprite.position(Vec2(100, 100))

    local stats_ui = Node.create(ui.health.setup)
    stats_ui:set_update(sprite)
    stats_ui:set_draw(sprite)
    stats_ui.position(Vec2(200, 100))
    stats_ui.damage(2)

    local items = {"foo", "bar", "spam", "foo", "bar", "spam"}
    local menu = Node.create(ui.menu, items)
    menu:set_update(node)
    menu:set_draw(node)
    menu:set_input(node)
    menu.position(Vec2(500, 200))

    local scroll = Node.create(ui.scroll, 200)
    scroll:set_update(node)
    scroll:set_draw(node)
    scroll:set_input(node)
    scroll.position(Vec2(200, 500))
end

love.load:subscribe(load_test)
