local List = require "list"

local op = {}

function op.curry(f, ...)
    local args = List.create(...)
    return function(...)
        local args = args:concat(List.create(...))
        return f(unpack(args))
    end
end

function op.equal(a, b) return a == b end

function op.identity(a) return a end

return op
