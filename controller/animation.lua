local ctrl = {}

local request = rx.Subject.create()
local force = rx.Subject.create()
local frames = rx.Subject.create()
local cancel = rx.Subject.create()
local events = rx.Subject.create()
local __lock = {}

function ctrl.request(id, type, lock) request(id, type, lock) end

function ctrl.force(id, type, lock) force(id, type, lock) end

--[[
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
    return atlas:play{"attack", from = 2, loop = "once"}
end
--]]

function ctrl.create(id, atlas, request_handles)
    local function check_id(__id)
        return id == __id
    end

    local merged_request = rx.Observable.merge(
        force,
        request:filter(function(id) return not __lock[id] end)
    )

    merged_request
        :takeUntil(cancel:filter(check_id))
        :filter(check_id)
        :map(function(_, type) return request_handles[type] end)
        :compact()
        :flatMapLatest(function(f) return f(atlas) end)
        :map(function(frame, event) return frame, id, event end)
        --:subscribe(frames)

    merged_request
        :subscribe(function(id, _, lock)
            __lock[id] = lock
        end)
    return merged_request
end

function ctrl.destroy(id) cancel(id) end

function ctrl.frames() return frames end

function ctrl.events() return events end

frames:subscribe(
    function(frame, id, event)
        for eventtype, eventargs in pairs(event) do
            events(id, eventtype, eventargs)
        end
    end
)

return ctrl
