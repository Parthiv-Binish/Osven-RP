local QBCore = exports['qb-core']:GetCoreObject()

-- PD request ID card from target
RegisterServerEvent('osven-idcard:server:requestId', function(targetId)
    local src = source
    local officer = QBCore.Functions.GetPlayer(src)
    local citizen = QBCore.Functions.GetPlayer(targetId)
    if not officer or not citizen then return end

    -- Verify officer has PD job
    if officer.PlayerData.job.name ~= 'police' and officer.PlayerData.job.name ~= 'sasp' then return end

    local char = citizen.PlayerData.charinfo
    local idData = {
        name = char.firstname .. ' ' .. char.lastname,
        dob = char.dateofbirth or 'N/A',
        citizenId = citizen.PlayerData.citizenid,
        job = citizen.PlayerData.job.label or 'Citizen',
        driving = char.driving or 'NONE',
        weapon = char.weapon or 'NONE',
        presented = true,
    }
    TriggerClientEvent('osven-idcard:client:showCard', src, idData)
end)
