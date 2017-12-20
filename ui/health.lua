local palette = require "ui/palette"
local constants = require "ui/constants"
local tool = require "ui/tool"

local font = constants.font()

local Health = {}

local function setup_draw(node)
    local shape  = tool.shape(Vec2(0, 0), Vec2(165, 40))
    local function draw_box(s, rad)
        rad = rad or 8
        gfx.rectangle("fill", s.pos[1], s.pos[2], s.size[1], s.size[2], rad)
    end
    --local draw_sub = rx.Subject.create()

    local transforms = {}
    transforms.outer_frame = rx.BehaviorSubject.create(shape)
    transforms.inner_frame = transforms.outer_frame
        :map(tool.shrink(10, 10))
    transforms.name_frame  = transforms.outer_frame
        :map(tool.shrink(20, 0))
        :map(tool.move(0, -20))
    transforms.outer_bar = transforms.outer_frame
        :map(tool.move(0, shape.size[2] - 10))
        :map(tool.size(-1, 20))
        :map(tool.shrink(15, 0))
        --:map(ui.shrink(5, 5))
    transforms.inner_bar = transforms.outer_bar
        :map(tool.shrink(10, 6))


    node.draw
        :with(transforms.outer_bar, node.theme)
        :subscribe(
            function(_, s, t)
                gfx.setColor(t)
                draw_box(s, 20)
            end
        )
    node.draw
        :with(transforms.inner_bar, node.health, node.damage)
        :subscribe(
            function(_, s, hp, dmg)
                local rad = 20
                local ratio = 1.0 - dmg / hp
                gfx.setColor("#00000066")
                draw_box(s, rad)
                gfx.stencil(
                    function()
                        local cover = tool.shape(
                            s.pos, Vec2(s.size[1] * ratio, s.size[2])
                        )
                        draw_box(cover, 0)
                    end,
                    "replace", 1
                )
                gfx.setStencilTest("equal", 1)
                local bar_color = "#00ff00ff"
                if ratio < 0.25 then
                    bar_color = "#ff0000ff"
                elseif ratio < 0.6 then
                    bar_color = "#ffff00ff"
                end
                gfx.setColor(bar_color)
                draw_box(s, rad)
                gfx.setStencilTest()

            end
        )
    node.draw
        :with(transforms.name_frame, node.theme, node.name)
        :subscribe(
            function(_, s, t, n)
                gfx.setColor(t)
                draw_box(s)
                gfx.setColor(palette.bg)
                gfx.setFont(constants.font())
                gfx.printf(
                    n, s.pos[1], s.pos[2] + 1, s.size[1], s.size[2], "center", "top"
                )
            end
        )
    node.draw
        :with(transforms.outer_frame, node.theme)
        :subscribe(
            function(_, s, t)
                gfx.setColor(t)
                draw_box(s)
            end
        )

    node.draw
        :with(transforms.inner_frame, node.theme, node.health, node.damage)
        :subscribe(
            function(_, s, t, hp, dmg)
                gfx.setColor(palette.bg)
                draw_box(s)
                gfx.setColor(t)
                gfx.setFont(constants.font())
                local text = string.format("%i / %i", hp - dmg, hp)
                gfx.printf(
                    text, s.pos[1], s.pos[2], s.size[1], s.size[2],
                    "center", "center", 1.25, 1.25
                )
            end
        )
end

function Health.setup(node)
    node.theme  = rx.BehaviorSubject.create(palette.hero)
    node.health = rx.BehaviorSubject.create(10)
    node.damage = rx.BehaviorSubject.create(0)
    node.name   = rx.BehaviorSubject.create("Yo Mom")

    setup_draw(node)

end

return Health
