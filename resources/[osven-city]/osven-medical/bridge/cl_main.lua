local QBCore = exports['qb-core']:GetCoreObject()
local currentState = 'normal'
local bleedTimer = nil
local downTimer = nil

-- Health monitoring
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped) - 100
        local maxHealth = GetEntityMaxHealth(ped) - 100

        if health <= 0 then
            -- Downed state
            if currentState ~= 'downed' then
                currentState = 'downed'
                SetNuiFocus(false, false)
                SendNUIMessage({
                    type = 'SET_MEDICAL_STATE',
                    state = 'downed',
                    countdown = 300,  -- 5 minutes
                })
                SetPedToRagdoll(ped, 10000, 10000, 0, true, true, false)
                TriggerServerEvent('osven-medical:server:playerDowned')
                -- Bleed-out timer
                if downTimer then Citizen.RemoveTimer(downTimer) end
                downTimer = Citizen.SetTimeout(300000, function()
                    -- Force respawn
                    TriggerEvent('osven-medical:client:forceRespawn')
                end)
            end
        elseif health < 15 then
            -- Critical state
            if currentState ~= 'critical' then
                currentState = 'critical'
                SendNUIMessage({
                    type = 'SET_MEDICAL_STATE',
                    state = 'critical',
                    countdown = 60,  -- 60s bleed-out before death
                })
                -- Bleed-out timer
                if bleedTimer then Citizen.RemoveTimer(bleedTimer) end
                if downTimer then Citizen.RemoveTimer(downTimer) downTimer = nil end
                bleedTimer = Citizen.SetTimeout(60000, function()
                    SetEntityHealth(ped, 0)
                end)
            end
        elseif health < 40 then
            -- Limping state
            if currentState ~= 'limping' then
                currentState = 'limping'
                SendNUIMessage({
                    type = 'SET_MEDICAL_STATE',
                    state = 'limping',
                })
                -- Reduce movement speed
                SetRunSprintMultiplierForPlayer(PlayerId(), 0.7)
            end
        else
            -- Normal
            if currentState ~= 'normal' then
                currentState = 'normal'
                SendNUIMessage({ type = 'CLEAR_MEDICAL_STATE' })
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                if bleedTimer then Citizen.RemoveTimer(bleedTimer) bleedTimer = nil end
                if downTimer then Citizen.RemoveTimer(downTimer) downTimer = nil end
            end
        end
    end
end)

-- Force respawn
RegisterNetEvent('osven-medical:client:forceRespawn', function()
    currentState = 'normal'
    SendNUIMessage({ type = 'CLEAR_MEDICAL_STATE' })
    DoScreenFadeOut(500)
    Citizen.Wait(1000)
    SetEntityHealth(PlayerPedId(), 200)
    DoScreenFadeIn(500)
    TriggerEvent('osven-spawn:client:openSelector', {})
end)

-- Revive
RegisterNetEvent('osven-medical:client:revive', function()
    currentState = 'normal'
    SendNUIMessage({ type = 'CLEAR_MEDICAL_STATE' })
    SetEntityHealth(PlayerPedId(), 200)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    if bleedTimer then Citizen.RemoveTimer(bleedTimer) bleedTimer = nil end
    if downTimer then Citizen.RemoveTimer(downTimer) downTimer = nil end
    -- Clear ragdoll
    ClearPedTasks(PlayerPedId())
    SetPedToRagdoll(PlayerPedId(), 1, 1, 0, false, false, false)
end)

-- Use bandage to stabilize
RegisterNetEvent('osven-medical:client:stabilize', function()
    if currentState == 'critical' then
        currentState = 'limping'
        SendNUIMessage({
            type = 'SET_MEDICAL_STATE',
            state = 'limping',
        })
        SetEntityHealth(PlayerPedId(), 140)  -- ~40% to start limping range
        SetRunSprintMultiplierForPlayer(PlayerId(), 0.7)
        if bleedTimer then Citizen.RemoveTimer(bleedTimer) bleedTimer = nil end
    end
end)
