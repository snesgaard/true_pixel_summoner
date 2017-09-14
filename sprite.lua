local Sprite = {}
Sprite.__index = Sprite

function Sprite.create(atlas, frames)
    local sprite = {event = rx.Subject.create()}

    return setmetatable(sprite, Sprite)
end

function Sprite:bounce(args)

end

function Sprite.draw(atlas, frame, x, y, r, sx, sy)
    local quad, ox, oy = unpack(frame)
    gfx.draw(atlas.sheet, frame)
    r = r or 0
    sx = sx or 1
    sy = sy or 1
    gfx.draw(atlas.sheet, quad, x, y, r, sx, sy, ox, oy)
end

return Sprite
