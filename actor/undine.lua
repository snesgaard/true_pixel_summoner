local undine = {}

function undine.atlas(atlas_bank)
    return atlas_bank:load("res/sword_summoner/", "res/sword_summoner/")
end

function undine.stats(id, gamestate)
    return gamestate
        :set("health", id, 12)
end


function undine.animation_control()
    local request_handles = {}
    function request_handles.idle(atlas)
        return atlas:play{"undine"}
    end

    return request_handles
end

return undine
