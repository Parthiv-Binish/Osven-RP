const { REST, Routes } = require('discord.js');
const fs = require('fs');
const path = require('path');

module.exports = {
    name: 'ready',
    once: true,
    async execute(client) {
        console.log(`[osven-bot] Logged in as ${client.user.tag}`);

        const guild = client.guilds.cache.get(client.config.guildId);
        if (!guild) {
            console.error('[osven-bot] Guild not found — check guildId');
            return;
        }

        // Register slash commands
        const commands = [];
        const commandsPath = path.join(__dirname, '..', 'commands');
        for (const file of fs.readdirSync(commandsPath).filter(f => f.endsWith('.js'))) {
            const command = require(path.join(commandsPath, file));
            if ('data' in command) {
                commands.push(command.data.toJSON());
            }
        }

        const rest = new REST({ version: '10' }).setToken(client.config.token);
        try {
            await rest.put(Routes.applicationGuildCommands(client.user.id, client.config.guildId), { body: commands });
            console.log(`[osven-bot] Registered ${commands.length} slash commands`);
        } catch (err) {
            console.error('[osven-bot] Failed to register commands:', err.message);
        }

        // Start stats updater
        const stats = client.config.stats;
        if (client.config.serverId && stats?.channelId) {
            updateStats(client);
            setInterval(() => updateStats(client), stats.updateInterval || 60000);
        }

        // Set bot presence
        client.user.setPresence({
            activities: [{ name: 'Osven City', type: 3 }],
            status: 'online',
        });
    },
};

async function updateStats(client) {
    try {
        const res = await fetch(`https://servers-frontend.fivem.net/api/servers/single/${client.config.serverId}`, {
            headers: { 'User-Agent': 'OsvenCityBot/1.0' },
        });

        if (!res.ok) {
            console.warn(`[osven-bot] Stats API returned ${res.status}`);
            updateChannelName(client, client.config.stats.offlineName || '🔴 Server Offline');
            return;
        }

        const data = await res.json();
        const current = data.Data?.Clients ?? 0;
        const max = data.SvMaxclients ?? 48;
        const name = (client.config.stats.channelName || 'Players: {current}/{max}')
            .replace('{current}', current)
            .replace('{max}', max);
        updateChannelName(client, name);
        client.user.setPresence({
            activities: [{ name: `${current}/${max} players`, type: 3 }],
            status: 'online',
        });
    } catch (err) {
        console.error('[osven-bot] Stats update error:', err.message);
    }
}

async function updateChannelName(client, name) {
    const chId = client.config.stats.channelId;
    if (!chId) return;
    const channel = client.channels.cache.get(chId);
    if (channel && channel.isVoiceBased()) {
        await channel.setName(name).catch(() => {});
    }
}
