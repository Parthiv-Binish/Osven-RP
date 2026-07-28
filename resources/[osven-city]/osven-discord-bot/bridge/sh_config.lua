Config = Config or {}

Config.DiscordBot = {
    -- Webhook URL where the Discord bot listens for in-game events
    WebhookUrl = '',

    -- Secret key shared between the server and the Discord bot
    Secret = '',

    -- Events to send to Discord
    Events = {
        JoinLeave = true,
        Reports = true,
        StaffActions = true,
        Bans = true,
    },

    Debug = false,
}
