local palette = require "ui/palette"
local constants = require "ui/constants"
local tool = require "ui/tool"
local util = require "util"

local Scroll = {}
Scroll.__index = Scroll

local DEFINE = {
    height = 8,
    cursor = Vec2(8, 26)
}

local function setup_draw(node)
    local transforms = {}

    transforms.outer_frame = node.length
        :map(
            function(l)
                return tool.shape(Vec2(0, 0), Vec2(l, DEFINE.height))
            end
        )
    transforms.inner_frame = transforms.outer_frame
        :map(tool.shrink(4, 4))
    transforms.cursor      = rx.Observable.combineLatest(
            transforms.inner_frame, node.length, node.pose
        )
        :map(
            function(s, l, p)

                local x = s.pos[1] - DEFINE.cursor[1] * 0.5 + l * p
                local y = s.pos[2] + DEFINE.height * 0.25 - DEFINE.cursor[2] * 0.5
                return tool.shape(Vec2(x, y), DEFINE.cursor)
            end
        )

    local function draw_bar(s, rad)
        local x, y = unpack(s.pos)
        local w, h = unpack(s.size)
        gfx.rectangle("fill", x, y, w, h, rad)
    end

    node.draw
        :with(transforms.outer_frame, node.theme)
        :subscribe(
            function(_, s, t)
                gfx.setColor(t)
                draw_bar(s, s.size[2] * 0.5)
            end
        )
    node.draw
        :with(transforms.inner_frame)
        :subscribe(
            function(_, s)
                gfx.setColor("#00000077")
                draw_bar(s, s.size[2] * 0.5)
            end
        )
    node.draw
        :with(transforms.cursor, node.theme)
        :subscribe(
            function(_, s, t)
                gfx.setColor(t)
                draw_bar(s, 2)
            end
        )

end

local function setup_input(node)
    node.keypressed
        :map(
            function(key)
                local rate = 0.05
                local keymap = {left = -rate, right = rate}
                return keymap[key], key
            end
        )
        :filter(function(dir) return dir end)
        :flatMap(
            function(dir, key)
                local term = node.keyreleased
                    :filter(OP.equal(key))
                return util.period(0.2, node.update)
                    :takeUntil(term)
                    :map(OP.constant(dir))
                    --:startWith(dir)
            end
        )
        :with(node.pose)
        :map(
            function(dir, pose)
                return pose + dir
            end
        )
        :map(OP.clamp(0, 1))
        :subscribe(node.pose)
end

return function(node, length)
    node.pose   = rx.BehaviorSubject.create(0.2)
    node.length = rx.BehaviorSubject.create(length)
    node.theme  = rx.BehaviorSubject.create(palette.hero)

    setup_draw(node)
    setup_input(node)
end
