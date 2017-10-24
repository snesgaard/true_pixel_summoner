local OP = require "op"
local util = require "util"

local ElectorMaster = {}
ElectorMaster.__index = ElectorMaster


local Elector = {}
Elector.__index = Elector

function Elector.__tostring(e)
    return string.format("Elector[%i]", e.election:getValue())
end

function ElectorMaster:__call(the_list, keymap, initial_selection)
    print("create", initial_selection)
    local the_size = type(the_list) == "table" and #the_list or the_list
    local elector = love.keypressed
        :map(function(key) return key, keymap[key] end)
        :filter(function(k, dir) return dir end)
        :flatMap(
            function(key, dir)
                local end_stream = love.keyreleased
                    :filter(OP.curry(OP.equal, key))
                return util.period(0.35)
                    :takeUntil(end_stream)
                    :map(OP.constant(dir))
                    --:tap(print)
                    --:takeUntil(end_stream)
                    --:map(OP.constant(dir))
                --    :map(function() return 1 end)
            end
        )
        :scan(
            function(current, dir)
                if current == -1 then
                    return dir == 1 and 0 or the_size - 1
                else
                    return (current + dir) % the_size
                end
            end,
            (initial_selection or 0) - 1
        )
        :map(OP.add(1))
    return elector
end

setmetatable(ElectorMaster, ElectorMaster)
return ElectorMaster
