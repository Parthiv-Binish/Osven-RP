local radioOpen = false
local currentChannel = 0
local isTalking = false

-- Radio UI
local function openRadio()
    if radioOpen then return end
    SetNuiFocus(true, true)
    radioOpen = true
    SendNUIMessage({ action = 'open', channel = currentChannel })
end

local function closeRadio()
    if not radioOpen then return end
    SetNuiFocus(false, false)
    radioOpen = false
    SendNUIMessage({ action = 'close' })
end

-- Toggle radio transmit
RegisterCommand('+radiotalk', function()
    if currentChannel > 0 then
        isTalking = true
        exports['pma-voice']:setRadioChannel(currentChannel)
        TriggerEvent('pma-voice:radioActive', true)
    end
end, false)

RegisterCommand('-radiotalk', function()
    isTalking = false
    if currentChannel > 0 then
        exports['pma-voice']:setRadioChannel(currentChannel)
    end
    TriggerEvent('pma-voice:radioActive', false)
end, false)

RegisterKeyMapping('+radiotalk', 'Radio Transmit', 'keyboard', Config.keyBind.useRadio)

-- Open/Close radio UI
RegisterCommand('+openRadio', function()
    if currentChannel > 0 then
        openRadio()
    else
        QBCore.Functions.Notify('No radio connected', 'error')
    end
end, false)

RegisterCommand('-openRadio', closeRadio, false)
RegisterKeyMapping('+openRadio', 'Open Radio', 'keyboard', Config.keyBind.openRadio)

-- Channel cycling
RegisterCommand('+radioChannelUp', function()
    if currentChannel > 0 then
        local newChan = math.min(currentChannel + 1, Config.MaxFrequency)
        TriggerServerEvent('osven-radio:server:joinRadio', newChan)
    end
end, false)

RegisterCommand('-radioChannelUp', function() end, false)
RegisterKeyMapping('+radioChannelUp', 'Radio Channel Up', 'keyboard', Config.keyBind.RadioChannelUp)

RegisterCommand('+radioChannelDown', function()
    if currentChannel > 0 then
        local newChan = math.max(currentChannel - 1, Config.MinFrequency)
        TriggerServerEvent('osven-radio:server:joinRadio', newChan)
    end
end, false)

RegisterCommand('-radioChannelDown', function() end, false)
RegisterKeyMapping('+radioChannelDown', 'Radio Channel Down', 'keyboard', Config.keyBind.RadioChannelDown)

-- NUI callbacks
RegisterNUICallback('joinChannel', function(data, cb)
    TriggerServerEvent('osven-radio:server:joinRadio', tonumber(data.channel))
    cb({ ok = true })
end)

RegisterNUICallback('leaveChannel', function(_, cb)
    TriggerServerEvent('osven-radio:server:leaveRadio')
    currentChannel = 0
    closeRadio()
    cb({ ok = true })
end)

RegisterNUICallback('volumeChange', function(data, cb)
    exports['pma-voice']:setRadioVolume(tonumber(data.volume) or Config.DefaultRadioVolume)
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    closeRadio()
    cb({ ok = true })
end)

-- Server events
RegisterNetEvent('osven-radio:client:setRadioChannel', function(channel)
    currentChannel = channel
    if channel == 0 then
        exports['pma-voice']:setRadioChannel(0)
        QBCore.Functions.Notify('Radio disconnected', 'error')
    end
end)

RegisterNetEvent('osven-radio:client:setRadioVolume', function(volume)
    exports['pma-voice']:setRadioVolume(volume)
end)

-- qb-radio compat events (for radial menu)
RegisterNetEvent('qb-radio:client:JoinRadioChannel1', function() TriggerServerEvent('osven-radio:server:joinRadio', 1) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel2', function() TriggerServerEvent('osven-radio:server:joinRadio', 2) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel3', function() TriggerServerEvent('osven-radio:server:joinRadio', 3) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel4', function() TriggerServerEvent('osven-radio:server:joinRadio', 4) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel5', function() TriggerServerEvent('osven-radio:server:joinRadio', 5) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel6', function() TriggerServerEvent('osven-radio:server:joinRadio', 6) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel7', function() TriggerServerEvent('osven-radio:server:joinRadio', 7) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel8', function() TriggerServerEvent('osven-radio:server:joinRadio', 8) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel9', function() TriggerServerEvent('osven-radio:server:joinRadio', 9) end)
RegisterNetEvent('qb-radio:client:JoinRadioChannel10', function() TriggerServerEvent('osven-radio:server:joinRadio', 10) end)

-- Radio item use
RegisterNetEvent('osven-radio:client:useRadio', function()
    if currentChannel > 0 then
        TriggerServerEvent('osven-radio:server:leaveRadio')
    else
        openRadio()
    end
end)

-- Interaction via ox_target or item use
-- Register ox_inventory item use handler in osven-inventory-bridge
