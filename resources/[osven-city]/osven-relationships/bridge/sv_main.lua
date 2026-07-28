local QBCore = exports['qb-core']:GetCoreObject()
local proposals = {}
local marriages = {}

-- Load marriages from database
local function loadMarriages()
    marriages = {}
    local rows = MySQL.query.await('SELECT id, spouse1, spouse2, ring_type, married_at FROM osven_relationships WHERE divorced = 0')
    if not rows then return end
    for _, row in ipairs(rows) do
        marriages[row.spouse1] = { id = row.id, spouse = row.spouse2, ring = row.ring_type, marriedAt = row.married_at }
        marriages[row.spouse2] = { id = row.id, spouse = row.spouse1, ring = row.ring_type, marriedAt = row.married_at }
    end
    print('[osven-relationships] Loaded ' .. #rows .. ' marriages')
end

-- Check if player is married
local function isMarried(citizenid)
    return marriages[citizenid] ~= nil
end

-- Get marriage data
local function getMarriage(citizenid)
    return marriages[citizenid]
end

-- Proposal logic
RegisterServerEvent('osven-relationships:server:propose', function(targetSrc)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local targetPlayer = QBCore.Functions.GetPlayer(targetSrc)
    if not player or not targetPlayer then return end

    local cid = player.PlayerData.citizenid
    local tCid = targetPlayer.PlayerData.citizenid

    if isMarried(cid) then
        TriggerClientEvent('QBCore:Notify', src, 'You are already married!', 'error')
        return
    end
    if isMarried(tCid) then
        TriggerClientEvent('QBCore:Notify', src, 'That player is already married!', 'error')
        return
    end

    -- Check if player has a ring
    local hasRing = false
    local ringType = nil
    for ringName, _ in pairs(Config.Rings) do
        if exports['osven-inventory-bridge']:HasItem(src, ringName, 1) then
            hasRing = true
            ringType = ringName
            break
        end
    end
    if not hasRing then
        TriggerClientEvent('QBCore:Notify', src, 'You need an engagement ring!', 'error')
        return
    end

    -- Check cooldown on recent proposal
    if proposals[src] and proposals[src].cooldown and GetGameTimer() < proposals[src].cooldown then
        TriggerClientEvent('QBCore:Notify', src, 'Please wait before proposing again', 'error')
        return
    end

    -- Send proposal
    proposals[src] = { target = targetSrc, ring = ringType, cooldown = GetGameTimer() + 30000 }

    TriggerClientEvent('osven-relationships:client:receiveProposal', targetSrc, {
        from = src,
        fromName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        ring = ringType,
    })
    TriggerClientEvent('QBCore:Notify', src, 'Proposal sent!', 'success')
end)

-- Accept proposal
RegisterServerEvent('osven-relationships:server:acceptProposal', function(proposerSrc)
    local src = source
    local targetPlayer = QBCore.Functions.GetPlayer(src)
    local player = QBCore.Functions.GetPlayer(proposerSrc)
    if not targetPlayer or not player then return end

    if not proposals[proposerSrc] or proposals[proposerSrc].target ~= src then
        TriggerClientEvent('QBCore:Notify', src, 'No active proposal found', 'error')
        return
    end

    local cid = player.PlayerData.citizenid
    local tCid = targetPlayer.PlayerData.citizenid
    local ringType = proposals[proposerSrc].ring

    -- Remove ring from proposer
    exports['osven-inventory-bridge']:RemoveItem(proposerSrc, ringType, 1)

    -- Create marriage
    local result = MySQL.insert.await('INSERT INTO osven_relationships (spouse1, spouse2, ring_type) VALUES (?, ?, ?)', {
        cid, tCid, ringType
    })

    if not result then
        TriggerClientEvent('QBCore:Notify', src, 'Failed to create marriage', 'error')
        return
    end

    marriages[cid] = { id = result, spouse = tCid, ring = ringType, marriedAt = os.time() }
    marriages[tCid] = { id = result, spouse = cid, ring = ringType, marriedAt = os.time() }
    proposals[proposerSrc] = nil

    local pName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local tName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname

    TriggerClientEvent('QBCore:Notify', proposerSrc, tName .. ' accepted your proposal! You are now married!', 'success')
    TriggerClientEvent('QBCore:Notify', src, 'You accepted ' .. pName .. '\'s proposal! You are now married!', 'success')
    TriggerClientEvent('osven-relationships:client:updateMarriageStatus', proposerSrc, { married = true, spouse = tCid, spouseName = tName })
    TriggerClientEvent('osven-relationships:client:updateMarriageStatus', src, { married = true, spouse = cid, spouseName = pName })

    TriggerEvent('osven-logging:server:sendLog', 'economy', {
        message = 'Marriage',
        fields = {
            { label = 'Spouse 1', value = pName .. ' (' .. cid .. ')', icon = 0 },
            { label = 'Spouse 2', value = tName .. ' (' .. tCid .. ')', icon = 0 },
            { label = 'Ring', value = ringType, icon = 0 },
        }
    })
end)

-- Decline proposal
RegisterServerEvent('osven-relationships:server:declineProposal', function(proposerSrc)
    local src = source
    local targetPlayer = QBCore.Functions.GetPlayer(src)
    local player = QBCore.Functions.GetPlayer(proposerSrc)
    if not targetPlayer or not player then return end

    if not proposals[proposerSrc] or proposals[proposerSrc].target ~= src then
        return
    end

    proposals[proposerSrc] = nil
    TriggerClientEvent('QBCore:Notify', proposerSrc, targetPlayer.PlayerData.charinfo.firstname .. ' declined your proposal', 'error')
    TriggerClientEvent('QBCore:Notify', src, 'You declined the proposal', 'primary')
end)

-- Divorce
RegisterServerEvent('osven-relationships:server:divorce', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local cid = player.PlayerData.citizenid
    local marriage = getMarriage(cid)
    if not marriage then
        TriggerClientEvent('QBCore:Notify', src, 'You are not married!', 'error')
        return
    end

    -- Check balance
    local cash = player.PlayerData.money.cash or 0
    local bank = player.PlayerData.money.bank or 0
    if cash + bank < Config.DivorcePrice then
        TriggerClientEvent('QBCore:Notify', src, 'You need $' .. Config.DivorcePrice .. ' to file for divorce', 'error')
        return
    end

    -- Take money from cash first, then bank
    local remaining = Config.DivorcePrice
    if cash >= remaining then
        player.Functions.RemoveMoney('cash', remaining)
    else
        player.Functions.RemoveMoney('cash', cash)
        remaining = remaining - cash
        player.Functions.RemoveMoney('bank', remaining)
    end

    MySQL.update('UPDATE osven_relationships SET divorced = 1, divorced_at = CURRENT_TIMESTAMP WHERE id = ?', { marriage.id })

    local spouseCid = marriage.spouse
    marriages[cid] = nil
    marriages[spouseCid] = nil

    TriggerClientEvent('QBCore:Notify', src, 'You are now divorced.', 'primary')

    -- Notify spouse if online
    for _, playerData in pairs(QBCore.Functions.GetQBPlayers()) do
        if playerData.PlayerData.citizenid == spouseCid then
            TriggerClientEvent('QBCore:Notify', playerData.PlayerData.source, 'Your spouse filed for divorce.', 'error')
            TriggerClientEvent('osven-relationships:client:updateMarriageStatus', playerData.PlayerData.source, { married = false })
        end
    end
    TriggerClientEvent('osven-relationships:client:updateMarriageStatus', src, { married = false })

    TriggerEvent('osven-logging:server:sendLog', 'economy', {
        message = 'Divorce',
        fields = {
            { label = 'Citizen', value = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname .. ' (' .. cid .. ')', icon = 0 },
            { label = 'Ex-Spouse', value = spouseCid, icon = 0 },
            { label = 'Fee', value = '$' .. Config.DivorcePrice, icon = 0 },
        }
    })
end)

-- Get spouse info
lib.callback.register('osven-relationships:client:getMarriage', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return nil end
    return getMarriage(player.PlayerData.citizenid)
end)

-- ============ Exports ============

exports('IsMarried', isMarried)
exports('GetMarriage', getMarriage)
exports('GetSpouse', function(citizenid)
    local m = getMarriage(citizenid)
    return m and m.spouse or nil
end)

-- ============ Init ============

AddEventHandler('onServerResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        loadMarriages()
    end
end)
