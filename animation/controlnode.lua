local Node = require "node"

local NULL = {}

return function(node, atlas)
    node.__player      = rx.BehaviorSubject.create(NULL)
    node.__animations  = atlas:animations()

    node.event         = rx.Subject.create()
    node.set_animation = rx.Subject.create()

    -- Remove previous player
    node.__player:window(2)
        :filter(function(p) return p ~= NULL end)
        :subscribe(function(p) p.parent() end)

    node.__player
        :filter(function(p) return p ~= NULL end)
        :subscribe(function(p) p.parent(node) end)

    local function lookup_animation(name, loop)
        if not name then return NULL end
        local setup = node.__animations[name]
        if not setup then
            return NULL
        else
            return Node.create(setup, loop)
        end
    end

    node.set_animation
        :map(lookup_animation)
        :subscribe(node.__player)
end
