local QBCore = exports['qb-core']:GetCoreObject()
local isOpen = false
local spawnData = {}

-- Open the spawn selector
RegisterNetEvent('osven-spawn:client:openSelector', function(data)
    spawnData = data or {}
    SetNuiFocus(true, true)
    isOpen = true
    local PlayerData = QBCore.Functions.GetPlayerData()
    local firstName = PlayerData.charinfo.firstname or spawnData.firstname or 'Citizen'
    local lastName = PlayerData.charinfo.lastname or ''
    SendNUIMessage({
        type = 'OPEN_SPAWN',
        data = {
            name = firstName .. ' ' .. lastName,
            locations = Config.SpawnLocations,
            lastLocation = spawnData.lastLocation or nil,
            lastTimestamp = spawnData.lastTimestamp or nil,
        }
    })
end)

-- NUI callbacks
RegisterNUICallback('spawn:select', function(data, cb)
    cb({})
    if not data or not data.id then return end
    SetNuiFocus(false, false)
    isOpen = false
    TriggerServerEvent('osven-spawn:server:doSpawn', data.id)
end)

RegisterNUICallback('spawn:cancel', function(_, cb)
    cb({})
    SetNuiFocus(false, false)
    isOpen = false
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resName)
    if GetCurrentResourceName() == resName then
        SetNuiFocus(false, false)
        isOpen = false
    end
end)
