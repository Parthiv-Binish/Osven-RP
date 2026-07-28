local QBCore = exports['qb-core']:GetCoreObject()
local BotToken = Config.Whitelist.BotToken
local GuildId = Config.Whitelist.GuildId
local AllowedRoles = Config.Whitelist.AllowedRoles
local RolePermissions = Config.Whitelist.RolePermissions
local Debug = Config.Whitelist.Debug

local function log(msg, level)
    level = level or 'info'
    if Debug or level == 'error' then
        print(('[osven-whitelist] [%s] %s'):format(level:upper(), msg))
    end
    if exports['osven-logging'] then
        exports['osven-logging']:sendLog('admin', ('Whitelist %s'):format(level:upper()), msg, level)
    end
end

local function fetch(url, cb)
    PerformHttpRequest(url, function(code, res, headers)
        cb(code, res and json.decode(res) or nil)
    end, 'GET', '', { ['Authorization'] = 'Bot ' .. BotToken, ['Content-Type'] = 'application/json' })
end

local function getDiscordId(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find('discord:') then
            return id:gsub('discord:', '')
        end
    end
    return nil
end

-- Tracks which principals have been granted per license so we can revoke on reconnect
local grantedPermissions = {}

local function revokeAllPermissions(license)
    local granted = grantedPermissions[license]
    if not granted then return end
    for _, principal in ipairs(granted) do
        ExecuteCommand(('remove_principal %s %s'):format(license, principal))
    end
    grantedPermissions[license] = nil
end

local function applyPermissions(source, discordId, roles)
    if not RolePermissions or next(RolePermissions) == nil then return end
    local license
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find('license:') then
            license = id
            break
        end
    end
    if not license then
        log(('No license found for %s — cannot apply permissions'):format(discordId), 'warn')
        return
    end

    -- Clear any previously granted permissions for this player
    revokeAllPermissions(license)

    -- Apply current Discord role-based permissions
    local granted = {}
    for _, roleId in ipairs(roles) do
        local principals = RolePermissions[roleId]
        if principals then
            for _, principal in ipairs(principals) do
                ExecuteCommand(('add_principal %s %s'):format(license, principal))
                table.insert(granted, principal)
                log(('Granted %s → %s (role %s)'):format(discordId, principal, roleId))
            end
        end
    end
    grantedPermissions[license] = granted
end

-- Allow players to refresh their Discord permissions without reconnecting
RegisterCommand('refreshdiscord', function(source)
    if source == 0 then return end
    local discordId
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find('discord:') then discordId = id:gsub('discord:', ''); break end
    end
    if not discordId then
        TriggerClientEvent('QBCore:Notify', source, 'No Discord linked', 'error')
        return
    end
    local url = ('https://discord.com/api/v10/guilds/%s/members/%s'):format(GuildId, discordId)
    fetch(url, function(code, data)
        if code == 200 and data then
            applyPermissions(source, discordId, data.roles or {})
            TriggerClientEvent('QBCore:Notify', source, 'Discord permissions refreshed', 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Could not refresh Discord permissions', 'error')
        end
    end)
end, false)

local function checkWhitelist(source, discordId, cb)
    local url = ('https://discord.com/api/v10/guilds/%s/members/%s'):format(GuildId, discordId)

    fetch(url, function(code, data)
        if code == 200 and data then
            local userRoles = data.roles or {}

            if #AllowedRoles > 0 then
                local hasRole = false
                for _, roleId in ipairs(AllowedRoles) do
                    for _, userRole in ipairs(userRoles) do
                        if userRole == roleId then
                            hasRole = true
                            break
                        end
                    end
                    if hasRole then break end
                end
                if not hasRole then
                    log(('Whitelist denied: %s (no matching role)'):format(discordId))
                    cb(false, 'role')
                    return
                end
            end

            log(('Whitelist approved: %s'):format(discordId))
            applyPermissions(source, discordId, userRoles)
            cb(true)
        elseif code == 404 then
            log(('Whitelist denied: %s (not in guild)'):format(discordId))
            cb(false, 'guild')
        else
            log(('Discord API error: HTTP %s for %s'):format(tostring(code), discordId), 'error')
            cb(nil)
        end
    end)
end

AddEventHandler('playerConnecting', function(name, kickCb, deferrals)
    local src = source
    deferrals.defer()

    local discordId = getDiscordId(src)
    if not discordId then
        deferrals.done(Config.Whitelist.Messages.NoDiscord)
        return
    end

    deferrals.update('Verifying Discord whitelist...')

    checkWhitelist(src, discordId, function(allowed, reason)
        if allowed == true then
            deferrals.done()
        elseif allowed == false then
            local msg = reason == 'role' and Config.Whitelist.Messages.NotWhitelisted or Config.Whitelist.Messages.NotInGuild
            deferrals.done(msg)
        else
            if Config.Whitelist.FailOpen then
                log(('Fail-open: allowing %s despite API error'):format(discordId), 'warn')
                deferrals.done()
            else
                deferrals.done(Config.Whitelist.Messages.ApiError)
            end
        end
    end)
end)

AddEventHandler('onServerResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end

    if BotToken == '' or GuildId == '' then
        log('BotToken or GuildId not configured — whitelist disabled', 'warn')
        return
    end

    local roleCount = 0; for _ in pairs(RolePermissions or {}) do roleCount = roleCount + 1 end
    log(('Loaded (guild: %s, whitelist-roles: %s, permission-mappings: %d)'):format(
        GuildId,
        #AllowedRoles > 0 and table.concat(AllowedRoles, ', ') or 'any',
        roleCount
    ))
end)

RegisterCommand('reloadwhitelist', function(source)
    if source > 0 then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player or not IsPlayerAceAllowed(source, 'command.reloadwhitelist') then
            if Player then TriggerClientEvent('QBCore:Notify', source, 'No permission', 'error') end
            return
        end
    end
    BotToken = Config.Whitelist.BotToken
    GuildId = Config.Whitelist.GuildId
    AllowedRoles = Config.Whitelist.AllowedRoles
    RolePermissions = Config.Whitelist.RolePermissions
    log('Configuration reloaded')
    if source > 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Whitelist config reloaded', 'success')
    end
end, true)

AddEventHandler('onServerResourceStart', function(res)
    if GetResourceState('qb-core') == 'started' then
        ExecuteCommand('add_ace command.reloadwhitelist group.admin allow')
    end
end)
