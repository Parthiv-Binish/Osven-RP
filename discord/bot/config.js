module.exports = {
    // Discord bot token
    token: process.env.DISCORD_BOT_TOKEN || '',

    // Discord guild (server) ID
    guildId: process.env.DISCORD_GUILD_ID || '',

    // Cfx.re server ID for stats
    serverId: '',

    // ======================== WHITELIST APPLICATIONS ========================
    applications: {
        enabled: true,
        channelId: '',              // Channel where new application embeds appear for admin review
        approvedRoleId: '',          // Role to assign on whitelist approval
        staffRoleIds: [],            // Roles that can review applications
        cooldownDays: 7,             // Days before a rejected user can re-apply
    },

    // ======================== SUPPORT TICKETS ========================
    tickets: {
        enabled: true,
        categoryId: '',              // Category where ticket channels are created
        staffRoleIds: [],            // Roles that can see/manage all tickets
        logChannelId: '',            // Channel for ticket transcripts/logs
    },

    // ======================== JOB APPLICATIONS ========================
    jobs: {
        enabled: true,
        channelId: '',               // Channel where job application embeds appear
        staffRoleIds: [],            // Roles that review job apps
        // Available job types shown to applicants
        types: ['Police', 'EMS', 'Mechanic', 'Real Estate', 'News'],
    },

    // ======================== BAN LOGGING ========================
    bans: {
        enabled: true,
        channelId: '',               // Channel for regular ban notifications
        wallOfShameChannelId: '',    // Channel for permanent bans (styled embed)
        permBanThreshold: 0,         // Ban duration in ms above which it's "permanent" (0 = all bans to wall)
    },

    // ======================== SERVER STATS ========================
    stats: {
        channelId: '',               // Voice channel for player count
        updateInterval: 60000,       // Update interval (ms)
        channelName: 'Players: {current}/{max}',
        offlineName: '🔴 Server Offline',
    },

    // ======================== TEMP VOICE CHANNELS ========================
    tempVoice: {
        joinToCreateChannelId: '',
        categoryId: '',
    },

    // ======================== WEBHOOK (FiveM Bridge) ========================
    webhook: {
        port: 25461,                 // Port the bot listens on for FiveM webhook events
        secret: process.env.WEBHOOK_SECRET || 'osven-webhook-secret-change-me',
        channelId: '',               // Channel for join/leave/report embeds
    },
};
