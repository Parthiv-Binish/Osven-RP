local QBCore = exports['qb-core']:GetCoreObject()
local armoryLog = {}

-- Resolve rank index from job grade
local function getRankIndex(jobName, grade)
    local rankOrder = {
        ['police'] = { ['cadet'] = 1, ['officer'] = 2, ['senior'] = 2, ['sergeant'] = 3, ['lieutenant'] = 4, ['captain'] = 4, ['chief'] = 5 },
        ['sasp'] = { ['trooper'] = 2, ['sergeant'] = 3, ['lieutenant'] = 4, ['captain'] = 4, ['chief'] = 5 },
        ['ambulance'] = { ['trainee'] = 1, ['emt'] = 2, ['paramedic'] = 3, ['doctor'] = 4 },
    }
    local ranks = rankOrder[jobName]
    if not ranks then return 0 end
    return ranks[grade] or 0
end

-- Get available weapons/items for a player based on rank
local function getAvailableTier(player)
    if not player then return {}, {} end
    local job = player.PlayerData.job
    local jobName = job.name
    local grade = job.grade and job.grade.name:lower() or 'cadet'
    local rankIdx = getRankIndex(jobName, grade)

    if jobName == 'ambulance' then
        local tier = {}
        for id, t in pairs(Config.EMSTiers) do
            if t.rankIndex <= rankIdx then
                tier = t
            end
        end
        return tier.weapons or {}, tier.items or {}
    end

    local tier = {}
    for id, t in pairs(Config.WeaponTiers) do
        if t.rankIndex <= rankIdx then
            tier = t
        end
    end
    return tier.weapons or {}, tier.items or {}
end

RegisterServerEvent('osven-armory:server:openArmory', function(armoryId)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local armory = Config.Armories[armoryId]
    if not armory then return end
    if player.PlayerData.job.name ~= armory.job then
        QBCore.Functions.Notify(src, 'Access denied', 'error')
        return
    end

    local weapons, items = getAvailableTier(player)
    TriggerClientEvent('osven-armory:client:openArmoryMenu', src, {
        label = armory.label,
        weapons = weapons,
        items = items,
    })
end)

RegisterServerEvent('osven-armory:server:takeWeapon', function(weapon)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not weapon then return end

    local weapons, _ = getAvailableTier(player)
    local found = false
    for _, w in ipairs(weapons) do
        if w.name == weapon.name then
            found = true
            break
        end
    end
    if not found then return end

    player.Functions.AddItem(weapon.name, 1)
    if weapon.ammo and weapon.ammo > 0 then
        -- Give ammo component
        TriggerClientEvent('QBCore:Notify', src, 'Received ' .. weapon.label, 'success')
    end
    exports['oxmysql']:execute('INSERT INTO osven_armory_log (citizenid, action, item, timestamp) VALUES (?, ?, ?, ?)', {
        player.PlayerData.citizenid, 'weapon', weapon.name, os.time()
    })
end)

RegisterServerEvent('osven-armory:server:takeItem', function(item)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player or not item then return end

    local _, items = getAvailableTier(player)
    local found = false
    for _, i in ipairs(items) do
        if i.name == item.name then
            found = true
            break
        end
    end
    if not found then return end

    player.Functions.AddItem(item.name, item.amount or 1)
    TriggerClientEvent('QBCore:Notify', src, 'Received ' .. item.label, 'success')

    exports['oxmysql']:execute('INSERT INTO osven_armory_log (citizenid, action, item, timestamp) VALUES (?, ?, ?, ?)', {
        player.PlayerData.citizenid, 'item', item.name, os.time()
    })
end)

-- Log uniform changes
RegisterServerEvent('osven-armory:server:logAction', function(action, detail)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    exports['oxmysql']:execute('INSERT INTO osven_armory_log (citizenid, action, item, timestamp) VALUES (?, ?, ?, ?)', {
        player.PlayerData.citizenid, action, detail, os.time()
    })
end)
