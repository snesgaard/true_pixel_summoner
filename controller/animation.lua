local Dictionary = require "dictionary"

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

function ctrl.create(atlas, request_handles)
    local sprite = Dictionary.create({
        request = rx.Subject.create(),
        force = rx.Subject.create(),
        cancel = rx.Subject.create(),
        events = rx.Subject.create(),
        lock = rx.BehaviorSubject.create(false),
    })

    local merged_request = rx.Observable.merge(
        sprite.force,
        sprite.request:filter(function() return not sprite.lock:getValue() end)
    )
    --[[
    local merged_request = sprite.request
        :filter(function() return not sprite.lock:getValue() end)
        :merge(force)
        :takeUntil(sprite.cancel)
        ]]--
    sprite.frames = merged_request
        :map(function(__type) return request_handles[__type] end)
        :compact()
        :distinctUntilChanged()
        :flatMapLatest(function(f) return f(atlas) end)
        --:flatMapLatest(function(f) return love.update end)

    merged_request
        :map(function(_, __lock) return __lock end)
        :subscribe(sprite.lock)

    return sprite
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
