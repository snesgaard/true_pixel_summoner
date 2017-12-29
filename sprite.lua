local function __frame_lookup(image, frame, atlas)
    return atlas:frame(image, frame)
end

return function(node, atlas)
    node.atlas    = rx.BehaviorSubject.create(atlas)
    node.frame    = rx.BehaviorSubject.create(1)
    node.image    = rx.BehaviorSubject.create("")
    node.color    = rx.BehaviorSubject.create("#ffffffff")

    node.__cached_frame = rx.BehaviorSubject.create()

    node.draw
        :with(node.__cached_frame, node.color, node.atlas)
        :filter(function(_, f) return f end)
        :subscribe(
            function(_, frame, color, atlas)
                gfx.setColor(color)
                atlas:draw(frame)
            end
        )

    rx.Observable.combineLatest(
        node.image:distinctUntilChanged(),
        node.frame:distinctUntilChanged(),
        node.atlas, __frame_lookup
    )
        :subscribe(node.__cached_frame)
end
