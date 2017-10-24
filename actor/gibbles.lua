local gibbles = {}

function gibbles.atlas(atlas_bank)
    return atlas_bank:load("res/sword_summoner/", "res/sword_summoner/")
end

function gibbles.stats(id, gamestate)
    return {health = 40}
    --return gamestate
    --    :set("health", id, 7)
end


function gibbles.animation_control()
    local request_handles = {}
    function request_handles.idle(atlas)
        return atlas:play{"gibbles", speed = 0.75}
    end

    return request_handles
end

return gibbles
