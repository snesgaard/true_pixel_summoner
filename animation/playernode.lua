local Dictionary = require "dictionary"

local __do_nothing = coroutine.wrap(
    function()
        while true do coroutine.yield() end
    end
)

local function set_animation(node, name)
    local player = node.animations[name]
    if player then
        local function __do_play(dt, node) player:play(dt, node) end
        node.__current_player(coroutine.wrap(__do_play))
        node.__current_events(player.event)
        node.__current_name(name)
    else
        node.__current_player(__do_nothing)
        node.__current_events(rx.Observable.never)
        node.__current_name("")
    end
end

return function(node, animations)
    node.animations        = animations or Dictionary.create()
    node.loop              = Dictionary.create()
    node.default_animation = rx.BehaviorSubject.create("")
    --node.set_animation     = rx.Subject.create()

    node.__current_player  = rx.BehaviorSubject.create()
    node.__current_events  = rx.Subject.create()
    node.__current_name    = rx.BehaviorSubject.create()
    node.events            = node.__current_events:switch()

    node.set_animation = set_animation

    node.update
        :with(node.__current_player)
        :filter(function(_, p) return p end)
        :subscribe(function(dt, player) player(dt, node) end)

    node.events
        :filter(OP.equal("done"))
        :with(node.__current_name, node.default_animation)
        :map(
            function(name, default)
                if node.loop[name] then
                    return node, name
                else
                    return node, default
                end
            end
        )
        :subscribe(node.set_animation)

end
