local List = require "list"

local op = {}

function op.curry(f, ...)
    local args = List.create(...)
    return function(...)
        local args = args:concat(List.create(...))
        return f(unpack(args))
    end
end

function op.lookup(map)
    return function(key) return map[key] end
end

function op.mul(a, b)
    if not b then
        return function(c) return op.mul(a, c) end
    else
        return a * b
    end
end

function op.add(a, b)
    if not b then
        return function(c) return a + c end
    else
        return a + b
    end
end

function op.equal(a, b)
    if b == nil then
        return function(c) return a == c end
    else
        return a == b
    end
end

function op.identity(a) return a end

function op.constant(a) return function() return a end end

return op
