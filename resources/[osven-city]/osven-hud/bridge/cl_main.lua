local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isInWater = false
local bankVisibleTimer = 0

local function SendNUI(action, data)
    SendNUIMessage({ action = action, data = data })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    SendNUI('setPlayerName', PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- Real-time character name sync from osven-charcreator
RegisterNetEvent('osven:client:updateCharacterName', function(fullName)
    SendNUI('setPlayerName', fullName)
    PlayerData.charinfo.firstname = fullName:match('^(%S+)') or fullName
    PlayerData.charinfo.lastname = fullName:match('(%S+)$') or ''
end)

RegisterNetEvent('hospital:client:InWater', function(inWater)
    isInWater = inWater
end)

CreateThread(function()
    while true do
        Wait(Config.HUD.UpdateInterval)
        if not LocalPlayer.state.isLoggedIn then
            Wait(500)
        end

        local ped = PlayerPedId()
        local health = GetEntityHealth(ped) - 100
        local maxHealth = GetEntityMaxHealth(ped) - 100
        local armor = GetPedArmour(ped)
        local oxygen = (not isInWater) and -1 or GetPlayerUnderwaterTimeRemaining(PlayerId())

        SendNUI('updateVitals', {
            health = math.max(0, health),
            maxHealth = math.max(1, maxHealth),
            armor = armor,
            oxygen = oxygen,
        })
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if LocalPlayer.state.isLoggedIn then
            local hunger = 100
            local thirst = 100
            local stress = 0

            if PlayerData.metadata then
                hunger = PlayerData.metadata.hunger or 100
                thirst = PlayerData.metadata.thirst or 100
                stress = PlayerData.metadata.stress or 0
            end

            SendNUI('updateStatus', {
                hunger = hunger,
                thirst = thirst,
                stress = stress,
            })
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.HUD.UpdateInterval)
        if LocalPlayer.state.isLoggedIn then
            local cash = PlayerData.money and PlayerData.money.cash or 0
            local bank = PlayerData.money and PlayerData.money.bank or 0
            local job = PlayerData.job or {}
            local gang = PlayerData.gang or {}

            bankVisibleTimer = math.max(0, bankVisibleTimer - Config.HUD.UpdateInterval)

            SendNUI('updateMoney', {
                cash = cash,
                bank = bank,
                bankVisible = bankVisibleTimer > 0,
                job = job.label or 'Unemployed',
                jobGrade = job.grade and job.grade.name or '',
                gang = gang.label or nil,
            })
        end
    end
end)

RegisterNetEvent('osven-hud:revealBank', function()
    bankVisibleTimer = Config.HUD.HideBankDelay
end)

RegisterNetEvent('osven-hud:updateVoice', function(range)
    SendNUI('setVoice', { range = range })
end)

-- Voice range integration with pma-voice
local voiceRange = 0
RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
    voiceRange = mode
    SendNUI('setVoice', { range = mode })
end)

-- Stress updates from qb-smallresources or similar
RegisterNetEvent('hud:client:UpdateStress', function(s)
    SendNUI('updateStatus', { stress = s })
end)

-- Oxygen underwater detection
CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        if IsPedSwimmingUnderWater(ped) then
            if not isInWater then
                isInWater = true
                TriggerEvent('hospital:client:InWater', true)
            end
        else
            if isInWater then
                isInWater = false
                TriggerEvent('hospital:client:InWater', false)
                SendNUI('updateVitals', { oxygen = -1 })
            end
        end
    end
end)
