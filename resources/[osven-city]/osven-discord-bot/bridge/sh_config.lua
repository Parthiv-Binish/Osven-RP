Config = Config or {}

Config.DiscordBot = {
    -- Webhook URL where the Discord bot listens for in-game events
    WebhookUrl = os.getenv('WEBHOOK_URL') or 'http://localhost:25461',

    -- Secret key shared between the server and the Discord bot (must match config.js)
    Secret = os.getenv('WEBHOOK_SECRET') or 'osven-webhook-secret-change-me',

    -- Events to send to Discord
    Events = {
        JoinLeave = true,
        Reports = true,
        StaffActions = true,
        Bans = true,
    },

    Debug = false,
}
