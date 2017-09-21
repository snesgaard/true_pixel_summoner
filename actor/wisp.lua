local wisp = {}

function wisp.atlas(atlas_bank)
    return atlas_bank:load("res/sword_summoner/", "res/sword_summoner/")
end

function wisp.animation_control()
    local request_handles = {}
    function request_handles.idle(atlas)
        return atlas:play{"wisp"}
    end

    return request_handles
end

return wisp
