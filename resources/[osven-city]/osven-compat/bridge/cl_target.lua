-- qb-target → ox_target compatibility bridge
-- Converts exports['qb-target'] calls to ox_target equivalents

local oxTarget = exports['ox_target']

-- qb-target: AddBoxZone(name, coords, w, l, { name, heading, debugPoly, minZ, maxZ }, { options, distance })
-- ox_target: AddBoxZone({ name, coords, size, rotation, debug, options })
exports('AddBoxZone', function(name, coords, w, l, opts, opts2)
    if not oxTarget then return end

    local size
    local minZ = opts.minZ
    local maxZ = opts.maxZ
    if minZ and maxZ then
        size = vector3(w, l, maxZ - minZ)
        coords = vector3(coords.x, coords.y, coords.z + (maxZ - minZ) / 2)
    else
        size = vector3(w, l, 2.0)
    end

    oxTarget:AddBoxZone({
        name = name,
        coords = coords,
        size = size,
        rotation = opts.heading or 0,
        debug = opts.debugPoly or false,
        options = opts2 and opts2.options or {},
    })
end)

-- qb-target: RemoveZone(name)
exports('RemoveZone', function(name)
    if not oxTarget then return end
    oxTarget:RemoveZone(name)
end)

-- qb-target: AddCircleZone(name, coords, radius, opts, opts2)
exports('AddCircleZone', function(name, coords, radius, opts, opts2)
    if not oxTarget then return end
    oxTarget:AddBoxZone({
        name = name,
        coords = coords,
        size = vector3(radius * 2, radius * 2, (opts and opts.maxZ or 4) - (opts and opts.minZ or 0)),
        rotation = 0,
        debug = opts and opts.debugPoly or false,
        options = opts2 and opts2.options or {},
    })
end)

-- qb-target: AddEntityZone(name, entity, opts, opts2)
exports('AddEntityZone', function(name, entity, opts, opts2)
    if not oxTarget then return end
    oxTarget:AddEntityZone(name, entity, {
        debug = opts and opts.debugPoly or false,
        options = opts2 and opts2.options or {},
    })
end)