local ResouceManager = require "resource_manager"
local List = require "list"
local Dictionary = require "dictionary"
require "math"

local Atlas = {}
Atlas.__index = Atlas

local INDICES = {
    TIME = 4,
    OFFSET_Y = 3,
    OFFSET_X = 2,
    QUAD= 1,
}

function Atlas:play(args)
    local type = args.type or args[1]
    local anime_frames = self.animations:fetch(type)
    local from = args.from or 1
    local to = args.to or #anime_frames
    local speed = args.speed or 1
    local loop = args.loop or "normal"
    local df = loop == "reverse" and -1 or 1

    local resolve_boundry = {}
    function resolve_boundry.normal(frame_data)
        frame_data.frame = from
        frame_data.df = 1
        frame_data.event.loop = true
    end
    function resolve_boundry.bounce(frame_data)
        frame_data.df = frame_data.frame == to and -1 or 1
        frame_data.event.loop = true
        --frame_data.frame = frame_data.frame == to and to -1 or from + 1
    end
    function resolve_boundry.reverse(frame_data)
        frame_data.frame = to
        frame_data.df = -1
        frame_data.event.loop = true
    end
    function resolve_boundry.once(frame_data)
        frame_data.time = to
        frame_data.df = 0
        frame_data.event.finish = true
    end

    -- Updates the sprite with a given tiem step
    local function update_sprite(frame_data, dt)
        -- Update time
        frame_data.time = frame_data.time + dt * speed
        -- Check if we have exceed the current frame time
        local frame = frame_data.frame
        local frame_time = anime_frames[frame].time
        local df = frame_data.df
        -- If yes, update frame number and return recursively with a negative time step
        -- This resets the frame time with an appropiate amount
        if frame_data.time > frame_time then
            --frame_data.frame = frame < to and frame + df or from
            local next_frame = frame + df
            if from <= next_frame and next_frame <= to then
                frame_data.frame = frame + df
            else
                local f = resolve_boundry[loop]
                f(frame_data)
            end
            return update_sprite(frame_data, -frame_time / speed)
        end
        -- If not, simply reutrn the current data
        return frame_data
    end

    local function reset_events(frame_data, dt)
        frame_data.event = {}
        return update_sprite(frame_data, dt)
    end

    return love.update
        :scan(reset_events, {frame = from, time = 0, df = df})
        :map(
            function(frame_data)
                return anime_frames[frame_data.frame], frame_data.event
            end
        )
end

function Atlas.create(base_path)
    local sheet = gfx.newImage(base_path .. "/sheet.png")
    local status, normal = pcall(function()
        return gfx.newImage(base_path .. "/normal.png")
    end)
    --normal = status and normal or asset.default_normal
    local hitbox = require (base_path .. "/hitbox")
    local info = require (base_path .. "/info")

    local atlas = {
        animations = ResouceManager.create(),
        sheet = sheet,
        normal = normal
    }
    -- Iterate through all specified animations
    for key, pos in pairs(info) do
        local hit = hitbox[key]
        local x = pos.x
        local y = pos.y
        local h = pos.h
        -- Create quads covering the extend of the sprite
        local frame_size = List.create(unpack(hit.frame_size))
        local anime_size = #frame_size
        -- Calculate the position of each frame
        local frame_borders = frame_size
            :scan(function(agg, fs) return agg + fs end, pos.x)
        -- Craete a quad for each frame
        -- TODO SUB is broken, plz fix
        atlas.animations.__data[key] = List.zip(frame_borders:sub(1, -1), frame_size)
            :map(
                function(arg)
                    return love.graphics.newQuad(
                        arg[1], y, arg[2], h, sheet:getDimensions()
                    )
                end
            )
            --Attach x offset, y offset and time to each frame
            :zip(
                hit.offset_x, hit.offset_y,
                List.duplicate(hit.time, anime_size)
            )
            :map(
                function(arg)
                    return Dictionary.create(
                        {quad = arg[1], ox = arg[2], oy = arg[3], time = arg[4]}
                    )
                end
            )
    end
    -- Return the atlas object
    return setmetatable(atlas, Atlas)
end

function Atlas.draw(x, y, r, sx, sy, sheet, frame)
    gfx.draw(sheet, frame.quad, x, y, r, sx, sy, frame.ox, frame.oy)
end

function Atlas:draw_observer(painter)
    return function(frame, x, y, r, sx, sy)
        painter:register(Atlas.draw, x, y, r, sx, sy, self.sheet, frame)
    end
end

return Atlas
