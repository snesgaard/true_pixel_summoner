local Elector = require "controller/elector"

local function create_entry(name, action)
    return {name = name, action = action}
end

local menu = {"attack", "spells", "defend", "foo", "bar", "spam", "balls"}

local function menu_state(pos, order, items, previous)
    items = items or {}
    previous = previous or rx.Subject.create()

    local stop_drawing = rx.Subject.create()
    local stop_selection = rx.Subject.create()
    local start_selection = rx.Subject.create()

    local elector_stream = rx.Subject.create()
    --elector_stream:switch():subscribe(print)

    start_selection
        :takeUntil(stop_drawing)
        :with(elector_stream:switch())
        :map(function(_, index)
            print("restart", index)
            return Elector(#order, {up = -1, down = 1}, index)
        end)
        :subscribe(elector_stream)
        --:subscribe(function(e) print(e.election:getValue()) end)


    love.update
        :takeUntil(stop_drawing)
        :with(elector_stream:switch())
        :subscribe(
            function(dt, index)
                atelier.screen_ui:register(ui.menu.draw, pos[1], pos[2], 100, 20, order, index)
            end
        )

    start_selection()

    love.keypressed
        :filter(OP.equal("space"))
        --:subscribe(start_selection)

    love.keypressed
        :filter(OP.equal("space"))
        :take(1)
        :subscribe(
            function()
                print("the start")
                menu_state(pos:add(Vec2(100, 0)), menu, spells)
            end
        )

    love.keypressed
        :filter(OP.equal("c"))
        :subscribe(stop_selection)

    love.keypressed
        :filter(OP.equal("q"))
        :subscribe(stop_drawing)
end

love.load:subscribe(
    function()
        menu_state(Vec2(200, 200), menu, spells)
    end
)
