local isOpen = false

RegisterNetEvent('osven-idcard:client:showCard', function(data)
    SetNuiFocus(true, true)
    isOpen = true
    SendNUIMessage({
        type = 'SHOW_ID_CARD',
        name = data.name or '',
        dob = data.dob or '',
        citizenId = data.citizenId or '',
        job = data.job or 'Citizen',
        driving = data.driving or 'NONE',
        weapon = data.weapon or 'NONE',
        photo = data.photo or '',
        presented = data.presented or false,
    })
end)

RegisterNUICallback('id:close', function(_, cb)
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

exports('showIdCard', function(data)
    TriggerEvent('osven-idcard:client:showCard', data)
end)
