-- qb-npwd: QBCore framework integration for NPWD
-- NPWD v3 has a built-in QBCore bridge that hooks into qb-core events
-- This resource exists to satisfy the dependency check.

local QBCore = exports['qb-core']:GetCoreObject()

-- Ensure the npwd:framework convar is set
SetConvarReplicated('npwd:framework', 'qbcore')

-- Intercept qb-phone events and forward appropriate ones to NPWD
-- This allows legacy qb-phone dependent resources (like MDT) to still work

-- Forward call events from qb-phone style to NPWD
RegisterNetEvent('qb-phone:server:sendNewMail', function(data)
    -- qb-phone mail compat stub
    TriggerEvent('npwd:sendMail', source, data)
end)

-- Expose player data for NPWD's QBCore bridge
lib.callback.register('qb-npwd:getPlayerData', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    local data = Player.PlayerData
    return {
        citizenid = data.citizenid,
        license = data.license,
        firstname = data.charinfo.firstname,
        lastname = data.charinfo.lastname,
        phone = data.charinfo.phone,
        job = data.job,
        gang = data.gang
    }
end)

lib.callback.register('qb-npwd:getPlayers', function()
    return QBCore.Functions.GetQBPlayers()
end)

print('[qb-npwd] QBCore NPWD bridge loaded.')
