local palette = require "ui/palette"
local constants = require "ui/constants"

local menu = {}

local DEFINE = {
    width = 100,
    height = 25,
}

function menu.draw(x, y, w, h, entries, selected)
    local font = constants.font()
    entries = entries or {}
    for i, str in ipairs(entries) do
        local __x, __y = x, y + (i - 1) * h
        if i == selected then
            gfx.setColor(palette.select)
        else
            gfx.setColor(palette.hero)
        end
        gfx.rectangle("fill", __x, __y, w, h, 3)

        gfx.setColor(255, 255, 255)
        gfx.setFont(font)
        gfx.printf(str, __x, __y, w, h,  "center", "middle")
    end
end

return menu
