local QBCore = exports['qb-core']:GetCoreObject()

-- Create armory zones on all locations
Citizen.CreateThread(function()
    for id, armory in pairs(Config.Armories) do
        exports['ox_target']:addBoxZone({
            coords = armory.coords,
            size = vec3(2.0, 2.0, 2.0),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'armory_' .. id,
                    label = 'Open ' .. armory.label,
                    icon = 'fa-solid fa-vest',
                    onSelect = function()
                        TriggerServerEvent('osven-armory:server:openArmory', id)
                    end,
                    distance = 2.5,
                },
            },
        })
    end
end)

-- Open armory menu
RegisterNetEvent('osven-armory:client:openArmoryMenu', function(data)
    if not data or not data.weapons then return end

    local menuItems = {
        { header = data.label, isMenuHeader = true },
    }

    -- Add weapon section
    for _, weapon in ipairs(data.weapons) do
        table.insert(menuItems, {
            header = weapon.label,
            txt = 'Take ' .. weapon.label,
            params = {
                event = 'osven-armory:client:takeWeapon',
                args = weapon,
            },
        })
    end

    -- Add item section
    for _, item in ipairs(data.items) do
        table.insert(menuItems, {
            header = item.label,
            txt = 'Take x' .. (item.amount or 1),
            params = {
                event = 'osven-armory:client:takeItem',
                args = item,
            },
        })
    end

    exports['qb-menu']:openMenu(menuItems)
end)

-- Take weapon from armory
RegisterNetEvent('osven-armory:client:takeWeapon', function(weapon)
    TriggerServerEvent('osven-armory:server:takeWeapon', weapon)
end)

-- Take item from armory
RegisterNetEvent('osven-armory:client:takeItem', function(item)
    TriggerServerEvent('osven-armory:server:takeItem', item)
end)

-- Change uniform
RegisterNetEvent('osven-armory:client:changeUniform', function(uniformId)
    local uniform = Config.Uniforms[uniformId]
    if not uniform then return end

    local ped = PlayerPedId()
    for _, comp in ipairs(uniform.components) do
        SetPedComponentEnabled(ped, comp.id, comp.drawable, comp.texture)
    end
    TriggerServerEvent('osven-armory:server:logAction', 'uniform', uniform.label)
    QBCore.Functions.Notify('Uniform applied', 'success')
end)
