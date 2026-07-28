local QBCore = exports['qb-core']:GetCoreObject()
local adminLogs = {}

-- Admin action handler
RegisterServerEvent('osven-admin:server:action', function(action, target, reason, amount, item)
    local src = source
    local admin = QBCore.Functions.GetPlayer(src)
    if not admin then return end
    if not IsPlayerAceAllowed(tostring(src), 'command') then return end

    local logEntry = function(aType, aAction, detail)
        table.insert(adminLogs, {
            id = #adminLogs + 1,
            timestamp = os.date('%H:%M:%S'),
            actionType = aType,
            action = aAction,
            detail = detail .. ' (by ' .. admin.PlayerData.charinfo.firstname .. ' ' .. admin.PlayerData.charinfo.lastname .. ')',
        })
        if #adminLogs > 100 then table.remove(adminLogs, 1) end
    end

    if action == 'tpTo' and target then
        local targetPed = GetPlayerPed(tonumber(target))
        local coords = GetEntityCoords(targetPed)
        TriggerClientEvent('osven-admin:client:teleport', src, coords)
        logEntry('tp', 'TP', 'Teleported to player ' .. target)
    elseif action == 'spectate' and target then
        TriggerClientEvent('osven-admin:client:spectate', src, tonumber(target))
        logEntry('spectate', 'SPECTATE', 'Spectating player ' .. target)
    elseif action == 'freeze' and target then
        TriggerClientEvent('osven-admin:client:toggleFreeze', tonumber(target))
        logEntry('freeze', 'FREEZE', 'Toggled freeze on player ' .. target)
    elseif action == 'revive' and target then
        TriggerClientEvent('hospital:client:Revive', tonumber(target))
        logEntry('revive', 'REVIVE', 'Revived player ' .. target)
    elseif action == 'kick' and target and reason and reason ~= '' then
        DropPlayer(tonumber(target), 'Kicked by staff: ' .. reason)
        logEntry('kick', 'KICK', 'Kicked player ' .. target .. ' (' .. reason .. ')')
    elseif action == 'ban' and target and reason and reason ~= '' then
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(target))
        if targetPlayer then
            local license = targetPlayer.PlayerData.license
            exports['oxmysql']:execute('INSERT INTO bans (name, license, reason, banner, time) VALUES (?, ?, ?, ?, ?)',
                { targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname, license, reason, admin.PlayerData.charinfo.firstname .. ' ' .. admin.PlayerData.charinfo.lastname, os.time() * 1000 })
            DropPlayer(tonumber(target), 'Banned: ' .. reason)
            logEntry('ban', 'BAN', 'Banned player ' .. target .. ' (' .. reason .. ')')
        end
    elseif action == 'giveMoney' and target and amount and amount > 0 then
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(target))
        if targetPlayer then
            targetPlayer.Functions.AddMoney('cash', amount)
            logEntry('giveMoney', 'GIVE $', 'Gave $' .. amount .. ' to player ' .. target)
        end
    elseif action == 'giveItem' and target and item and item ~= '' then
        local targetPlayer = QBCore.Functions.GetPlayer(tonumber(target))
        if targetPlayer then
            targetPlayer.Functions.AddItem(item, 1)
            TriggerClientEvent('inventory:client:ItemBox', tonumber(target), QBCore.Shared.Items[item], 'add')
            logEntry('giveItem', 'GIVE ITEM', 'Gave ' .. item .. ' to player ' .. target)
        end
    elseif action == 'weather' then
        TriggerClientEvent('osven-admin:client:setWeather', -1, target)
        logEntry('weather', 'WEATHER', 'Set weather to ' .. target)
    elseif action == 'setTime' then
        local parts = {}
        for p in string.gmatch(target or '', '([^:]+)') do table.insert(parts, tonumber(p)) end
        if #parts == 2 then
            TriggerClientEvent('osven-admin:client:setTime', -1, parts[1], parts[2])
            logEntry('time', 'TIME', 'Set time to ' .. parts[1] .. ':' .. string.format('%02d', parts[2]))
        end
    elseif action == 'freezeTime' then
        TriggerClientEvent('osven-admin:client:freezeTime', -1)
        logEntry('time', 'TIME', 'Toggled time freeze')
    elseif action == 'spawnVehicle' and target and target ~= '' then
        TriggerClientEvent('osven-admin:client:spawnVehicle', src, target)
        logEntry('vehicle', 'VEHICLE', 'Spawned ' .. target)
    elseif action == 'announce' and target and target ~= '' then
        TriggerClientEvent('osven-hud:client:adminBroadcast', -1, target)
        logEntry('announce', 'ANNOUNCE', 'Sent announcement: ' .. target)
    end
end)

-- Request open admin menu
RegisterServerEvent('osven-admin:server:requestOpen', function()
    local src = source
    if not IsPlayerAceAllowed(tostring(src), 'command') then return end

    local players = {}
    local qbPlayers = QBCore.Functions.GetPlayers()
    for _, id in ipairs(qbPlayers) do
        local p = QBCore.Functions.GetPlayer(id)
        if p then
            table.insert(players, {
                id = #players + 1,
                name = p.PlayerData.charinfo.firstname .. ' ' .. p.PlayerData.charinfo.lastname,
                serverId = id,
            })
        end
    end

    -- Get territory data for admin panel
    local territories = {}
    if exports['osven-gangs'] then
        local gangTerritories = exports['osven-gangs']:GetAllTerritories()
        if gangTerritories then
            for zoneId, data in pairs(gangTerritories) do
                table.insert(territories, {
                    id = zoneId,
                    label = data.label,
                    nativeGang = data.gang,
                    owner = data.owner or 'none',
                })
            end
        end
    end

    TriggerClientEvent('osven-admin:client:openMenu', src, {
        players = players,
        logs = adminLogs,
        territories = territories,
    })
end)

-- Territory admin actions from panel
RegisterServerEvent('osven-admin:server:territoryAction', function(action, zoneId, gang)
    local src = source
    if not IsPlayerAceAllowed(tostring(src), 'command') then return end

    if action == 'setOwner' and zoneId and gang then
        exports['osven-gangs']:SetTerritoryOwner(zoneId, gang)
        TriggerClientEvent('QBCore:Notify', src, 'Territory updated: ' .. zoneId .. ' → ' .. gang, 'success')
    elseif action == 'resetAll' then
        exports['osven-gangs']:ResetAllTerritories()
        TriggerClientEvent('QBCore:Notify', src, 'All territories reset', 'success')
    end
end)
