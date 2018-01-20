local marker = require "test/battle/marker"
local Misc   = require "pileomisc"
local Node   = require "node"
local INode  = require "interaction_node"
--local Act    = require "interaction_node"


return function(node, targets, keymap, initial)
    INode(node)

    node.marker     = Node.create(marker)
    node.targets    = targets

    node.candidate = rx.BehaviorSubject.create(1)

    node.marker.position(Vec2(0, -50))

    node.candidate
        :subscribe(
            function(i)
                local target_node = targets[i]
                if target_node then
                    node.marker.parent(target_node)
                    node.marker.animate()
                else
                    node.marker.parent()
                end
            end
        )

    node.parent
        :filter(function(p) return p == nil end)
        :map(function() return -1 end)
        :subscribe(node.candidate)


    node.revive
        :with(node.candidate)
        :flatMapLatest(
            function(_, i)
                i = i or -1
                return Misc.selector(targets, {left = -1, right = 1}, i, node)
                    :takeUntil(node.dormant)
            end
        )
        :subscribe(node.candidate)

    node.revive
        :flatMapLatest(
            function()
                return node.keypressed:takeUntil(node.dormant)
            end
        )
        :filter(OP.equal("space"))
        :with(node.candidate)
        :map(function(_, c) return c end)
        :compact()
        :map(function(i) return targets[i], i end)
        :subscribe(node.publish)

    node.revive
        :flatMapLatest(
            function()
                return node.keypressed:takeUntil(node.dormant)
            end
        )
        :filter(OP.equal("escape"))
        :subscribe(node.reject)

    node.revive()
end
