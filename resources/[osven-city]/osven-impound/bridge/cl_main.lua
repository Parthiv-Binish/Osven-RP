local QBCore = exports['qb-core']:GetCoreObject()

-- Impound lot zone
Citizen.CreateThread(function()
    exports['ox_target']:addBoxZone({
        coords = vector3(436.73, -1008.27, 28.57),
        size = vec3(5.0, 5.0, 2.0),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'impound_lot',
                label = 'View Impounded Vehicles',
                icon = 'fa-solid fa-car',
                onSelect = function()
                    TriggerServerEvent('osven-impound:server:listVehicles')
                end,
                distance = 2.5,
                job = 'police',
            },
        },
    })

    -- Evidence locker
    exports['ox_target']:addBoxZone({
        coords = vector3(454.95, -990.98, 30.69),
        size = vec3(2.0, 2.0, 2.0),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'evidence_locker',
                label = 'Open Evidence Locker',
                icon = 'fa-solid fa-box',
                onSelect = function()
                    TriggerServerEvent('osven-impound:server:openEvidence', 'police')
                end,
                distance = 2.5,
                job = 'police',
            },
        },
    })
end)

-- Open impound menu
RegisterNetEvent('osven-impound:client:showImpoundList', function(vehicles)
    if not vehicles or #vehicles == 0 then
        QBCore.Functions.Notify('No impounded vehicles', 'error')
        return
    end

    local menuItems = { { header = 'Impounded Vehicles', isMenuHeader = true } }
    for _, v in ipairs(vehicles) do
        table.insert(menuItems, {
            header = v.plate .. ' (' .. v.vehicle .. ')',
            txt = 'Impounded: ' .. v.impoundedDate .. ' | Fee: $' .. v.impoundFee,
            params = {
                event = 'osven-impound:client:releaseVehicle',
                args = v,
            },
        })
    end
    exports['qb-menu']:openMenu(menuItems)
end)

-- Release vehicle
RegisterNetEvent('osven-impound:client:releaseVehicle', function(data)
    if not data then return end
    TriggerServerEvent('osven-impound:server:releaseVehicle', data.plate)
end)
