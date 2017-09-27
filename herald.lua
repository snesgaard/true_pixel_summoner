local Dictionary = require "dictionary"

local Herald = {}
Herald.__index = Herald

function Herald.__tostring(h)
    return h.__carriers
        :map(
            function(carrier)
                return carrier:map(
                    function(b)
                        return b:getValue()
                    end
                )
            end
        ):__tostring()
end

function Herald.create()
    local self = {
        __carriers = Dictionary.create()
    }
    return setmetatable(self, Herald)
end

function Herald:carrier(__type, __id, ...)
    local c = self.__carriers[__type]
    if not c then
        c = Dictionary.create()
        self.__carriers[__type] = c
    end
    if not __id then return c end
    local h = c[__id]
    if not h then
        h = rx.BehaviorSubject.create(...)
        c[__id] = h
    end
    return h
end

function Herald:destory(__type, __id)

end


return Herald
