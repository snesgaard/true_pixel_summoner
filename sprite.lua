local Internal = {}

local Sprite = {}

local loops = {}
function loops.normal(frame, range)
    frame = frame + 1
    if range[2] < frame then
        return range[1]
    else
        return frame
    end
end

function loops.once(frame, range)
    return math.max(math.min(frame + 1, range[2]), range[1])
end

function Internal.frame_updater(node)
    -- Updater

    node.frame_seq
        :flatMapLatest(
            function(anime)
                if anime == nil then
                    return node.__null()
                else
                    return node.update
                end
            end
        )
        :with(node.speed, node.frame, node.frame_seq)
        :scan(
            function(time, dt, speed, frame, frame_seq)
                if time < 0 then
                    time = time + frame_seq[frame].time
                end
                return time - dt * speed
            end,
            0
        )
        :filter(function(time) return time <= 0 end)
        :with(node.frame, node.range, node.loop)
        :map(
            function(_, frame, range, loop_type)
                local f = loops[loop_type]
                --print("what!!", frame, range, loop_type)
                return f(frame, range)
            end
        )
        :subscribe(node.frame)
end

function Internal.play(node)
    local play = rx.Subject.create()

    play
        :map(
            function(t, ...)
                if type(t) ~= "table" then
                    return {t, ...}
                else
                    return t
                end
            end
        )
        :with(node.atlas)
        :subscribe(
            function(args, atlas)
                local seq = atlas.animations:fetch(args[1])
                node.frame(0)
                node.frame_seq(seq)
                node.animation(args[1])
                node.speed(args.speed or 1)
                node.range(Vec2(args.from or 1, args.to or #seq))
                node.loop(args.loop or "normal")
            end
        )

    return play
end

function Internal.drawer(node)
    node.frame_seq
        :flatMapLatest(
            function(anime)
                if anime == nil then
                    return node.__null()
                else
                    return node.draw
                end
            end
        )
        :with(node.atlas, node.frame, node.frame_seq, node.color)
        :subscribe(
            function(_, atlas, frame, frame_seq, color)
                gfx.setColor(color)
                atlas:draw(frame_seq[frame])
            end
        )
end

function Sprite.setup(node, atlas)
    node.atlas     = rx.BehaviorSubject.create(atlas)
    node.frame     = rx.BehaviorSubject.create(1)
    node.frame_seq = rx.BehaviorSubject.create()
    node.animation = rx.BehaviorSubject.create()
    node.speed     = rx.BehaviorSubject.create(1)
    node.loop      = rx.BehaviorSubject.create()
    node.range     = rx.BehaviorSubject.create(Vec2(0,0))
    node.color     = rx.BehaviorSubject.create("#ffffffff")

    -- Create additional control function
    node.play      = Internal.play(node)
                     Internal.frame_updater(node)
                     Internal.drawer(node)
end

return Sprite
