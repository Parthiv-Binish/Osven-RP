local QBCore = exports['qb-core']:GetCoreObject()
local transferCooldown = {}

RegisterServerEvent('osven-banking:server:lookupRecipient', function(query)
    local src = source
    if not query or string.len(query) < 3 then return end

    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local players = QBCore.Functions.GetPlayers()
    for _, targetId in ipairs(players) do
        local target = QBCore.Functions.GetPlayer(targetId)
        if target then
            local cid = target.PlayerData.charinfo.citizenid
            local phone = target.PlayerData.charinfo.phone
            if cid and string.find(cid:lower(), query:lower()) or
               phone and string.find(phone, query) then
                local name = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
                TriggerClientEvent('osven-banking:client:lookupResult', src, name)
                return
            end
        end
    end
    TriggerClientEvent('osven-banking:client:lookupResult', src, '')
end)

RegisterServerEvent('osven-banking:server:transfer', function(recipient, amount, note)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local now = os.time()
    if transferCooldown[src] and now - transferCooldown[src] < 3 then
        TriggerClientEvent('osven-banking:client:transferResult', src, false, player.PlayerData.money['bank'], 'Please wait before next transfer')
        return
    end
    transferCooldown[src] = now

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('osven-banking:client:transferResult', src, false, player.PlayerData.money['bank'], 'Invalid amount')
        return
    end

    if amount > 100000 then
        TriggerClientEvent('osven-banking:client:transferResult', src, false, player.PlayerData.money['bank'], 'Transfer limit is $100,000')
        return
    end

    if player.PlayerData.money['bank'] < amount then
        TriggerClientEvent('osven-banking:client:transferResult', src, false, player.PlayerData.money['bank'], 'Insufficient funds')
        return
    end

    local targetPlayer = nil
    local players = QBCore.Functions.GetPlayers()
    for _, targetId in ipairs(players) do
        local target = QBCore.Functions.GetPlayer(targetId)
        if target then
            local cid = target.PlayerData.charinfo.citizenid
            local phone = target.PlayerData.charinfo.phone
            if cid and string.find(cid:lower(), recipient:lower()) or
               phone and string.find(phone, recipient) then
                targetPlayer = target
                break
            end
        end
    end

    if not targetPlayer then
        TriggerClientEvent('osven-banking:client:transferResult', src, false, player.PlayerData.money['bank'], 'Recipient not found')
        return
    end

    if tonumber(targetPlayer.PlayerData.source) == src then
        TriggerClientEvent('osven-banking:client:transferResult', src, false, player.PlayerData.money['bank'], 'Cannot transfer to yourself')
        return
    end

    player.Functions.RemoveMoney('bank', amount)
    targetPlayer.Functions.AddMoney('bank', amount)

    local targetName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
    TriggerClientEvent('QBCore:Notify', src, 'Transferred $' .. amount .. ' to ' .. targetName, 'success')
    TriggerClientEvent('QBCore:Notify', tonumber(targetPlayer.PlayerData.source), 'Received $' .. amount .. ' from ' .. player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname, 'success')

    TriggerClientEvent('osven-banking:client:transferResult', src, true, player.PlayerData.money['bank'])
end)

RegisterServerEvent('osven-banking:server:atm', function(action, amount)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    if transferCooldown[src] and os.time() - transferCooldown[src] < 1 then return end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('osven-banking:client:atmResult', src, false, player.PlayerData.money['cash'], player.PlayerData.money['bank'], 'Invalid amount')
        return
    end

    if amount > 10000 then
        TriggerClientEvent('osven-banking:client:atmResult', src, false, player.PlayerData.money['cash'], player.PlayerData.money['bank'], 'ATM limit is $10,000')
        return
    end

    if action == 'withdraw' then
        if player.PlayerData.money['bank'] < amount then
            TriggerClientEvent('osven-banking:client:atmResult', src, false, player.PlayerData.money['cash'], player.PlayerData.money['bank'], 'Insufficient funds')
            return
        end
        player.Functions.RemoveMoney('bank', amount)
        player.Functions.AddMoney('cash', amount)
        TriggerClientEvent('osven-banking:client:atmResult', src, true, player.PlayerData.money['cash'], player.PlayerData.money['bank'])
    elseif action == 'deposit' then
        if player.PlayerData.money['cash'] < amount then
            TriggerClientEvent('osven-banking:client:atmResult', src, false, player.PlayerData.money['cash'], player.PlayerData.money['bank'], 'Insufficient cash')
            return
        end
        player.Functions.RemoveMoney('cash', amount)
        player.Functions.AddMoney('bank', amount)
        TriggerClientEvent('osven-banking:client:atmResult', src, true, player.PlayerData.money['cash'], player.PlayerData.money['bank'])
    end
end)
