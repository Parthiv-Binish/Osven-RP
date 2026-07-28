local currentZone = nil
local territoryBlips = {}
local ownedTerritories = {}
local captureActive = false

-- Request territory data from server
local function fetchTerritories()
    ownedTerritories = lib.callback.await('osven-gangs:client:getTerritories', false)
end

-- Create minimap blips for all territories
local function createBlips()
    for _, blip in pairs(territoryBlips) do
        RemoveBlip(blip)
    end
    territoryBlips = {}

    for zoneId, data in pairs(ownedTerritories) do
        local gangConfig = Config.Gangs[data.owner]
        if gangConfig then
            local blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
            SetBlipSprite(blip, 9)
            SetBlipColour(blip, GetBlipColourFromGang(data.owner))
            SetBlipAlpha(blip, 100)
            SetBlipAsShortRange(blip, true)
            territoryBlips[zoneId] = blip

            local labelBlip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
            SetBlipSprite(labelBlip, 162)
            SetBlipColour(labelBlip, GetBlipColourFromGang(data.owner))
            SetBlipScale(labelBlip, 0.8)
            SetBlipAsShortRange(labelBlip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(data.label .. ' (' .. gangConfig.label .. ')')
            EndTextCommandSetBlipName(labelBlip)
            territoryBlips['label_' .. zoneId] = labelBlip
        end
    end
end

-- Map gang name to blip colour
function GetBlipColourFromGang(gang)
    local colours = {
        ['lostmc']   = 1,    -- Red
        ['ballas']   = 38,   -- Purple
        ['vagos']    = 66,   -- Yellow
        ['cartel']   = 5,    -- Teal
        ['families'] = 2,    -- Green
        ['triads']   = 17,   -- Dark Red
    }
    return colours[gang] or 3
end

-- Get gang colour as RGB for text
local function getGangRGB(gang)
    local colours = {
        ['lostmc']   = { r = 194, g = 59,  b = 59  },
        ['ballas']   = { r = 139, g = 58,  b = 139 },
        ['vagos']    = { r = 232, g = 163, b = 61  },
        ['cartel']   = { r = 47,  g = 182, b = 166 },
        ['families'] = { r = 58,  g = 139, b = 58  },
        ['triads']   = { r = 232, g = 61,  b = 61  },
    }
    return colours[gang] or { r = 255, g = 255, b = 255 }
end

-- Zone tracking
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local playerGang = QBCore.Functions.GetPlayerData().gang

        local closestZone = nil
        local closestDist = math.huge

        for zoneId, zoneConfig in pairs(Config.Territories) do
            local dist = #(coords - zoneConfig.coords)
            if dist <= zoneConfig.radius then
                if dist < closestDist then
                    closestZone = zoneId
                    closestDist = dist
                end
            end
        end

        if closestZone ~= currentZone then
            currentZone = closestZone
            SendNUIMessage({
                action = 'updateZone',
                zone = closestZone,
                zoneLabel = closestZone and Config.Territories[closestZone].label or nil,
                owner = closestZone and ownedTerritories[closestZone] and ownedTerritories[closestZone].owner or nil,
            })

            if closestZone then
                local config = Config.Territories[closestZone]
                local owner = ownedTerritories[closestZone] and ownedTerritories[closestZone].owner
                local ownerLabel = owner and Config.Gangs[owner] and Config.Gangs[owner].label or 'Unowned'
                local rgb = getGangRGB(owner)
                SetTextFont(4)
                SetTextScale(0.0, 0.45)
                SetTextColour(rgb.r, rgb.g, rgb.b, 255)
                SetTextOutline()
                SetTextCentre(true)
                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentString(config.label .. ' | ' .. ownerLabel)
                EndTextCommandDisplayHelp(0, false, false, -1)
            end
        end

        if currentZone then
            local config = Config.Territories[currentZone]
            local dist = #(coords - config.coords)
            if dist > config.radius + 10 then
                currentZone = nil
                SendNUIMessage({
                    action = 'updateZone',
                    zone = nil,
                })
            end
        end
    end
end)

-- Refresh blips periodically and on capture events
RegisterNetEvent('osven-gangs:client:refreshTerritories', function()
    fetchTerritories()
    createBlips()
end)

-- Initial fetch
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    fetchTerritories()
    Citizen.Wait(2000)
    createBlips()
end)

-- Refresh on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.Wait(3000)
        fetchTerritories()
        createBlips()
    end
end)
