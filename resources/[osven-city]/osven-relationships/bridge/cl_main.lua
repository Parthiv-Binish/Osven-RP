local isMarried = false
local spouseName = nil
local spouseCid = nil
local proposalPending = nil
local marriageMenuOpen = false
local ceremonyActive = false

-- Open marriage menu
local function openMarriageMenu()
    if marriageMenuOpen then return end
    marriageMenuOpen = true
    SetNuiFocus(true, true)

    local data = { married = isMarried }
    if isMarried then
        data.spouseName = spouseName
    end
    SendNUIMessage({ type = 'OPEN_MARRIAGE', data = data })
end

-- Close marriage menu
local function closeMarriageMenu()
    marriageMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'CLOSE_MARRIAGE' })
end

-- Near spouse health regen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        if isMarried and spouseCid then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            if health > 0 and health < 200 then
                -- Check if spouse is nearby
                local players = GetActivePlayers()
                for _, playerId in ipairs(players) do
                    if NetworkIsPlayerActive(playerId) then
                        local targetPed = GetPlayerPed(playerId)
                        if targetPed ~= ped then
                            local targetSrc = GetPlayerServerId(playerId)
                            -- We can't easily check citizenid here, so just check proximity
                            local dist = #(GetEntityCoords(ped) - GetEntityCoords(targetPed))
                            if dist <= Config.SpouseProximityRange then
                                SetEntityHealth(ped, math.min(200, health + Config.SpouseHealthRegen))
                                QBCore.Functions.Notify('You feel comforted by a nearby presence (+hp)', 'success')
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Propose to nearby player
function ProposeToPlayer(targetSrc)
    TriggerServerEvent('osven-relationships:server:propose', targetSrc)
end

-- NUI callbacks
RegisterNUICallback('marriage:propose', function(data, cb)
    cb({})
    closeMarriageMenu()
    local targetSrc = tonumber(data.target)
    if targetSrc then
        ProposeToPlayer(targetSrc)
    end
end)

RegisterNUICallback('marriage:acceptProposal', function(_, cb)
    cb({})
    if proposalPending then
        TriggerServerEvent('osven-relationships:server:acceptProposal', proposalPending.from)
        proposalPending = nil
    end
    closeMarriageMenu()
end)

RegisterNUICallback('marriage:declineProposal', function(_, cb)
    cb({})
    if proposalPending then
        TriggerServerEvent('osven-relationships:server:declineProposal', proposalPending.from)
        proposalPending = nil
    end
    closeMarriageMenu()
end)

RegisterNUICallback('marriage:divorce', function(_, cb)
    cb({})
    closeMarriageMenu()
    TriggerServerEvent('osven-relationships:server:divorce')
end)

RegisterNUICallback('marriage:close', function(_, cb)
    cb({})
    closeMarriageMenu()
end)

-- Receive proposal from another player
RegisterNetEvent('osven-relationships:client:receiveProposal', function(data)
    proposalPending = data
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'OPEN_PROPOSAL',
        data = {
            fromName = data.fromName,
            ring = data.ring,
            from = data.from,
        }
    })
end)

-- Update marriage status
RegisterNetEvent('osven-relationships:client:updateMarriageStatus', function(data)
    isMarried = data.married
    spouseCid = data.spouse
    spouseName = data.spouseName
end)

-- Get marriage data on load
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local marriage = lib.callback.await('osven-relationships:client:getMarriage', false)
    if marriage then
        isMarried = true
        spouseCid = marriage.spouse
        -- Try to get spouse name from player data (may not be available if offline)
        spouseName = 'Your Spouse'
    end
end)

-- Toggle marriage menu
RegisterCommand('marriage', function()
    if marriageMenuOpen then
        closeMarriageMenu()
    else
        openMarriageMenu()
    end
end, false)

RegisterKeyMapping('marriage', 'Open Relationship Menu', 'keyboard', Config.OpenMarriageKey)
