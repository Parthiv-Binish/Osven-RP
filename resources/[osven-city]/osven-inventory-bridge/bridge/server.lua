local ox_inventory = exports.ox_inventory

-- Returns a list of items in the player's inventory
---@param source number
---@return table
lib.callback.register('osven-inventory:server:getInventory', function(source)
    local items = ox_inventory:GetInventoryItems(source)
    return items or {}
end)

-- Check if player has an item
---@param source number
---@param itemName string
---@param amount? number
---@return boolean
lib.callback.register('osven-inventory:server:hasItem', function(source, itemName, amount)
    local count = ox_inventory:GetItemCount(source, itemName)
    if amount then
        return count >= amount
    end
    return count > 0
end)

-- Add item to player
---@param source number
---@param itemName string
---@param amount number
---@param metadata? table
---@return boolean
lib.callback.register('osven-inventory:server:addItem', function(source, itemName, amount, metadata)
    return ox_inventory:AddItem(source, itemName, amount, metadata)
end)

-- Remove item from player
---@param source number
---@param itemName string
---@param amount number
---@param metadata? table
---@return boolean
lib.callback.register('osven-inventory:server:removeItem', function(source, itemName, amount, metadata)
    return ox_inventory:RemoveItem(source, itemName, amount, metadata)
end)

-- Get total item count
---@param source number
---@param itemName string
---@return number
lib.callback.register('osven-inventory:server:getItemCount', function(source, itemName)
    return ox_inventory:GetItemCount(source, itemName)
end)

-- Get item metadata (returns first matching slot)
---@param source number
---@param itemName string
---@return table|nil
lib.callback.register('osven-inventory:server:getItemByMetadata', function(source, itemName, metadata)
    local items = ox_inventory:Search(source, 'slots', itemName, metadata)
    if items and #items > 0 then
        return items[1]
    end
    return nil
end)

-- Open stash
-- source is passed as 0 for server-triggered
function OpenStash(source, stashId, label, slots, weight)
    ox_inventory:OpenInventory(source, 'stash', stashId, {
        label = label,
        slots = slots,
        weight = weight
    })
end

-- Open glovebox
function OpenGlovebox(source, plate)
    ox_inventory:OpenInventory(source, 'glovebox', plate)
end

-- Open trunk
function OpenTrunk(source, plate)
    ox_inventory:OpenInventory(source, 'trunk', plate)
end

-- Open evidence locker
function OpenEvidenceLocker(source, lockerId)
    ox_inventory:OpenInventory(source, 'stash', 'evidence_' .. lockerId)
end

-- ============ QB-Inventory Compat Exports ============

-- qb-inventory:server:GetInventory
lib.callback.register('inventory:server:GetInventory', function(source)
    return ox_inventory:GetInventoryItems(source)
end)

-- qb-inventory:server:AddItem
lib.callback.register('inventory:server:AddItem', function(source, itemName, amount, _, metadata)
    return ox_inventory:AddItem(source, itemName, amount, metadata)
end)

-- qb-inventory:server:RemoveItem
lib.callback.register('inventory:server:RemoveItem', function(source, itemName, amount, _, metadata)
    return ox_inventory:RemoveItem(source, itemName, amount, metadata)
end)

-- qb-inventory:server:GetItemByName
lib.callback.register('inventory:server:GetItemByName', function(source, itemName)
    local count = ox_inventory:GetItemCount(source, itemName)
    if count > 0 then
        return { name = itemName, count = count }
    end
    return nil
end)

-- qb-inventory:server:GetItemBySlot
lib.callback.register('inventory:server:GetItemBySlot', function(source, slot)
    local items = ox_inventory:GetInventoryItems(source)
    for _, item in pairs(items) do
        if item.slot == slot then
            return item
        end
    end
    return nil
end)

-- qb-inventory:server:GetItemsByType
lib.callback.register('inventory:server:GetItemsByType', function(source, itemType)
    local items = ox_inventory:GetInventoryItems(source)
    local filtered = {}
    for _, item in pairs(items) do
        if item.type == itemType then
            table.insert(filtered, item)
        end
    end
    return filtered
end)

-- qb-inventory:server:UsedItem
lib.callback.register('inventory:server:UsedItem', function(source, itemName)
    local count = ox_inventory:GetItemCount(source, itemName)
    return count > 0
end)

-- qb-inventory:server:HasItem
lib.callback.register('inventory:server:HasItem', function(source, items, amount)
    for _, item in pairs(items) do
        local itemType = type(item)
        if itemType == 'string' then
            local c = ox_inventory:GetItemCount(source, item)
            if amount and c < amount then return false end
            if not amount and c <= 0 then return false end
        elseif itemType == 'table' then
            if item.amount then
                local c = ox_inventory:GetItemCount(source, item.name or item.item)
                if c < item.amount then return false end
            else
                local c = ox_inventory:GetItemCount(source, item.name or item.item)
                if c <= 0 then return false end
            end
        end
    end
    return true
end)

-- qb-inventory:server:GetInventoryByName (deprecated in qb, but some resources call it)
lib.callback.register('inventory:server:GetInventoryByName', function(source, itemName)
    local count = ox_inventory:GetItemCount(source, itemName)
    if count > 0 then
        -- Return a minimal item object for backwards compat
        local info = ox_inventory:GetItem(source, itemName)
        if info then
            return {
                name = itemName,
                count = count,
                label = info.label or itemName,
                weight = info.weight or 0,
                slot = info.slot or 1
            }
        end
    end
    return nil
end)

-- qb-inventory:server:CanReceiveItem (check container space)
lib.callback.register('inventory:server:CanReceiveItem', function(source, itemName, count)
    return ox_inventory:CanCarryItem(source, itemName, count)
end)

-- ============ Server Exports (called from other resources) ============

exports('HasItem', function(source, itemName, amount)
    local count = ox_inventory:GetItemCount(source, itemName)
    if amount then return count >= amount end
    return count > 0
end)

exports('GetItemCount', function(source, itemName)
    return ox_inventory:GetItemCount(source, itemName)
end)

exports('AddItem', function(source, itemName, amount, metadata)
    return ox_inventory:AddItem(source, itemName, amount, metadata)
end)

exports('RemoveItem', function(source, itemName, amount, metadata)
    return ox_inventory:RemoveItem(source, itemName, amount, metadata)
end)

exports('GetInventory', function(source)
    return ox_inventory:GetInventoryItems(source)
end)

exports('OpenStash', function(source, stashId, label, slots, weight)
    ox_inventory:OpenInventory(source, 'stash', stashId, {
        label = label,
        slots = slots,
        weight = weight
    })
end)

exports('OpenGlovebox', function(source, plate)
    ox_inventory:OpenInventory(source, 'glovebox', plate)
end)

exports('OpenTrunk', function(source, plate)
    ox_inventory:OpenInventory(source, 'trunk', plate)
end)

-- ============ Item Registration ============

local itemsRegistered = false
local function registerItems()
    if itemsRegistered then return end
    itemsRegistered = true

    -- Osven City item definitions
    local osvenItems = {
        -- Food & Drink
        ['water_bottle'] = { label = 'Water Bottle', weight = 500, stack = true, close = true, description = 'Clean drinking water' },
        ['taco'] = { label = 'Taco', weight = 250, stack = true, close = true, description = 'A delicious taco' },
        ['sandwich'] = { label = 'Sandwich', weight = 200, stack = true, close = true, description = 'Fresh sandwich' },
        ['burger'] = { label = 'Burger', weight = 220, stack = true, close = true, description = 'Juicy burger' },
        ['cola'] = { label = 'Cola', weight = 350, stack = true, close = true, description = 'Refreshing cola' },
        ['coffee'] = { label = 'Coffee', weight = 250, stack = true, close = true, description = 'Hot coffee' },

        -- Medical
        ['bandage'] = { label = 'Bandage', weight = 100, stack = true, close = true, description = 'Basic wound dressing' },
        ['firstaid'] = { label = 'First Aid Kit', weight = 500, stack = true, close = true, description = 'Emergency medical kit' },
        ['painkillers'] = { label = 'Painkillers', weight = 100, stack = true, close = true, description = 'Over-the-counter pain relief' },
        ['antibiotic'] = { label = 'Antibiotics', weight = 100, stack = true, close = true, description = 'Fights infection' },
        ['morphine'] = { label = 'Morphine', weight = 50, stack = true, close = true, description = 'Strong painkiller - prescription only' },
        ['suturekit'] = { label = 'Suture Kit', weight = 200, stack = true, close = true, description = 'For closing deep wounds' },
        ['defib'] = { label = 'Defibrillator', weight = 2000, stack = false, close = true, description = 'Restart a stopped heart' },

        -- Tools & Items
        ['lockpick'] = { label = 'Lockpick', weight = 50, stack = true, close = true, description = 'For picking locks' },
        ['screwdriver'] = { label = 'Screwdriver', weight = 100, stack = true, close = true, description = 'Multi-purpose tool' },
        ['phone'] = { label = 'Phone', weight = 200, stack = false, close = true, description = 'Mobile phone' },
        ['id_card'] = { label = 'ID Card', weight = 10, stack = false, close = true, description = 'Citizen identification card' },
        ['driver_license'] = { label = 'Driving License', weight = 10, stack = false, close = true, description = 'Driving permit' },
        ['weapon_license'] = { label = 'Weapon License', weight = 10, stack = false, close = true, description = 'Firearms permit' },

        -- Crafting Materials
        ['metalscrap'] = { label = 'Metal Scrap', weight = 200, stack = true, close = true, description = 'Scrap metal for crafting' },
        ['plastic'] = { label = 'Plastic', weight = 100, stack = true, close = true, description = 'Plastic material' },
        ['copper'] = { label = 'Copper Wire', weight = 150, stack = true, close = true, description = 'Copper wiring' },
        ['steel'] = { label = 'Steel', weight = 500, stack = true, close = true, description = 'Steel alloy' },
        ['aluminum'] = { label = 'Aluminum', weight = 300, stack = true, close = true, description = 'Lightweight aluminum' },
        ['rubber'] = { label = 'Rubber', weight = 100, stack = true, close = true, description = 'Synthetic rubber' },

        -- Drugs
        ['weed_leaf'] = { label = 'Weed Leaf', weight = 50, stack = true, close = true, description = 'Dried cannabis leaf' },
        ['weed_bag'] = { label = 'Weed Bag', weight = 25, stack = true, close = true, description = 'Ready for sale' },
        ['coke_brick'] = { label = 'Cocaine Brick', weight = 1000, stack = false, close = true, description = 'Compressed cocaine' },
        ['coke_bag'] = { label = 'Cocaine Bag', weight = 25, stack = true, close = true, description = 'Ready for sale' },
        ['meth_bag'] = { label = 'Meth Bag', weight = 25, stack = true, close = true, description = 'Crystal methamphetamine' },

        -- Black Market
        ['hacker_device'] = { label = 'Hacker Device', weight = 500, stack = false, close = true, description = 'Advanced electronic device' },
        ['drill'] = { label = 'Drill', weight = 2000, stack = false, close = true, description = 'Heavy-duty power drill' },
        ['gold_bar'] = { label = 'Gold Bar', weight = 1000, stack = true, close = true, description = 'Precious gold bullion' },
        ['diamond'] = { label = 'Diamond', weight = 10, stack = true, close = true, description = 'Precious diamond' },
        ['rolex'] = { label = 'Rolex', weight = 100, stack = false, close = true, description = 'Luxury watch' },
        ['goldchain'] = { label = 'Gold Chain', weight = 200, stack = false, close = true, description = 'Gold chain necklace' },
        ['billscrate'] = { label = 'Cash Crate', weight = 5000, stack = false, close = true, description = 'Crate of marked bills' },
        ['wetbillevidence'] = { label = 'Wet Bill Evidence', weight = 100, stack = false, close = true, description = 'Evidence bag with wet bills' },

        -- Police
        ['police_stormram'] = { label = 'Stormram', weight = 5000, stack = false, close = true, description = 'Heavy battering ram' },
        ['police_evidencebag'] = { label = 'Evidence Bag', weight = 50, stack = true, close = true, description = 'Sealable evidence bag' },
        ['police_radio'] = { label = 'Police Radio', weight = 300, stack = false, close = true, description = 'Police communication radio' },
        ['police_cuff'] = { label = 'Handcuffs', weight = 200, stack = true, close = true, description = 'Restraint device' },

        -- EMS
        ['ems_radio'] = { label = 'EMS Radio', weight = 300, stack = false, close = true, description = 'EMS communication radio' },
        ['ems_bag'] = { label = 'Medical Bag', weight = 1500, stack = false, close = true, description = 'Advanced medical supplies' },
        ['ems_stretcher'] = { label = 'Stretcher', weight = 5000, stack = false, close = true, description = 'Collapsible stretcher' },

        -- Misc
        ['repairkit'] = { label = 'Repair Kit', weight = 1000, stack = true, close = true, description = 'Basic vehicle repair tools' },
        ['advancedrepairkit'] = { label = 'Advanced Repair Kit', weight = 2000, stack = true, close = true, description = 'Professional repair tools' },
        ['cleaningkit'] = { label = 'Cleaning Kit', weight = 500, stack = true, close = true, description = 'Vehicle cleaning supplies' },
        ['tirekit'] = { label = 'Tire Kit', weight = 1000, stack = true, close = true, description = 'Spare tire and tools' },
        ['harness'] = { label = 'Racing Harness', weight = 500, stack = false, close = true, description = '5-point racing harness' },
        ['nitrous'] = { label = 'Nitrous Oxide', weight = 1000, stack = false, close = true, description = 'NOS boost' },
        ['nabox'] = { label = 'NA Box', weight = 1000, stack = false, close = true, description = 'Performance parts box' },

        -- Rings
        ['gold_ring'] = { label = 'Gold Ring', weight = 10, stack = false, close = true, description = 'A simple gold engagement band' },
        ['diamond_ring'] = { label = 'Diamond Ring', weight = 10, stack = false, close = true, description = 'A gold ring with a small diamond' },
        ['platinum_ring'] = { label = 'Platinum Ring', weight = 10, stack = false, close = true, description = 'Premium platinum ring with diamonds' },
    }

    for itemName, itemData in pairs(osvenItems) do
        ox_inventory:RegisterItem(itemName, itemData)
    end

    local count = 0; for _ in pairs(osvenItems) do count = count + 1 end
    print('[osven-inventory-bridge] ' .. count .. ' items registered.')
end

AddEventHandler('onServerResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        registerItems()
    end
end)
