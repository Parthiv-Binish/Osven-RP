local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('osven-spawn:server:doSpawn', function(locationId)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local location = nil
    for _, loc in ipairs(Config.SpawnLocations) do
        if loc.id == locationId then
            location = loc
            break
        end
    end

    if not location then return end
    if location.id == 'last' then
        -- Use stored last location from player data
        local lastCoords = player.PlayerData.position
        if lastCoords and lastCoords.x then
            TriggerClientEvent('osven-spawn:client:spawnPlayer', src, lastCoords)
        else
            -- Fallback to downtown
            TriggerClientEvent('osven-spawn:client:spawnPlayer', src, Config.SpawnLocations[4].coords)
        end
    else
        TriggerClientEvent('osven-spawn:client:spawnPlayer', src, location.coords)
    end
end)

-- When a player selects a character, open the spawn selector
RegisterNetEvent('qb-spawn:server:openSpawnSelector', function()
    -- Hook into qb-multicharacter's spawn flow
end)

-- Expose for other resources to trigger
exports('openSpawnSelector', function(source, data)
    TriggerClientEvent('osven-spawn:client:openSelector', source, data)
end)
