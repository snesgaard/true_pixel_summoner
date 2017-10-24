local List = require "list"
local Dictionary = require "dictionary"

local Database = {}
Database.__index = Database

function Database.__tostring(d)
    local columns = {}
    for id, row in pairs(d.rows) do
        for key, val in pairs(row) do
            columns[key] = 1
        end
    end

    local max_size = 15
    local name = d.name or ''
    local str = name .. '\n' .. string.pad('ID', max_size, "back")
    for key, _ in pairs(columns) do
        str = str .. tostring(key):pad(max_size, "back"):upper()
    end
    str = str .. '\n'
    for id, row in pairs(d.rows) do
        str = str .. tostring(id):pad(max_size, "back")
        for key, _ in pairs(columns) do
            local val = row[key]
            local s = val ~= nil and tostring(val) or '-'
            str = str .. s:pad(max_size, "back")
        end
        str = str .. '\n'
    end
    return str
end

function Database.create(name)
    local this = {rows = Dictionary.create(), name = name}
    return setmetatable(this, Database)
end

function Database:clone()
    local __next = Database.create(self.name)
    __next.rows = Dictionary.create(self.rows)
    return __next
end

function Database:select(...)
    local columns = {...}
    local __next = Database.create()
    for id, row in pairs(self.rows) do
        local __next_row = Dictionary.create()
        for _, c in pairs(columns) do __next_row[c] = row[c] end
        __next.rows[id] = __next_row
    end
    return __next
end

function Database:filter(f)
    local __next = Database.create()--self:clone()
    for id, row in pairs(self.rows) do
        if f(id, row) then __next.rows[id] = row end
    end
    return __next
end

function Database:insert(id, row)
    local __next = self:clone()
    __next.rows[id] = Dictionary.create(row)
    return __next
end

function Database:erase(id)
    local __next = self:clone()
    __next.rows[id] = nil
    return __next
end

function Database:write(id, key, val)
    local __next = self:clone()
    __next.rows[id] = Dictionary.create(__next.rows[id])
    __next.rows[id][key] = val
    return __next
end

function Database:read(id, key)
    return __next.rows[id][key]
end

function Database:stack(other)
    local __next = self:clone()

    for id, row in pairs(other) do
        __next.rows[id] = row
    end
    return __next
end

function Database:map(f)
    local __next = self:clone()
    for id, row in pairs(self.rows) do
        local __next_row = f(id, Dictionary.create(row))
        __next.rows[id] = __next_row
    end
    return __next
end

function Database:impose(other)
    local __next = self:clone()

    for id, row in pairs(other.rows) do
        local __prev = __next.rows[id]
        if not __prev then
            __next.rows[id] = row
        else
            __prev = Dictionary.create(__prev)
            for key, val in pairs(row) do
                __prev[key] = val
            end
            __next.rows[id] = __prev
        end
    end
    return __next
end

function Database:fill(other)
    return other:impose(self)
end

return Database
