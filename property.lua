local Dictionary = require "dictionary"

local function generic_loader()
    return
end

local Property = {}
Property.__index = Property

function Property.__tostring(p)
    local str = "Properties:"
    for type, data in pairs(p.__data) do
        str = str .. "  " .. type .. ": " .. data:__tostring() .. ","
    end
    return str
end

function Property:create(type, id, value)
    local next = setmetatable({__data = Dictionary.create()}, Property)
    if self == nil then return next end
    -- Shallow copy of un-mutated state
    next.__data = Dictionary.create(self.__data)
    next.__data[type] = Dictionary.create(next.__data[type])
    next.__data[type][id] = value
    return next
end

function Property:set(type, id, value)
    return self:create(type, id, value)
end

function Property:get(type, id)
    local d = self.__data[type]
    if not d then return end
    if not id then return d end
    return d[id]
end

function Property:map(type, id, f)
    local d = next.__data[type]
    if not d then return end

    local value = f(d[id])
    return self:create(type, id, value)
end

function Property:mutate(__type, id, f)
    local d = self.__data[__type] or Dictionary.create()

    local prev = d[id]
    local val = type(f) == "function" and f(prev) or f

    d[id] = val
    self.__data[__type] = d
    return self
end

return Property
