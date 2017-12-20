local constants = {}

function constants.battle_position(placement, faction)
    local w = gfx.getWidth() / 2
    local h = gfx.getHeight()
    if faction == "hero" then
        return Vec2(w - 150 * placement, 2 * h / 3):dot(0.5)
    else
        return Vec2(w + 150 * placement, 2 * h / 3):dot(0.5)
    end
end

constants.font = coroutine.wrap(function()
    local font = gfx.newImageFont("res/font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
    font:setFilter("nearest", "nearest")
    while true do coroutine.yield(font) end
end)

return constants
