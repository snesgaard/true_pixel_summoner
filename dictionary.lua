require "math"
local list = require "list"

local dictionary = {}
dictionary.__index = dictionary

function dictionary.__tostring(d)
  local l = {}
  for key, val in pairs(d) do
    l[#l + 1] = tostring(key) .. ": " .. tostring(val)
  end
  if #l == 0 then return "{}" end
  local s = "{"
  for i = 1, #l - 1 do
    s = s .. tostring(l[i]) .. ", "
  end
  s = s .. tostring(l[#l]) .. "}"
  return s
end

function dictionary.create(d)
  local data = {}
  for key, val in pairs(d or {}) do
    data[key] = val
  end
  return setmetatable(data, dictionary)
end

function dictionary.from_keyvalue(keys, values)
    local data = {}
    for _, keyval in pairs(list.zip(keys, values)) do
        local k, v = unpack(keyval)
        data[k] = v
    end
    return setmetatable(data, dictionary)
end

function dictionary:filter(f)
  local ret = dictionary.create()
  for key, val in pairs(self) do
    ret[key] = f(val) and val or nil
  end
  return ret
end

function dictionary:map(f)
  local ret = dictionary.create()
  for key, val in pairs(self) do
    ret[key] = f(val)
  end
  return ret
end

function dictionary:set(key, val)
  local ret = dictionary.create(self)
  ret[key] = val
  return ret
end

function dictionary:erase(key)
  return self:set(key, nil)
end

function dictionary:tolist()
  local ret = list.create()
  for _, val in pairs(self) do
    ret[#ret + 1] = val
  end
  return ret
end

return dictionary
