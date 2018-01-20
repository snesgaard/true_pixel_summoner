local Tween = require "tween"
local Event = require "animation/event"

local Player = {}
Player.__index = Player

function __get_event(parent)
    if parent then
        return parent.event
    else
        return rx.Subject.create()
    end
end

return function(node, name, time, frames, atlas, loop)
    time = time * #frames
    node.name(name)

    node.image   = rx.Subject.create()
    node.frame   = rx.Subject.create()
    node.atlas   = rx.Subject.create()
    node.event   = rx.Subject.create()
    node.current = rx.BehaviorSubject.create(1)

    node.parent
        :map(function(p) return p and p:find('../frame') or nil end)
        :subscribe(node.frame)

    node.parent
        :map(function(p) return p and p:find('../image') or nil end)
        :compact()
        :subscribe(function(i) i(name) end)

    node.parent
        :map(function(p) return p and p:find('../atlas') or nil end)
        :compact()
        :subscribe(function(a) a(atlas) end)

    frametween = loop and Tween.loop or Tween.linear
    frametween = frametween(time, node.update)

    frametween
        :step(1, #frames)
        :subscribe(
            function(f) node.current(f) end,
            print,
            function()
                node.event(Event.create("done"))
            end)
    --    :with(node.frame)
        --:tap(print)
    --    :subscribe(
            --function(f, dst) if dst then dst(f) end end,
            --print,
            --function()
        --        node.event(Event.create("done"))
        --    end
        --)
--    node.current:subscribe(print)
    node.frame
        :flatMapLatest(
            function(dst)
                return node.current
            end
        )
        :with(node.frame)
        :subscribe(
            function(f, dst)
                if dst then dst(f) end
            end
        )


    node.event
        :skipUntil(node.parent)
        :with(node.parent:map(__get_event))
        :subscribe(function(e, p) p(e) end)
end
