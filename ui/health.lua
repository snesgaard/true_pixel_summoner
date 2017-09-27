local palette = require "ui/palette"
local constants = require "ui/constants"

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
    return padstring(tostring(hp - dmg)) .. " / " .. padstring(tostring(hp))
end

function health.draw(x, y, _, _, _, damage, health, theme, bg, __type)
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
    local _top_w = 6
    gfx.rectangle("fill", x + _top_w, y - 8, w - _top_w * 2, 20, r)
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
    --gfx.setColor(bg)
    gfx.printf(
        __type, x, y - 7, w *  2, "center",
        0, 0.5, 0.5
    )
    --gfx.rectangle("fill", x, y + h * 0.5 - 3, w, h - m * 4)
end

function health.draw_observer(painter)
    return function(pos, hp, dmg, faction, __type)
        painter:register(
            health.draw, pos[1], pos[2], 0, 0, 0, hp, dmg,
            palette.bg, palette[faction], __type
        )
    end
end


function health.create(id, evolution, painter)
    local cancel = rx.Subject.create()
    evolution
        :takeUntil(cancel)
        :map(
            function()
                local place = gamestate:get("placement", id)
                local faction = gamestate:get("faction", id)
                local health = gamestate:get("health", id)
                local dmg = gamestate:get("damage", id)
                local __type = get_type(id):upper()
                -- calculate postion here
                local pos = constants.battle_position(place, faction)
                return pos:add(Vec2(0,15)), dmg, health, faction, __type
            end
        )
        :flatMapLatest(
            function(...)
                local arg = {...}
                return love.update:map(function() return unpack(arg) end)
            end
        )
        :subscribe(health.draw_observer(painter))
    return Dictionary.create({cancel = cancel})
end

return health
