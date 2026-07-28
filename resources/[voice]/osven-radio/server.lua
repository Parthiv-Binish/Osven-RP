local radioPlayers = {}

function IsRadioOn(src)
    return radioPlayers[src] and radioPlayers[src].channel or false
end

RegisterNetEvent('osven-radio:server:joinRadio', function(channel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    channel = tonumber(channel)
    if not channel or channel < Config.MinFrequency or channel > Config.MaxFrequency then return end

    -- Check restricted channels
    local restricted = Config.RestrictedChannels[channel]
    if restricted then
        local job = Player.PlayerData.job.name
        if (restricted.police and job ~= 'police') or (restricted.ambulance and job ~= 'ambulance') then
            TriggerClientEvent('QBCore:Notify', src, 'You cannot access this channel', 'error')
            return
        end
    end

    -- Check if player has radio item
    local hasRadio = exports['osven-inventory-bridge']:HasItem(src, Config.RadioItem)
    if not hasRadio then
        TriggerClientEvent('QBCore:Notify', src, 'You need a radio', 'error')
        return
    end

    radioPlayers[src] = { channel = channel }

    exports['pma-voice']:setPlayerRadio(src, channel)
    TriggerClientEvent('osven-radio:client:setRadioChannel', src, channel)
    TriggerClientEvent('QBCore:Notify', src, 'Joined channel ' .. channel, 'success')
end)

RegisterNetEvent('osven-radio:server:leaveRadio', function()
    local src = source
    radioPlayers[src] = nil
    exports['pma-voice']:setPlayerRadio(src, 0)
    TriggerClientEvent('osven-radio:client:setRadioChannel', src, 0)
end)

RegisterNetEvent('osven-radio:server:setRadioVolume', function(volume)
    local src = source
    TriggerClientEvent('osven-radio:client:setRadioVolume', src, volume)
end)

-- Export for other resources
exports('IsRadioOn', IsRadioOn)

-- qb-radio compat exports
exports('JoinRadio', function(source, channel)
    TriggerEvent('osven-radio:server:joinRadio', channel)
end)

exports('LeaveRadio', function(source)
    TriggerEvent('osven-radio:server:leaveRadio')
end)
