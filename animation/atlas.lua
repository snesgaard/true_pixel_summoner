local Dictionary = require "dictionary"
local List       = require "list"
local PNode      = require "animation/playernode"

local Atlas = {}
Atlas.__index = Atlas

local function calculate_border(lx, ux) return lx + ux end

local function create_quad(y, h, sheet)
    return function(arg)
        local x, w = unpack(arg)
        return gfx.newQuad(x, y, w, h, sheet:getDimensions())
    end
end

local function create_frame(arg)
    local quad, ox, oy = unpack(arg)
    return Dictionary.create({quad = quad, ox = ox, oy = oy})
end

function Atlas.__tostring(atlas)
    return string.format('Atlas <%s>', atlas.path)
end

function Atlas.create(path)
    local sheet = gfx.newImage(path .. "/sheet.png")
    local status, normal = pcall(function()
        return gfx.newImage(path .. "/normal.png")
    end)
    local hitboxes = require (path .. "/hitbox")
    local info = require (path   .. "/info")

    local this = {
        images = Dictionary.create(),
        sheet  = sheet,
        normal = normal,
        path = path
    }

    for name, positional in pairs(info) do
        local hitbox = hitboxes[name]
        local widths = List.create(unpack(hitbox.frame_size))
        local frames = #widths
        local borders = widths:scan(calculate_border, positional.x)
        local x = positional.x
        local y = positional.y
        local h = positional.h
        local image = List.zip(borders:sub(1, -1), widths)
            :map(create_quad(y, h, sheet))
            :zip(hitbox.offset_x, hitbox.offset_y)
            :map(create_frame)
        this.images[name] = image
    end

    return setmetatable(this, Atlas)
end

function Atlas:frame(image, frame)
    local im = self.images[image]
    return im and im[frame] or nil
end

function Atlas:draw(frame, x, y, r, sx, sy)
    x  = x  or 0
    y  = y  or 0
    r  = r  or 0
    sx = sx or 1
    sy = sy or 1
    gfx.draw(self.sheet, frame.quad, x, y, r, sx, sy, frame.ox, frame.oy)
end

function Atlas:animations()
    local hitboxes = require (self.path .. "/hitbox")

    local animations = Dictionary.create()
    for name, frames in pairs(self.images) do
        local time = hitboxes[name].time

        animations[name] = function(node, loop)
            PNode(node, name, time, frames, self, loop)
        end
    end
    return animations
end

return Atlas
