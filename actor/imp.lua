local imp = {}

function imp.atlas(atlas_bank)
    return atlas_bank:load("res/sword_summoner/", "res/sword_summoner/")
end

function imp.stats(id, gamestate)
    return gamestate
        :set("health", id, 7)
end


function imp.animation_control()
    local request_handles = {}
    function request_handles.idle(atlas)
        return atlas:play{"imp2"}
    end

    return request_handles
end

return imp
