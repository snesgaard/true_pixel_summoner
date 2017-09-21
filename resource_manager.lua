local OP = require "op"
local list = require "list"
local dictionary = require "dictionary"

local resource_manager = {}
resource_manager.__index = resource_manager

function resource_manager:__tostring()
    local str = "Resource Manager with data = " .. self.__data:__tostring()
    return str
end

function resource_manager.create(loader, pedantic)
  local state = {
    __predantic = pedantic,
    __loader = loader or OP.identity,
    __data = dictionary.create()
  }
  return setmetatable(state, resource_manager)
end

function resource_manager:load(name, ...)
  if not self.__data[name] then
      self.__data[name] = self.__loader(...)
  end
  return self.__data[name]
end

function resource_manager:fetch(name)
  local d = self.__data[name]
  if self.__pedantic and d == nil then
    error(string.format("%s was not found!", name))
  end
  return d
end

function resource_manager:clear()
  self.__data = dictionary.create()
  return self
end

function resource_manager:unload(name)
  self.__data[name] = nil
  return self
end

return resource_manager
