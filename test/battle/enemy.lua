local enemy = {}

function enemy.visual(node)
    local function __do_draw()
        gfx.setColor(200, 50, 50)
        local w, h = 25, 100
        gfx.rectangle("fill", -w, -h, w + w, h)
    end

    node.draw:subscribe(__do_draw)

    node.name("visual")
end

return enemy
