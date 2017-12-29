local Tween = require "tween"

local function find_movement(attacker, defender)
    local from = attacker.world_position:getValue()
    local to   = defender.world_position:getValue()
    return to:sub(from):add(Vec2(0, 100))
end

local function __do_attack(node, attacker, defender)
    Tween.curve(0.35, node.update)
        :map()
end

local function __move_towards(node, attacker, defender)
    local move = find_movement(attacker, defender)
    Tween.curve(0.35, node.update)
        :map(function(t) return move:dot(t) end)
        :subscribe(
            function(v) attacker:find("visual").position(v) end,
            nil,
            function() __do_attack(node, attacker, defender) end
        )
end

return function(node, attacker, defender)



end
