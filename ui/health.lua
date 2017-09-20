local palette = require "ui/palette"

local DEFINE = {
    margin = 2,
    shape = {60, 15, 5},
    bar = {10, 5},
    font = gfx.newImageFont("res/font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
}

local health = {}



local function health2string(dmg, hp)
    local function padstring(s)
        local l = string.len(s)
        return string.rep(" ", 3 - l) .. s
    end
    return padstring(tostring(hp - dmg)) .. " / " .. tostring(hp)
end

function health.draw(x, y, _, _, _, damage, health, theme, bg)
    local w, h, r = unpack(DEFINE.shape)
    x = x - w * 0.5
    local m = DEFINE.margin
    gfx.setColor(theme)
    local bh, br = unpack(DEFINE.bar)

    -- Draw the healthbar
    gfx.rectangle(
        "fill", x + r, y + h - bh / 2, w - r * 2, bh, br
    )
    gfx.stencil(function()
        gfx.rectangle(
            "fill", x + r + m, y + h - bh / 2 + m, w - r * 2 - m * 2, bh - m * 2, br
        )
    end, "replace", 1)

    gfx.setStencilTest("equal", 1)
    gfx.setColor(0, 0, 0, 100)
    gfx.rectangle(
        "fill", x + r + m, y + h - bh / 2 + m, w - r * 2 - m * 2, bh - m * 2
    )
    local ratio = (1 - damage / health)
    local color = ratio < 0.25 and {120, 20, 20} or {20, 120, 20}
    gfx.setColor(unpack(color))
    gfx.rectangle(
        "fill", x + r + m, y + h - bh / 2 + m,
         ratio * (w - r * 2 - m * 2), bh - m * 2
    )
    gfx.setStencilTest()
    -- Draw the healt number
    gfx.setColor(theme)
    gfx.rectangle("fill", x, y, w, h, r)
    gfx.setColor(0, 0, 0, 200)
    gfx.rectangle("fill", x + m + 1, y + m + 1, w - m * 2, h - m * 2, r)
    gfx.setColor(bg)
    gfx.rectangle("fill", x + m, y + m, w - m * 2, h - m * 2, r)

    gfx.setFont(DEFINE.font)
    DEFINE.font:setFilter("nearest", "nearest")
    gfx.setColor(255, 255, 255)
    gfx.printf(
        health2string(damage, health), x, y + h * 0.5 - DEFINE.font:getHeight() / 4, w *  2, "center",
        0, 0.5, 0.5
    )
    gfx.setColor(255, 0, 0)
    --gfx.rectangle("fill", x, y + h * 0.5 - 3, w, h - m * 4)
end

function health.draw_observer(painter)
    return function(pos, hp, dmg)
        painter:register(
            health.draw, pos[1], pos[2], 0, 0, 0, hp, dmg,
            palette.bg, palette.hero
        )
    end
end

return health
