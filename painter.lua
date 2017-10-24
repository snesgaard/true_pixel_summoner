local list = require "list"

local painter = {}
painter.__index = painter

function painter.create()
  local state = {
    brushes = list.create(), -- Draw functions
  }
  return setmetatable(state, painter)
end


function painter:draw(order)
  order = order or function(b1, b2)
    -- Sort according to x
    return b1.x < b2.x
  end

  --self.paint_order = self.paint_order or list.range(1, #self.brush):sort(order)
  local paint_order = self.brushes:sort(order)

  for _, b in pairs(paint_order) do
      b.brush(b.x, b.y, b.r, b.sx, b.sy, unpack(b.paint))
  end
end

function painter:clear()
    self.brushes = list.create()
end

function painter:register(brush, x, y, r, sx, sy, ...)
    local data = {
        brush = brush, paint = {...}, x = x, y = y, r = r, sx = sx, sy = sy
    }
    self.brushes = self.brushes:insert(data)
end

function painter:listener()
    local me = self
    return function(...) me:register(...) end
end

return painter
