-- ============ qb-phone Compat Server Exports ============
-- Intercept qb-phone callbacks and redirect to NPWD exports
-- Only NPWD server exports that actually exist are used here.

-- qb-phone:server:GetPhoneData -> NPWD getPlayerData
lib.callback.register('qb-phone:server:GetPhoneData', function(source)
    local playerData = exports.npwd:getPlayerData({ source = source })
    return playerData
end)

-- qb-phone:server:sendMessage -> NPWD emitMessage
lib.callback.register('qb-phone:server:sendMessage', function(source, data)
    if not data or not data.targetNumber then return false end
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    local senderNumber = Player.PlayerData.charinfo.phone
    exports.npwd:emitMessage({
        senderNumber = senderNumber,
        targetNumber = data.targetNumber,
        message = data.message,
        embed = data.embed or {}
    })
    return true
end)

-- ============ NPWD Exports (for other resources to call) ============

-- Emit in-game notification to phone
exports('sendPhoneAlert', function(targetNumber, message, embed)
    exports.npwd:emitMessage({
        senderNumber = '911',
        targetNumber = targetNumber,
        message = message,
        embed = embed or {}
    })
end)

-- Get player phone number
exports('getPlayerPhone', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    return Player.PlayerData.charinfo.phone
end)

-- ============ Event Forwarding ============

-- Forward qb-phone style events to NPWD
RegisterNetEvent('phone:server:sendMessage', function(data)
    local src = source
    if not data or not data.targetNumber then return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local senderNumber = Player.PlayerData.charinfo.phone

    exports.npwd:emitMessage({
        senderNumber = senderNumber,
        targetNumber = data.targetNumber,
        message = data.message or '',
        embed = data.embed or {}
    })
end)

-- Forward 911 alerts from medical/police systems
RegisterNetEvent('hospital:server:ambulanceAlert', function(text)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
            exports.npwd:emitMessage({
                senderNumber = '911',
                targetNumber = v.PlayerData.charinfo.phone,
                message = text or 'Medical emergency reported.',
                embed = {
                    type = 'location',
                    coords = { coords.x, coords.y, coords.z },
                    phoneNumber = '911',
                }
            })
        end
    end
end)

print('[osven-phone-bridge] qb-phone -> NPWD bridge loaded.')
