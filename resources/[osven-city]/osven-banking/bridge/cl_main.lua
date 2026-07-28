local isOpen = false

RegisterNetEvent('osven-banking:client:openBranch', function(data)
    SetNuiFocus(true, true)
    isOpen = true
    SendNUIMessage({
        type = 'OPEN_BANKING',
        mode = 'branch',
        cash = data.cash or 0,
        bank = data.bank or 0,
        transactions = data.transactions or {},
    })
end)

RegisterNetEvent('osven-banking:client:openATM', function(data)
    SetNuiFocus(true, true)
    isOpen = true
    SendNUIMessage({
        type = 'OPEN_BANKING',
        mode = 'atm',
        cash = data.cash or 0,
        bank = data.bank or 0,
        transactions = {},
    })
end)

RegisterNUICallback('bank:lookup', function(data, cb)
    if not data or not data.query then cb({}) return end
    TriggerServerEvent('osven-banking:server:lookupRecipient', data.query)
    -- Result comes back via net event
    RegisterNetEvent('osven-banking:client:lookupResult', function(name)
        cb({ name = name })
    end)
    -- Timeout
    Citizen.SetTimeout(5000, function()
        cb({})
    end)
end)

RegisterNUICallback('bank:transfer', function(data, cb)
    if not data then cb({ success = false, error = 'Invalid request' }) return end
    TriggerServerEvent('osven-banking:server:transfer', data.recipient, data.amount, data.note or '')
    RegisterNetEvent('osven-banking:client:transferResult', function(success, newBalance, error)
        cb({ success = success, newBalance = newBalance, error = error })
    end)
    Citizen.SetTimeout(5000, function()
        cb({ success = false, error = 'Request timed out' })
    end)
end)

RegisterNUICallback('bank:atm', function(data, cb)
    if not data or not data.action then cb({ success = false }) return end
    TriggerServerEvent('osven-banking:server:atm', data.action, data.amount)
    RegisterNetEvent('osven-banking:client:atmResult', function(success, newCash, newBank, error)
        cb({ success = success, newCash = newCash, newBank = newBank, error = error })
    end)
    Citizen.SetTimeout(5000, function()
        cb({ success = false, error = 'Request timed out' })
    end)
end)

RegisterNUICallback('bank:close', function(_, cb)
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
