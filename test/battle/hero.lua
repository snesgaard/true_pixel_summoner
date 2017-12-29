local hero = {}

function hero.visual(node)
    node.color = rx.BehaviorSubject.create({100, 100, 200})

    local function __do_draw(_, c)
        gfx.setColor(unpack(c))
        local w, h = 25, 100
        gfx.rectangle("fill", -w, -h, w + w, h)
    end

    node.draw
        :with(node.color)
        :subscribe(__do_draw)

    node.name("visual")
end

return hero
