local QBCore = exports['qb-core']:GetCoreObject()

local function getChannel(channelId)
    for _, ch in ipairs(Config.ChatChannels) do
        if ch.id == channelId then return ch end
    end
    return nil
end

local function broadcastMessage(source, channel, message)
    local channelCfg = getChannel(channel)
    if not channelCfg then return end

    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local msg = {
        channel = channel,
        sender = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        senderId = source,
        message = message,
        timestamp = os.date('%H:%M'),
        accent = channelCfg.color,
        icon = channelCfg.icon,
        label = channelCfg.label,
    }

    local players = QBCore.Functions.GetPlayers()
    for _, targetId in ipairs(players) do
        local target = QBCore.Functions.GetPlayer(targetId)
        if target then
            if channelCfg.maxDistance > 0 then
                local sourcePed = GetPlayerPed(source)
                local targetPed = GetPlayerPed(targetId)
                local sourceCoords = GetEntityCoords(sourcePed)
                local targetCoords = GetEntityCoords(targetPed)
                local dist = #(sourceCoords - targetCoords)
                if dist > channelCfg.maxDistance then goto continue end
            end

            if channel == 'pd' then
                if target.PlayerData.job.name ~= 'police' and target.PlayerData.job.name ~= 'sasp' then goto continue end
            elseif channel == 'ems' then
                if target.PlayerData.job.name ~= 'ambulance' then goto continue end
            elseif channel == 'gang' then
                if target.PlayerData.gang.name ~= player.PlayerData.gang.name then goto continue end
            elseif channel == 'admin' then
                if not IsPlayerAceAllowed(tostring(targetId), 'command') then goto continue end
            end

            TriggerClientEvent('osven-chat:client:receiveMessage', targetId, msg)
            ::continue::
        end
    end
end

RegisterServerEvent('osven-chat:server:sendMessage', function(channel, message)
    local src = source
    if not channel or not message or message == '' then return end
    if string.len(message) > 500 then return end

    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local now = os.time()
    local rateKey = 'chat_rate_' .. src
    local lastTime = GlobalState[rateKey] or 0
    if now - lastTime < 1 then return end
    GlobalState[rateKey] = now

    broadcastMessage(src, channel, message)
end)

RegisterCommand('clearchat', function(source)
    if not IsPlayerAceAllowed(tostring(source), 'command') then return end
    local players = QBCore.Functions.GetPlayers()
    for _, targetId in ipairs(players) do
        TriggerClientEvent('osven-chat:client:clearChat', targetId)
    end
end, true)
