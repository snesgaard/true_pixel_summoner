local summoner = {}

function summoner.atlas(atlas_bank)
    atlas_bank:load("res/sword_summoner/", "res/sword_summoner/")
end

function summoner.animation_control()
    local request_handles = {}
    function request_handles.idle(atlas)
        return atlas:play{"idle"}
    end
    function request_handles.chant(atlas)
        return atlas:play{"cast", from = 2, to = 3}
    end
    function request_handles.cast(atlas)
        return atlas:play{"cast", from = 4, to = 5, speed = 1.5}
    end
    function request_handles.attack(atlas)
        return atlas:play{"attack", from = 2, loop = "once"}
    end

    return request_handles
end

return summoner
