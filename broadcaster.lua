local Dictionary = require "dictionary"

local Broadcaster = {}
Broadcaster.__index = Broadcaster

function Broadcaster.__tostring(d)
    local columns = {}
    for id, row in pairs(d.rows) do
        for key, val in pairs(row) do
            columns[key] = 1
        end
    end

    local max_size = 15
    local name = d.name or 'Generic Broadcaster'
    local str = name .. '\n' .. string.pad('ID', max_size, "back")
    for key, _ in pairs(columns) do
        str = str .. tostring(key):pad(max_size, "back"):upper()
    end
    str = str .. '\n'
    for id, row in pairs(d.rows) do
        str = str .. tostring(id):pad(max_size, "back")
        for key, _ in pairs(columns) do
            local val = row[key]
            local s = val ~= nil and tostring(val:getValue()) or '-'
            str = str .. s:pad(max_size, "back")
        end
        str = str .. '\n'
    end
    return str
end


function Broadcaster.create()
    return setmetatable({rows = {}}, Broadcaster)
end

local function create_channel()
    return rx.BehaviorSubject.create()
end

function Broadcaster:step(database)
    for id, data_row in pairs(database.rows) do
        local broad_row = self.rows[id] or Dictionary.create()

        for attribute, value in pairs(data_row) do
            local att = broad_row[attribute] or create_channel()
            att(value)
            broad_row[attribute] = att
        end

        self.rows[id] = broad_row
    end
    return self
end

function Broadcaster:channel(id, attribute)
    local row = self.rows[id]
    if not row then
        print(id, attribute)
        row = Dictionary.create()
        self.rows[id] = row
    end
    local att = row[attribute]
    if not att then
        att = create_channel()
        row[attribute] = att
    end
    return att
end

local function get_values(row)
    return Dictionary.create(row):map(function(t) return t:getValue() end)
end

function Broadcaster:map(f)
    for id, row in pairs(self.rows) do
        local __next_row = f(id, get_values(row)) or {}
        for att, val in pairs(__next_row) do
            self:channel(id, att):onNext(val)
        end
    end
    return self
end

function Broadcaster:filter(f)
    local __next = Broadcaster.create()
    for id, row in pairs(self.rows) do
        if f(id, get_values(row)) then
            __next.rows[id] = Row
        end
    end
    return __next
end

function Broadcaster:select(...)
    local columns = {...}
    local __next = Broadcaster.create()

    for id, row in pairs(self.rows) do
        local __next_row = Dictionary.create()
        for _, c in pairs(columns) do
            __next_row[c] = row[c]
        end
        __next.rows[i] = __next_row
    end
    return __next
end


return Broadcaster
