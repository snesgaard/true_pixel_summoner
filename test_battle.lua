local battle = require "battle"

love.load:subscribe(
    function()
        battle.begin(
            List.create("summoner", "imp", "goblin", "wisp"),
            List.create("wisp", "goblin", "goblin", "undine")
        )
    end
)
