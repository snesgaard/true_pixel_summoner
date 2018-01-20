local palette = require "ui/palette"
local constants = require "ui/constants"
local tool = require "ui/tool"
local util = require "util"
local InterNode = require "interaction_node"
local misc = require "pileomisc"
local Node = require "node"

local Menu = {}
Menu.__index = Menu

local DEFINE = {
    width = 100,
    height = 25,
    inner_margin = 3,
    outer_margin = 5
}


local function setup_draw(node)
    local transforms = {}
    transforms.outer_frame = node.items
        :map(
            function(items)
                local l = #items
                local h = l * DEFINE.height + (l - 1) * DEFINE.inner_margin
                h = h  + 2 * DEFINE.outer_margin
                local w = DEFINE.width + 2 * DEFINE.outer_margin
                return tool.shape(Vec2(0, 0), Vec2(w, h))
            end
        )
    transforms.inner_frame = transforms.outer_frame
        :map(tool.shrink(DEFINE.outer_margin * 2, DEFINE.outer_margin * 2))

    node.draw
        :with(transforms.outer_frame, node.theme.normal)
        :subscribe(
            function(_, s, t)
                gfx.setColor(t)
                gfx.rectangle(
                    "fill", s.pos[1], s.pos[2], s.size[1], s.size[2], 5
                )
            end
        )
    node.draw
        :with(
            transforms.inner_frame, node.items, node.theme.normal,
            node.theme.select, node.selected
        )
        :subscribe(
            function(_, shape, items, tnormal, tselect, selected)
                local o = DEFINE.height + DEFINE.inner_margin
                for i, val in ipairs(items) do
                    local pos = shape.pos:add(Vec2(0, (i - 1) * o))
                    local w, h = shape.size[1], DEFINE.height

                    gfx.setColor(selected == i and tselect or palette.bg)
                    gfx.rectangle("fill", pos[1], pos[2], w, h, 5)
                    gfx.setColor(tnormal)
                    gfx.printf(val, pos[1], pos[2], w, h, "center", "center")
                end
            end
        )
end


local function Menu(node, items)
    InterNode(node)
    node.items    = rx.BehaviorSubject.create(items)
    node.selected = rx.BehaviorSubject.create(nil)
    node.theme    = {
        normal    = rx.BehaviorSubject.create(palette.hero),
        select    = rx.BehaviorSubject.create(palette.select),
    }

    setup_draw(node)
    --setup_input(node)

    node.revive
        :map(function() return palette.hero end)
        :subscribe(node.theme.normal)
    node.dormant
        :map(function() return palette.villian end)
        :subscribe(node.theme.normal)


    node.revive
        :with(node.selected)
        :flatMapLatest(
            function(_, i)
                i = i or -1
                return misc.selector(items, {up = -1, down = 1}, i, node)
                    :takeUntil(node.dormant)
            end
        )
        :subscribe(node.selected)

    node.revive
        :flatMapLatest(
            function()
                return node.keypressed:takeUntil(node.dormant)
            end
        )
        :filter(function(key) return key == "space" end)
        :flatMapLatest(function() return node.selected:take(1) end)
        :compact()
        :map(function(s) return items[s] end)
        :subscribe(node.publish)

    node.revive
        :flatMapLatest(
            function()
                return node.keypressed:takeUntil(node.dormant)
            end
        )
        :filter(OP.equal("escape"))
        :subscribe(node.reject)

    node.revive()
end

return Menu

--setmetatable(Menu, Menu)

--return setmetatable({}, Menu)
