local util   = require "util"
local Node   = require "node"
local Atlas  = require "atlas"
local Sprite = require "sprite"
local Tween  = require "tween"
local Misc   = require "pileomisc"


love.draw = rx.Subject.create()

local function load_test()
    local atlas = Atlas.create('res/sword_summoner/')
    local node = Node.create()
    node:set_update(love)
    node:set_draw(love)
    node:set_input(love)
    --node.scale(Vec2(2, 2))

    local sprite = Node.create(Sprite.setup, atlas)
    sprite:set_update(node)
    sprite:set_draw(node)
    --sprite.play("gibbles")
    --sprite.position(Vec2(100, 100))

    local stats_ui = Node.create(ui.health.setup)
    stats_ui:set_update(sprite)
    stats_ui:set_draw(sprite)
    stats_ui.position(Vec2(200, 100))
    stats_ui.damage(2)

    local items = {"foo", "bar", "spam", "foo", "bar", "spam"}
    local menu = Node.create(ui.menu, items)
    menu:set_update(node)
    menu:set_draw(node)
    menu:set_input(node)
    menu.position(Vec2(500, 200))

    local scroll = Node.create(ui.scroll, 200)
    scroll:set_update(node)
    scroll:set_draw(node)
    scroll:set_input(node)
    scroll.position(Vec2(200, 500))
end

local function select_test()
    local function link_nodes(to, from)
        from = from or {}
        to:set_update(from)
        to:set_draw(from)
        to:set_input(from)
        --to:set_transform(from)
    end
    local root = Node.create()
    root:set_update(love)
    root:set_draw(love)
    root:set_input(love)

    local function create_box_node()
        local function __setup(node)
            node.draw:subscribe(function()
                local s = 40
                gfx.setColor(50, 200, 50)
                gfx.rectangle("fill", -s, -s, s + s, s + s)
            end)
        end
        local box_node = Node.create(__setup)
        box_node:set_update(root)
        box_node:set_draw(root)
        box_node:set_input(root)
        return box_node
    end
    local box_nodes = List.create()
    for i = 1,5 do
        local b = create_box_node()
        b.position(Vec2(i * 150, 200))
        box_nodes = box_nodes:insert(b)
    end

    local function create_marker()
        local function __setup(node)
            node.__angle = rx.BehaviorSubject.create(0)
            node.__scale = rx.BehaviorSubject.create(1)
            node.animate = rx.Subject.create()

            node.animate
                :flatMapLatest(
                function()
    --                print("what!")
                    return Tween.log(0.3, node.update)
                end
                )
                :map(function(t) return math.pi * (1 - t) end)
                :subscribe(node.__angle)
            node.animate
                :map(OP.constant(1))
                :subscribe(node.__scale)

            node.animate
                :flatMapLatest(
                    function()
                        return Tween.sine(1.5, -0.25, node.update)
                    end
                )
                :map(
                    function(v)
                        v = 0.5 * v + 0.5
                        return 0.25 * v + 1.0
                    end
                )
                --:tap(print)
                :subscribe(node.__scale)


            node.draw
                :with(node.__angle, node.__scale)
                :subscribe(function(_, a, scale)
                    local s  = 8 * scale
                    local s2 = s * math.sqrt(2)
                    gfx.setLineWidth(3)

                    gfx.push()
                    gfx.rotate(-a + math.pi * 0.25)
                    gfx.setColor(200, 50, 50, 100)
                    gfx.rectangle("fill", -s2, -s2, s2 + s2, s2 + s2, 1)
                    gfx.setColor(200, 50, 50)
                    gfx.rectangle("line", -s2, -s2, s2 + s2, s2 + s2, 1)
                    gfx.pop()

                    gfx.push()
                    gfx.rotate(a)
                    gfx.setColor(200, 50, 50, 100)
                    gfx.rectangle("fill", -s, -s, s + s, s + s, 1)
                    gfx.setColor(200, 50, 50)
                    gfx.rectangle("line", -s, -s, s + s, s + s, 1)
                    gfx.pop()
                end)

        end
        local marker_node = Node.create(__setup)
        return marker_node
    end
    local marker = create_marker()
    --link_nodes(marker, box_nodes[1])

    local selector = Misc.selector(box_nodes, {left = -1, right = 1}, root)
    selector
        :subscribe(
            function(index)
                local bn = box_nodes[index]
                marker.animate()
                link_nodes(marker, bn)
            end
        )

    root.keypressed
        :filter(OP.equal("space"))
        :subscribe(function() link_nodes(marker) end)

    root.keypressed
        :filter(OP.equal("space"))
        :with(selector)
        :subscribe(
            function(_, index)
                for _, bn in ipairs(box_nodes:erase(index)) do
                    link_nodes(bn)
                end
                print("done")
            end
        )

    local focus_subject = root.keypressed
        :filter(OP.equal("space"))
        :with(
            root.position,
            selector
                :flatMapLatest(
                    function(index)
                        local bn = box_nodes[index]
                        return bn.position
                    end
                )
        )
        :map(
            function(_, from, to)
                to = to:dot(-1):add(Vec2(800, 450))
                return _, from, to
            end
        )



    local unfocus_subject = root.keypressed
        :filter(OP.equal("a"))
        :with(root.position, rx.BehaviorSubject.create(Vec2(0, 0)))

    unfocus_subject
        :subscribe(
                function()
                    for _, bn in pairs(box_nodes) do
                        link_nodes(bn, root)
                    end
                end
        )

    rx.Observable.merge(focus_subject, unfocus_subject)
        :flatMapLatest(
            function(_, from, to)
                return Tween.curve(0.5, root.update)
                    :map(
                        function(t)
                            return Vec2.add(from:dot(1 - t), to:dot(t))
                        end
                    )
                    --:map(function(v) return v:dot(-1) end)
            end
        )
        :subscribe(root.position)

    Tween.curve(1)
        :subscribe(print)
end

love.load:subscribe(select_test)
