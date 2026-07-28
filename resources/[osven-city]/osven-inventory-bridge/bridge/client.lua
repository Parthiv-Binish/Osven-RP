local ox_inventory = exports.ox_inventory

-- ============ QB-Inventory Compat Client Exports ============

-- qb-inventory:client:GetItemByName
exports('GetItemByName', function(itemName)
    return ox_inventory:GetItem(itemName)
end)

-- qb-inventory:client:GetInventory
exports('GetInventory', function()
    return ox_inventory:GetInventoryItems()
end)

-- qb-inventory:client:HasItem
exports('HasItem', function(itemName, amount)
    local item = ox_inventory:GetItem(itemName)
    if not item then return false end
    if amount then return item.count >= amount end
    return item.count > 0
end)

-- qb-inventory:client:GetItemCount
exports('GetItemCount', function(itemName)
    local item = ox_inventory:GetItem(itemName)
    return item and item.count or 0
end)

-- qb-inventory:client:openInventory
exports('OpenInventory', function(type, data)
    if type == 'stash' then
        ox_inventory:openInventory('stash', data.id)
    elseif type == 'shop' then
        ox_inventory:openInventory('shop', data.id, data)
    elseif type == 'crafting' then
        ox_inventory:openInventory('crafting', data.id)
    elseif type == 'drop' then
        ox_inventory:openInventory('drop', data.id)
    end
end)

-- ============ Client Events ============

RegisterNetEvent('inventory:client:UseItem', function(itemName)
    ox_inventory:UseItem(itemName)
end)

RegisterNetEvent('inventory:client:SetCurrentItem', function(itemData)
    -- qb-inventory internal state; no-op for compat
end)

-- Intercept qb-inventory use-item events and redirect
RegisterNetEvent('qb-inventory:client:UseItem', function(itemName)
    ox_inventory:UseItem(itemName)
end)

-- ============ Radio Item Use Handler ============

ox_inventory:registerUse('radio', function()
    TriggerEvent('osven-radio:client:useRadio')
end)

-- ============ Client Commands ============

RegisterCommand('inventory', function()
    ox_inventory:openInventory('player')
end, false)

RegisterKeyMapping('inventory', 'Open Inventory', 'keyboard', 'TAB')
