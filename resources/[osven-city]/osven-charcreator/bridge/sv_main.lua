local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('osven-charcreator:server:createCharacter', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    -- Validation
    if not data or not data.firstName or not data.lastName or not data.gender or not data.dob then
        TriggerClientEvent('QBCore:Notify', src, 'Missing required fields', 'error')
        return
    end

    if string.len(data.firstName) < 2 or string.len(data.lastName) < 2 then
        TriggerClientEvent('QBCore:Notify', src, 'Name must be at least 2 characters', 'error')
        return
    end

    if data.backstory and string.len(data.backstory) > 500 then
        TriggerClientEvent('QBCore:Notify', src, 'Backstory too long (max 500)', 'error')
        return
    end

    -- Update player data via QBCore
    local charInfo = player.PlayerData.charinfo
    charInfo.firstname = data.firstName
    charInfo.lastname = data.lastName
    charInfo.gender = data.gender == 'male' and 0 or 1
    charInfo.backstory = data.backstory or ''
    charInfo.dateofbirth = data.dob

    player.Functions.SetPlayerData('charinfo', charInfo)
    player.Functions.Save()

    -- Notify all systems of the updated character data in real-time
    local fullName = data.firstName .. ' ' .. data.lastName
    TriggerClientEvent('osven:client:updateCharacterName', src, fullName)
    TriggerEvent('npwd:setPlayerName', src, fullName)
    exports['osven-logging']:sendLog('admin', ('Character Created: %s'):format(fullName), ('%s created by %s'):format(fullName, GetPlayerName(src)), 'info')

    -- Spawn player at default location
    TriggerClientEvent('osven-spawn:client:spawnPlayer', src, Config.SpawnLocations[4].coords)
end)
