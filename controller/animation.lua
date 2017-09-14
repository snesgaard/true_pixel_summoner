local ctrl = {}

local request = rx.Subject.create()
local force = rx.Subject.create()
local frames = rx.Subject.create()

function ctrl.request(id, type)
    request(id, type)
end

local request_handles = {}
function request_handles.idle(atlas)
    return atlas:play{"idle"}
end
function request_handles.chant(atlas)
    return atlas:play{"cast", from = 2, to = 3}
end
function request_handles.cast(atlas)
    return atlas:play{"cast", from = 4, to = 5, speed = 1.5}
end
function request_handles.attack(atlas)
    return atlas:play{"attack", from = 2}
end

function ctrl.create(id, atlas)
    request
        :filter(function(_id) return _id == id end)
        :flatMapLatest(
            function(_, type)
                local f = request_handles[type]
                return f(atlas)
            end
        )
        :map(function(f) return f, id end)
        :subscribe(frames)
end

function ctrl.frames()
    return frames
end

return ctrl
