local battle = require "battle"


love.load:subscribe(
    function()
        battle.begin(
            List.create("summoner", "undine", "gibbles", "imp"),
            List.create("wisp", "goblin", "goblin", "undine")
        )
    end,
    function() print("THEE FUUUCH") end
)
