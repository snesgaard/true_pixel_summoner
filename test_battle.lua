local battle = require "battle"

love.load:subscribe(
    function()
        battle.begin(List.create("summoner"), List.create("wisp"))
    end
)
