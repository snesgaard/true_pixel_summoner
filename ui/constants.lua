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

return constants
