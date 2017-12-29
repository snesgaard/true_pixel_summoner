local util = require "util"
local OP   = require "op"
local misc = {}

function misc.selector(thelist, keymap, initial, node)
    local size = type(thelist) == "table" and #thelist or thelist
    return node.keypressed
        :map(
            function(key)
        --        local keymap = {up = -1, down = 1}
                return keymap[key], key
            end
        )
        :filter(function(dir) return dir end)
        :flatMap(
            function(dir, key)
                local term = node.keyreleased
                    :filter(OP.equal(key))
                return util.period(0.2, node.update)
                    :takeUntil(term)
                    :map(OP.constant(dir))
                    --:startWith(dir)
            end
        )
        --:with(node.selected, node.items)
        :scan(
            function(selected, dir)
                if selected == -1 then
                    selected = dir == -1 and 1 or size
                end
                selected = selected - 1
                return (selected + dir) % size + 1
            end,
            initial or -1
        )
end

return misc
