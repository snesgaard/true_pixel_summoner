local util = require "util"
local constants = require "ui/constants"

local number = {}

function number.damage(pos, damage)
    local dy = util.span(1)
        :map(
            function(t)
                local d = 10
                return math.log(t * d + 1) / (math.log(1 + d) - math.log(1))
            end
        )
        :map(OP.mul(-50))

    local alpha = util.sine(0.1)
        :skipUntil(util.wait(0.5))
        :map(function(a) return a < 0 and 0 or 255 end)

    local function draw(x, y, alpha)
        gfx.setFont(constants.font())
        gfx.setColor(255, 50, 50, alpha)
        gfx.printf(tostring(damage), x - 5, y - 5, 10, 10, "center", "middle", 2, 2)
    end

    return util.span(1)
        :with(dy, alpha)
        :map(
            function(_, dy, alpha)
                return draw, pos[1], pos[2] + dy, alpha
            end
        )
end

return number
