local QBCore = exports['qb-core']:GetCoreObject()

-- Discord embed sender
local function sendWebhook(channel, title, description, color, fields, footer)
    local url = Config.Webhooks[channel]
    if not url or url == '' then return end

    local embed = {
        {
            ['title'] = title,
            ['description'] = description,
            ['color'] = color,
            ['fields'] = fields or {},
            ['footer'] = footer or { text = 'Osven City Logs' },
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        }
    }

    local payload = { embeds = embed }

    PerformHttpRequest(url, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end

-- Exposed log function
exports('log', function(channel, title, description, color, fields, footer)
    sendWebhook(channel, title, description, color, fields, footer)
end)

-- Admin action logging overlay for osven-admin
RegisterServerEvent('osven-logging:server:adminAction', function(action, target, detail)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local adminName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local targetPlayer = target and QBCore.Functions.GetPlayer(tonumber(target))
    local targetName = targetPlayer and (targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname) or 'N/A'

    sendWebhook('admin', 'Admin Action: ' .. action, detail, 15158332, {
        { name = 'Admin', value = adminName, inline = true },
        { name = 'Target', value = targetName, inline = true },
    })
end)

-- Chat logging
RegisterServerEvent('osven-logging:server:chatLog', function(channel, message, sender)
    sendWebhook('chat', 'Chat - ' .. channel, message, 5814783, {
        { name = 'Sender', value = sender, inline = true },
        { name = 'Channel', value = channel, inline = true },
    })
end)

-- Economy logging
RegisterServerEvent('osven-logging:server:economyLog', function(action, from, to, amount)
    sendWebhook('economy', 'Transaction: ' .. action, '$' .. tostring(amount), 3066993, {
        { name = 'From', value = from, inline = true },
        { name = 'To', value = to, inline = true },
        { name = 'Amount', value = '$' .. tostring(amount), inline = true },
    })
end)

-- Player join/leave
local function playerJoin(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end
    local name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    sendWebhook('joinleave', 'Player Joined', name .. ' (' .. source .. ') connected.', 3066993)
end

local function playerLeave(source, reason)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end
    local name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    sendWebhook('joinleave', 'Player Left', name .. ' (' .. source .. ') disconnected. Reason: ' .. (reason or 'N/A'), 15158332)
end

AddEventHandler('playerJoining', function()
    local src = source
    Citizen.SetTimeout(3000, function() playerJoin(src) end)
end)

AddEventHandler('playerDropped', function(reason)
    playerLeave(source, reason)
end)

-- Report system
RegisterServerEvent('osven-logging:server:playerReport', function(reportedId, reason)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local reported = QBCore.Functions.GetPlayer(tonumber(reportedId))
    local reportedName = reported and (reported.PlayerData.charinfo.firstname .. ' ' .. reported.PlayerData.charinfo.lastname) or 'Unknown'

    sendWebhook('reports', 'Player Report', reason, 15158332, {
        { name = 'Reporter', value = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname, inline = true },
        { name = 'Reported', value = reportedName .. ' (ID: ' .. reportedId .. ')', inline = true },
        { name = 'Reason', value = reason },
    })
end)
