local QBCore = exports['qb-core']:GetCoreObject()
local downedCooldown = {}

-- Player downed notification
RegisterServerEvent('osven-medical:server:playerDowned', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local now = os.time()
    if downedCooldown[src] and now - downedCooldown[src] < 10 then return end
    downedCooldown[src] = now

    local players = QBCore.Functions.GetPlayers()
    for _, targetId in ipairs(players) do
        local target = QBCore.Functions.GetPlayer(targetId)
        if target and target.PlayerData.job.name == 'ambulance' and target.PlayerData.job.onduty then
            TriggerClientEvent('osven-medical:client:emsAlert', targetId, {
                patient = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                coords = GetEntityCoords(GetPlayerPed(src)),
            })
        end
    end
end)

-- Revive command (EMS/admin)
RegisterCommand('revive', function(source, args)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local isEMS = player.PlayerData.job.name == 'ambulance'
    local isAdmin = IsPlayerAceAllowed(tostring(src), 'command')

    if not isEMS and not isAdmin then
        TriggerClientEvent('QBCore:Notify', src, 'No permission', 'error')
        return
    end

    local target = src
    if args[1] then
        target = tonumber(args[1])
    end
    if not target then return end

    TriggerClientEvent('osven-medical:client:revive', target)
    TriggerClientEvent('QBCore:Notify', target, 'You have been revived', 'success')
end, false)

RegisterKeyMapping('revive', 'Revive self (EMS/Admin)', 'keyboard', '')

-- Heal command (admin)
RegisterCommand('heal', function(source, args)
    local src = source
    if not IsPlayerAceAllowed(tostring(src), 'command') then return end

    local target = src
    if args[1] then
        target = tonumber(args[1])
    end
    if not target then return end

    TriggerClientEvent('osven-medical:client:revive', target)
    TriggerClientEvent('QBCore:Notify', target, 'You have been healed', 'success')
end, false)
