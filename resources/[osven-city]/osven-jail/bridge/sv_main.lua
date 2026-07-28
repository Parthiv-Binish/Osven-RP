local QBCore = exports['qb-core']:GetCoreObject()
local activeSentences = {}

RegisterServerEvent('osven-jail:server:sentencePlayer', function(targetId, minutes)
    local src = source
    local officer = QBCore.Functions.GetPlayer(src)
    if not officer then return end
    if officer.PlayerData.job.name ~= 'police' and officer.PlayerData.job.name ~= 'sasp' then return end

    local target = QBCore.Functions.GetPlayer(targetId)
    if not target then return end

    minutes = tonumber(minutes)
    if not minutes or minutes <= 0 or minutes > 240 then return end  -- max 4 hours

    local duration = minutes * 60
    activeSentences[targetId] = {
        remaining = duration,
        original = duration,
        communityActive = false,
        thread = nil,
    }

    TriggerClientEvent('osven-jail:client:startSentence', targetId, duration)
end)

RegisterServerEvent('osven-jail:server:startCommunityService', function()
    local src = source
    if not activeSentences[src] then return end
    if activeSentences[src].communityActive then return end

    activeSentences[src].communityActive = true

    activeSentences[src].thread = Citizen.CreateThread(function()
        while activeSentences[src] and activeSentences[src].communityActive do
            Citizen.Wait(1000)
            if activeSentences[src] then
                activeSentences[src].remaining = activeSentences[src].remaining - 2
                local total = activeSentences[src].remaining
                local pct = math.floor((1 - total / activeSentences[src].original) * 100)
                TriggerClientEvent('osven-jail:client:communityProgress', src, pct, total)

                if total <= 0 then
                    activeSentences[src] = nil
                    TriggerClientEvent('osven-jail:client:released', src)
                    TriggerClientEvent('osven-spawn:client:spawnPlayer', src, vector4(178.64, -1006.36, 29.37, 180.0))
                    break
                end
            end
        end
    end)
end)

-- Cleanup on disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    if activeSentences[src] then
        -- Sentence persists for re-log
    end
end)

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(player)
    local src = player.PlayerData.source
    if activeSentences[src] and activeSentences[src].remaining > 0 then
        TriggerClientEvent('osven-jail:client:startSentence', src, activeSentences[src].remaining)
    end
end)
