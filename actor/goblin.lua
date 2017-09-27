local goblin = {}

function goblin.atlas(atlas_bank)
    return atlas_bank:load("res/sword_summoner/", "res/sword_summoner/")
end

function goblin.stats(id, gamestate)
    return gamestate
        :set("health", id, 10)
end


function goblin.animation_control()
    local request_handles = {}
    function request_handles.idle(atlas)
        return atlas:play{"goblin"}
    end

    return request_handles
end

return goblin
