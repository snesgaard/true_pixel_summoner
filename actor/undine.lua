local undine = {}

function undine.atlas(atlas_bank)
    return atlas_bank:load("res/sword_summoner/", "res/sword_summoner/")
end

function undine.stats(id, gamestate)
    return {health = 12}
    --return gamestate
    --    :set("health", id, 12)
end


function undine.animation_control()
    local request_handles = {}
    function request_handles.idle(atlas)
        return atlas:play{"undine"}
    end
    function request_handles.chant(atlas)
        return atlas:play{"undine_cast", from = 1, to = 3}
    end

    function request_handles.cast(atlas)
        return atlas:play{"undine_cast", from = 4, to = 6, speed = 1.5}
    end

    return request_handles
end

return undine
