local QBCore = exports['qb-core']:GetCoreObject()
local isOpen = false
local history = {}
local historyKey = 20  -- 'T' by default

-- Register commands
RegisterCommand('me', function(_, args, raw)
    if #args < 1 then return end
    TriggerServerEvent('osven-chat:server:sendMessage', 'me', raw:sub(4))
end)

RegisterCommand('do', function(_, args, raw)
    if #args < 1 then return end
    TriggerServerEvent('osven-chat:server:sendMessage', 'do', raw:sub(4))
end)

RegisterCommand('ooc', function(_, args, raw)
    if #args < 1 then return end
    TriggerServerEvent('osven-chat:server:sendMessage', 'ooc', raw:sub(5))
end)

-- QBCore chat overrides
RegisterNetEvent('QBCore:client:sendChatMessage', function(source, sender, msg, msgType)
    if msgType == 'me' then
        TriggerServerEvent('osven-chat:server:sendMessage', 'me', msg)
    elseif msgType == 'do' then
        TriggerServerEvent('osven-chat:server:sendMessage', 'do', msg)
    elseif msgType == 'ooc' then
        TriggerServerEvent('osven-chat:server:sendMessage', 'ooc', msg)
    end
end)

-- NUI callbacks
RegisterNUICallback('chat:typing', function(_, cb)
    cb({})
end)

RegisterNUICallback('chat:send', function(data, cb)
    if not data or not data.channel or not data.message then cb({}) return end
    TriggerServerEvent('osven-chat:server:sendMessage', data.channel, data.message)
    cb({})
end)

RegisterNUICallback('chat:history', function(_, cb)
    cb(history)
end)

RegisterNUICallback('chat:focus', function(data, cb)
    if data and data.state then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
    cb({})
end)

-- Listen for incoming messages
RegisterNetEvent('osven-chat:client:receiveMessage', function(msg)
    table.insert(history, msg)
    if #history > Config.MaxHistoryMessages then
        table.remove(history, 1)
    end
    SendNUIMessage({ type = 'CHAT_MESSAGE', data = msg })
end)

-- Toggle chat input
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 245) then  -- TAB key for chat
            if not isOpen then
                isOpen = true
                SetNuiFocus(true, true)
                SendNUIMessage({ type = 'CHAT_OPEN' })
            end
        end
        if IsControlJustPressed(0, 177) then  -- ESC
            if isOpen then
                isOpen = false
                SetNuiFocus(false, false)
                SendNUIMessage({ type = 'CHAT_CLOSE' })
            end
        end
    end
end)

-- History panel toggle (T key)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, historyKey) and not isOpen then
            SendNUIMessage({ type = 'TOGGLE_HISTORY' })
        end
    end
end)

-- Speech bubbles above players
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        -- 3D speech bubbles are handled via server-side distance checks
        -- no heavy per-frame work needed client-side
    end
end)

exports('getHistory', function()
    return history
end)

exports('isChatOpen', function()
    return isOpen
end)
