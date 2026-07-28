local WebhookUrl = Config.DiscordBot.WebhookUrl
local Secret = Config.DiscordBot.Secret
local Events = Config.DiscordBot.Events

local function sendToBot(event, data)
    if WebhookUrl == '' or Secret == '' then return end
    PerformHttpRequest(WebhookUrl, function(code)
        if code ~= 200 and Config.DiscordBot.Debug then
            print(('[osven-discord-bot] Webhook returned %s'):format(tostring(code)))
        end
    end, 'POST', json.encode({
        secret = Secret,
        event = event,
        data = data,
        server = GetConvar('sv_hostname', 'Osven City'),
        timestamp = os.time(),
    }), { ['Content-Type'] = 'application/json' })
end

-- Player join/leave
if Events.JoinLeave then
    AddEventHandler('playerConnecting', function(name)
        local src = source
        local discordId = 'unknown'
        for _, id in ipairs(GetPlayerIdentifiers(src)) do
            if id:find('discord:') then discordId = id:gsub('discord:', ''); break end
        end
        sendToBot('playerConnecting', { name = name, discordId = discordId })
    end)

    AddEventHandler('playerDropped', function(reason)
        local src = source
        local name = GetPlayerName(src)
        local discordId = 'unknown'
        for _, id in ipairs(GetPlayerIdentifiers(src)) do
            if id:find('discord:') then discordId = id:gsub('discord:', ''); break end
        end
        sendToBot('playerDropped', { name = name, discordId = discordId, reason = reason })
    end)
end

-- Player reports from osven-admin
if Events.Reports then
    RegisterNetEvent('osven:server:playerReport', function(target, reason)
        local src = source
        local reporterName = GetPlayerName(src)
        local targetName = GetPlayerName(target)
        sendToBot('playerReport', {
            reporter = { name = reporterName, id = src },
            target = { name = targetName, id = target },
            reason = reason,
        })
    end)
end

-- Staff actions from osven-admin
if Events.StaffActions then
    RegisterNetEvent('osven:server:staffAction', function(action, target, detail)
        local src = source
        local staffName = GetPlayerName(src)
        sendToBot('staffAction', {
            staff = { name = staffName, id = src },
            action = action,
            target = target,
            detail = detail,
        })
    end)
end

-- Ban events (triggered by osven-admin when banning a player)
RegisterNetEvent('osven:server:playerBanned', function(data)
    sendToBot('playerBan', {
        playerName = data.playerName,
        discordId = data.discordId,
        citizenId = data.citizenId,
        reason = data.reason,
        bannedBy = data.bannedBy,
        duration = data.duration,
        isPermanent = data.isPermanent or false,
    })
end)

-- Server start/stop signals
AddEventHandler('onServerResourceStart', function(res)
    if res == GetCurrentResourceName() then
        sendToBot('serverStart', {})
        print('[osven-discord-bot] Bridge loaded')
    end
end)

AddEventHandler('onServerResourceStop', function(res)
    if res == GetCurrentResourceName() then
        sendToBot('serverStop', {})
    end
end)
