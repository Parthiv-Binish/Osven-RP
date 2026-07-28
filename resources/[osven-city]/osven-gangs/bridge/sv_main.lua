local QBCore = exports['qb-core']:GetCoreObject()
local territoryOwners = {}
local captureProgress = {}
local cooldowns = {}

-- Load ownership from database
local function loadOwnership()
    local rows = MySQL.query.await('SELECT territory, owner FROM osven_territories')
    if not rows then return end
    for _, row in ipairs(rows) do
        territoryOwners[row.territory] = row.owner
    end
    print('[osven-gangs] Loaded ' .. #rows .. ' territory owners')
end

-- Save ownership to database
local function saveOwnership(territory, owner)
    MySQL.query('INSERT INTO osven_territories (territory, owner) VALUES (?, ?) ON DUPLICATE KEY UPDATE owner = ?', {
        territory, owner, owner
    })
end

-- Get players in a zone, grouped by gang
local function getPlayersInZone(zoneConfig)
    local players = QBCore.Functions.GetQBPlayers()
    local gangCounts = {}
    local zoneCenter = zoneConfig.coords
    local radius = zoneConfig.radius

    for src, player in pairs(players) do
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        local dist = #(coords - zoneCenter)
        if dist <= radius then
            local gang = player.PlayerData.gang.name
            if gang and gang ~= 'none' then
                gangCounts[gang] = (gangCounts[gang] or 0) + 1
            end
        end
    end
    return gangCounts
end

-- Territory capture loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        for zoneId, zoneConfig in pairs(Config.Territories) do
            -- Check cooldown
            if cooldowns[zoneId] and GetGameTimer() < cooldowns[zoneId] then goto continue end

            local currentOwner = territoryOwners[zoneId]
            local nativeGang = zoneConfig.gang
            local gangCounts = getPlayersInZone(zoneConfig)
            local totalInZone = 0
            for _, count in pairs(gangCounts) do totalInZone = totalInZone + count end

            -- No one in zone, reset progress
            if totalInZone == 0 then
                if captureProgress[zoneId] then
                    captureProgress[zoneId] = nil
                end
                goto continue
            end

            -- Find dominant gang
            local dominantGang = nil
            local dominantCount = 0
            local contested = false
            for gang, count in pairs(gangCounts) do
                if count > dominantCount then
                    dominantGang = gang
                    dominantCount = count
                end
            end

            -- Check for contest (more than one gang present)
            local gangPresent = 0
            for _ in pairs(gangCounts) do gangPresent = gangPresent + 1 end
            contested = gangPresent > 1

            if contested then
                captureProgress[zoneId] = nil
                local msg = zoneConfig.label .. ' is contested!'
                for src, _ in pairs(QBCore.Functions.GetQBPlayers()) do
                    local ped = GetPlayerPed(src)
                    local dist = #(GetEntityCoords(ped) - zoneConfig.coords)
                    if dist <= zoneConfig.radius * 2 then
                        Config.Notify(src, msg, 'error')
                    end
                end
                goto continue
            end

            -- Owner already holds it
            if currentOwner == dominantGang then
                captureProgress[zoneId] = nil
                goto continue
            end

            -- Native gang holds it — can't capture your own turf
            if dominantGang == nativeGang and currentOwner == dominantGang then
                captureProgress[zoneId] = nil
                goto continue
            end

            -- Track capture progress
            captureProgress[zoneId] = (captureProgress[zoneId] or 0) + 5
            local progress = captureProgress[zoneId]
            local remaining = Config.CaptureDuration - progress

            -- Notify nearby players every 15s
            if progress % 15 <= 5 then
                local msg = zoneConfig.label .. ': ' .. remaining .. 's remaining'
                for src, player in pairs(QBCore.Functions.GetQBPlayers()) do
                    local ped = GetPlayerPed(src)
                    local dist = #(GetEntityCoords(ped) - zoneConfig.coords)
                    if dist <= zoneConfig.radius * 2 then
                        if player.PlayerData.gang.name == dominantGang then
                            Config.Notify(src, msg, 'success')
                        elseif player.PlayerData.gang.name ~= 'none' and player.PlayerData.gang.name ~= dominantGang then
                            Config.Notify(src, msg, 'error')
                        end
                    end
                end
            end

            -- Capture complete
            if progress >= Config.CaptureDuration then
                local oldOwner = currentOwner or 'unowned'
                territoryOwners[zoneId] = dominantGang
                captureProgress[zoneId] = nil
                cooldowns[zoneId] = GetGameTimer() + (Config.CaptureCooldown * 1000)
                saveOwnership(zoneId, dominantGang)

                -- Notify all online gang members
                for src, player in pairs(QBCore.Functions.GetQBPlayers()) do
                    if player.PlayerData.gang.name == dominantGang then
                        Config.Notify(src, zoneConfig.label .. ' captured by ' .. Config.Gangs[dominantGang].label .. '!', 'success')
                    end
                end

                -- Log to all online admins
                for src, player in pairs(QBCore.Functions.GetQBPlayers()) do
                    if player.PlayerData.job.name == 'police' and player.PlayerData.job.onduty then
                        Config.Notify(src, 'TERRITORY: ' .. zoneConfig.label .. ' taken by ' .. Config.Gangs[dominantGang].label, 'police')
                    end
                end

                -- Discord log
                TriggerEvent('osven-logging:server:sendLog', 'gang', {
                    message = 'Territory Captured',
                    fields = {
                        { label = 'Zone', value = zoneConfig.label, icon = 0 },
                        { label = 'Captured By', value = Config.Gangs[dominantGang].label, icon = 0 },
                        { label = 'Old Owner', value = oldOwner ~= 'unowned' and (Config.Gangs[oldOwner].label or oldOwner) or 'None', icon = 0 },
                    }
                })
            end

            ::continue::
        end
    end
end)

-- ============ Callbacks ============

lib.callback.register('osven-gangs:client:getTerritories', function(source)
    local result = {}
    for zoneId, zoneConfig in pairs(Config.Territories) do
        result[zoneId] = {
            label = zoneConfig.label,
            gang = zoneConfig.gang,
            owner = territoryOwners[zoneId],
            coords = zoneConfig.coords,
            radius = zoneConfig.radius,
        }
    end
    return result
end)

-- ============ Exports ============

-- Get current owner of a territory
exports('GetTerritoryOwner', function(zoneId)
    return territoryOwners[zoneId]
end)

-- Get all territories and their owners
exports('GetAllTerritories', function()
    local result = {}
    for zoneId, zoneConfig in pairs(Config.Territories) do
        result[zoneId] = {
            label = zoneConfig.label,
            gang = zoneConfig.gang,
            owner = territoryOwners[zoneId],
            coords = zoneConfig.coords,
            radius = zoneConfig.radius,
        }
    end
    return result
end)

-- Get capture progress for a zone
exports('GetCaptureProgress', function(zoneId)
    return captureProgress[zoneId]
end)

-- ============ Payday ============

-- Distribute territory income every 30 minutes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30 * 60 * 1000)

        for zoneId, owner in pairs(territoryOwners) do
            if owner and owner ~= 'none' then
                -- Add to gang bank account
                local gangAccount = 'boss_' .. owner
                exports['qb-banking']:AddMoney(gangAccount, Config.TerritoryIncome, 'Territory income: ' .. (Config.Territories[zoneId].label or zoneId))

                -- Notify gang members
                for src, player in pairs(QBCore.Functions.GetQBPlayers()) do
                    if player.PlayerData.gang.name == owner then
                        Config.Notify(src, 'Territory payday: +$' .. Config.TerritoryIncome .. ' from ' .. (Config.Territories[zoneId].label or zoneId), 'success')
                    end
                end
            end
        end
    end
end)

-- ============ Init ============

AddEventHandler('onServerResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        loadOwnership()
    end
end)

-- ============ Commands ============

RegisterCommand('territories', function(source)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local msg = '=== Territories ==='
    for zoneId, zoneConfig in pairs(Config.Territories) do
        local owner = territoryOwners[zoneId]
        local ownerLabel = owner and Config.Gangs[owner] and Config.Gangs[owner].label or 'Unowned'
        msg = msg .. '\n' .. zoneConfig.label .. ': ' .. ownerLabel
    end
    Config.Notify(src, msg, 'primary')
end, true)

-- ============ Admin Commands ============

-- Force-set a territory owner
RegisterCommand('setterritory', function(source, args)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not QBCore.Functions.HasPermission(src, 'admin') then
        Config.Notify(src, 'No permission', 'error')
        return
    end

    local zoneId = args[1]
    local gang = args[2]

    if not zoneId or not Config.Territories[zoneId] then
        Config.Notify(src, 'Usage: /setterritory [zone] [gang] — Zones: ' .. table.concat(GetTerritoryList(), ', '), 'error')
        return
    end
    if not gang or not Config.Gangs[gang] then
        Config.Notify(src, 'Invalid gang. Options: ' .. table.concat(GetGangList(), ', '), 'error')
        return
    end

    territoryOwners[zoneId] = gang
    captureProgress[zoneId] = nil
    cooldowns[zoneId] = nil
    saveOwnership(zoneId, gang)

    TriggerClientEvent('osven-gangs:client:refreshTerritories', -1)
    Config.Notify(src, Config.Territories[zoneId].label .. ' → ' .. Config.Gangs[gang].label, 'success')

    TriggerEvent('osven-logging:server:sendLog', 'admin', {
        message = 'Territory Set by Admin',
        fields = {
            { label = 'Admin', value = GetPlayerName(src), icon = 0 },
            { label = 'Zone', value = Config.Territories[zoneId].label, icon = 0 },
            { label = 'Gang', value = Config.Gangs[gang].label, icon = 0 },
        }
    })
end, true)

-- Reset all territories to unowned
RegisterCommand('resetterritories', function(source, _)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not QBCore.Functions.HasPermission(src, 'admin') then
        Config.Notify(src, 'No permission', 'error')
        return
    end

    for zoneId, _ in pairs(Config.Territories) do
        territoryOwners[zoneId] = nil
        captureProgress[zoneId] = nil
        cooldowns[zoneId] = nil
        saveOwnership(zoneId, 'none')
    end

    TriggerClientEvent('osven-gangs:client:refreshTerritories', -1)
    Config.Notify(src, 'All territories reset', 'success')

    TriggerEvent('osven-logging:server:sendLog', 'admin', {
        message = 'All Territories Reset',
        fields = { { label = 'Admin', value = GetPlayerName(src), icon = 0 } }
    })
end, true)

-- Clear specific zone cooldown
RegisterCommand('clearcooldown', function(source, args)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not QBCore.Functions.HasPermission(src, 'admin') then
        Config.Notify(src, 'No permission', 'error')
        return
    end

    local zoneId = args[1]
    if not zoneId or not Config.Territories[zoneId] then
        Config.Notify(src, 'Usage: /clearcooldown [zone]', 'error')
        return
    end

    cooldowns[zoneId] = nil
    Config.Notify(src, 'Cooldown cleared for ' .. Config.Territories[zoneId].label, 'success')
end, true)

-- ============ Helper functions for commands ============

function GetTerritoryList()
    local list = {}
    for id, _ in pairs(Config.Territories) do table.insert(list, id) end
    return list
end

function GetGangList()
    local list = {}
    for id, _ in pairs(Config.Gangs) do table.insert(list, id) end
    return list
end

-- Expose for admin panel
exports('GetTerritoryList', GetTerritoryList)
exports('GetGangList', GetGangList)
exports('SetTerritoryOwner', function(zoneId, gang)
    if not Config.Territories[zoneId] or not Config.Gangs[gang] then return false end
    territoryOwners[zoneId] = gang
    captureProgress[zoneId] = nil
    cooldowns[zoneId] = nil
    saveOwnership(zoneId, gang)
    TriggerClientEvent('osven-gangs:client:refreshTerritories', -1)
    return true
end)
exports('ResetAllTerritories', function()
    for zoneId, _ in pairs(Config.Territories) do
        territoryOwners[zoneId] = nil
        captureProgress[zoneId] = nil
        cooldowns[zoneId] = nil
        saveOwnership(zoneId, 'none')
    end
    TriggerClientEvent('osven-gangs:client:refreshTerritories', -1)
end)
