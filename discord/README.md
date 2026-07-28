# Osven City — Discord Bot

Node.js Discord bot for server management, whitelist applications, support tickets, live stats, and ban logging.

## Features

| Feature | Description |
|---------|-------------|
| **Whitelist Applications** | `/apply whitelist` — modal with 5 questions; admins approve/reject via buttons; auto-role on approval; cooldown on rejection; DM notification |
| **Job Applications** | `/apply job` — modal with 4 questions; per-job-type applications (Police, EMS, Mechanic, etc.) |
| **Admin Review** | `/admin review` — paginated review of pending applications; approve/reject/skip buttons; stats via `/admin stats` |
| **Support Tickets** | `/ticket open` — creates private text channel; `/ticket close` — closes with transcript logging; staff can add users |
| **Live Stats** | Auto-updating voice channel name with player count (e.g. "Players: 12/48"); online/offline detection |
| **Join-to-Create VC** | Users join a designated VC → temporary channel spawns; auto-deletes when empty |
| **Server Status** | `/server` — rich embed with player count, hostname, status; `/ping` — latency check |
| **Ban Logging** | In-game bans relayed to Discord via webhook; permanent bans posted to a Wall of Shame channel |
| **Event Logging** | Player join/leave, reports, staff actions posted to a log channel as rich embeds |

## Setup

### 1. Create a Discord Application

1. Go to https://discord.com/developers/applications
2. **New Application** → name it "Osven City"
3. **Bot** → **Add Bot** → copy the **Token**
4. Enable **Privileged Gateway Intents**: Server Members Intent, Message Content Intent, Voice State Intent

### 2. Invite the Bot

**OAuth2 → URL Generator**:
- Scopes: `bot`, `applications.commands`
- Permissions: `Send Messages`, `Manage Channels`, `Connect`, `Move Members`, `Read Message History`, `Manage Roles`

### 3. Configure

Edit `bot/config.js`:

```js
token: 'YOUR_BOT_TOKEN',
guildId: 'YOUR_GUILD_ID',
serverId: 'YOUR_CFX_SERVER_ID',       // From https://servers.fivem.net

applications: {
    channelId: 'REVIEW_CHANNEL_ID',       // Where new applications appear
    approvedRoleId: 'WHITELISTED_ROLE_ID', // Role given on approval
    staffRoleIds: ['ADMIN_ROLE_ID'],       // Roles that can review apps
},

tickets: {
    categoryId: 'TICKET_CATEGORY_ID',     // Where ticket channels are created
    staffRoleIds: ['ADMIN_ROLE_ID'],
    logChannelId: 'TICKET_LOG_CHANNEL_ID',
},

bans: {
    channelId: 'BAN_CHANNEL_ID',
    wallOfShameChannelId: 'WALL_OF_SHAME_CHANNEL_ID',
},

stats: {
    channelId: 'STATS_VC_ID',             // Voice channel for player count
},

tempVoice: {
    joinToCreateChannelId: 'JOIN_TO_CREATE_VC_ID',
    categoryId: 'TEMP_VC_CATEGORY_ID',
},

webhook: {
    port: 30121,
    secret: 'your-secret-key',           // Match with osven-discord-bot config
    channelId: 'LOG_CHANNEL_ID',          // For join/leave/report embeds
},
```

### 4. Install & Run

```bash
cd bot
npm install
npm start
```

For production (PM2):
```bash
npm install -g pm2
pm2 start index.js --name osven-bot
pm2 save
pm2 startup
```

## FiveM Bridge

The `osven-discord-bot` resource sends in-game events to the bot:

1. Set `WebhookUrl` to `http://localhost:30121/webhook`
2. Set `Secret` to match the bot's `webhook.secret`
3. Ensure the resource in `osven.cfg`

## Directory Structure

```
discord/bot/
  index.js              # Bot entry point
  config.js             # Configuration
  package.json
  data/                 # JSON storage (applications, tickets, bans)
  commands/             # Slash commands
    apply.js            # /apply whitelist|job
    ticket.js           # /ticket open|close|add
    admin.js            # /admin review|stats
    server.js           # /server info
    ping.js             # /ping latency
  events/               # Event handlers
    ready.js            # Bot ready + stats updater
    interactionCreate.js # Commands + modals + buttons
    voiceStateUpdate.js  # Temp VC management
  modals/               # Application modals
    whitelistApply.js   # Whitelist form
    jobApply.js         # Job form
  services/             # Business logic
    storage.js          # JSON file read/write
    applicationManager.js # App lifecycle
    ticketManager.js    # Ticket lifecycle
    banManager.js       # Ban logging
  webhook.js            # HTTP server for FiveM events
```
