local ResourceManager = require "resource_manager"

local spatial = {}
spatial.__index = spatial



function spatial.create()
    local function loader(id, x, y, sx)
        return {
            x = rx.BehaviorSubject.create(),
            y = rx.BehaviorSubject.create(),
            sx = rx.BehaviorSubject.create(),
            wooble = {
                x = rx.BehaviorSubject.create(),
                y = rx.BehaviorSubject.create()
            }
        }
    end
    local this = {
        __data = ResourceManager.create(loader)
    }
    return setmetatable(this, spatial)
end

function spatial:set_position(id, x, y)
    local d = self.__data:fetch(id)
    d.x(x)
    d.y(y)
end

function spatial:set_face(id, sx)
    local d = self.__data:fetch(id)
    d.face(sx)
end

function spatial:get_position(id)
    return self.__data:fetch(id)
end

function spatial:wooble()

end

return spatial
