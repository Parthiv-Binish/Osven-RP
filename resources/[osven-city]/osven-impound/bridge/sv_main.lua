local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('osven-impound:server:listVehicles', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    exports['oxmysql']:execute('SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ?', {
        player.PlayerData.citizenid, 1  -- 1 = impounded
    }, function(vehicles)
        local list = {}
        for _, v in ipairs(vehicles) do
            table.insert(list, {
                plate = v.plate,
                vehicle = v.vehicle,
                impoundedDate = v.date or 'N/A',
                impoundFee = 500,
            })
        end
        TriggerClientEvent('osven-impound:client:showImpoundList', src, list)
    end)
end)

RegisterServerEvent('osven-impound:server:releaseVehicle', function(plate)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not plate then return end

    local fee = 500
    if player.PlayerData.money['cash'] < fee then
        QBCore.Functions.Notify(src, 'Insufficient funds. Fee: $' .. fee, 'error')
        return
    end

    player.Functions.RemoveMoney('cash', fee)
    exports['oxmysql']:execute('UPDATE player_vehicles SET state = ? WHERE plate = ? AND citizenid = ?', {
        0, plate, player.PlayerData.citizenid
    }, function(rows)
        if rows > 0 then
            QBCore.Functions.Notify(src, 'Vehicle released for $' .. fee, 'success')
            -- Spawn vehicle nearby
            TriggerClientEvent('qb-vehicletake:client:takeOutImpound', src, plate)
        end
    end)
end)

RegisterServerEvent('osven-impound:server:openEvidence', function(location)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    -- Use inventory stash system for evidence
    TriggerClientEvent('inventory:server:OpenInventory', src, 'stash', 'evidence_' .. location)
end)
