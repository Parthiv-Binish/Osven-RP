local isOpen = false

RegisterNetEvent('osven-admin:client:openMenu', function(data)
    SetNuiFocus(true, true)
    isOpen = true
    SendNUIMessage({
        type = 'OPEN_ADMIN',
        players = data.players or {},
        logs = data.logs or {},
        territories = data.territories or {},
        gangs = data.gangs or {},
    })
end)

RegisterNUICallback('admin:action', function(data, cb)
    cb({})
    if not data or not data.action then return end
    TriggerServerEvent('osven-admin:server:action', data.action, data.target, data.reason, data.amount, data.item)
end)

RegisterNUICallback('admin:territoryAction', function(data, cb)
    cb({})
    if not data or not data.action then return end
    TriggerServerEvent('osven-admin:server:territoryAction', data.action, data.zoneId, data.gang)
end)

RegisterNUICallback('admin:close', function(_, cb)
    cb({})
    SetNuiFocus(false, false)
    isOpen = false
end)

AddEventHandler('onResourceStop', function(resName)
    if GetCurrentResourceName() == resName then
        SetNuiFocus(false, false)
        isOpen = false
    end
end)

-- Toggle admin menu
RegisterCommand('admin', function()
    TriggerServerEvent('osven-admin:server:requestOpen')
end, false)

RegisterKeyMapping('admin', 'Open Admin Menu', 'keyboard', 'F8')
