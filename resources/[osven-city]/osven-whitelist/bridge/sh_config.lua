Config = Config or {}

Config.Whitelist = {
    -- Discord bot token (required) — create a bot at https://discord.com/developers/applications
    BotToken = os.getenv('DISCORD_BOT_TOKEN') or '',

    -- Discord guild (server) ID
    GuildId = os.getenv('DISCORD_GUILD_ID') or '',

    -- Role ID(s) that are allowed to join (empty = any guild member)
    AllowedRoles = {},

    -- Map Discord role IDs → in-game permissions
    -- The bot will apply these ACE principals on connect
    -- Format: ['discord_role_id'] = { 'group.admin', 'qbcore.god' }
    RolePermissions = {
        -- ['your-admin-role-id'] = { 'group.admin', 'qbcore.admin' },
        -- ['your-mod-role-id']  = { 'group.mod',  'qbcore.mod' },
    },

    -- Kick messages
    Messages = {
        NotWhitelisted = 'You are not whitelisted on this server.\nJoin our Discord and apply: discord.gg/yourinvite',
        NotInGuild = 'You must join our Discord server first.\n discord.gg/yourinvite',
        ApiError = 'Could not verify whitelist status. Please try again later.',
        NoDiscord = 'You must have Discord open and linked to FiveM to join.'
    },

    -- Fail mode: true = let players in if Discord API is unreachable, false = block
    FailOpen = false,

    -- Enable debug logging
    Debug = false,
}
