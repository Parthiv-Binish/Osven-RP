local isOpen = false

RegisterNetEvent('osven-charcreator:client:openCreator', function(data)
    SetNuiFocus(true, true)
    isOpen = true
    SendNUIMessage({ type = 'OPEN_CHARACTER_CREATOR' })
end)

RegisterNUICallback('char:confirm', function(data, cb)
    cb({})
    SetNuiFocus(false, false)
    isOpen = false
    TriggerServerEvent('osven-charcreator:server:createCharacter', data)
end)

AddEventHandler('onResourceStop', function(resName)
    if GetCurrentResourceName() == resName then
        SetNuiFocus(false, false)
        isOpen = false
    end
end)
