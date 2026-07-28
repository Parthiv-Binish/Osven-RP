const { REST, Routes } = require('discord.js');
const fs = require('fs');
const path = require('path');
const { runSetup } = require('../services/autoSetup');

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

        // ── Auto-setup: create missing channels/roles ──
        const setup = await runSetup(guild, client);

        // Merge setup IDs into client.config at runtime
        if (setup) {
            if (setup.categories.ticketsCategory) {
                client.config.tickets.categoryId = client.config.tickets.categoryId || setup.categories.ticketsCategory;
            }
            if (setup.categories.tempVoiceCategory) {
                client.config.tempVoice.categoryId = client.config.tempVoice.categoryId || setup.categories.tempVoiceCategory;
            }
            if (setup.channels.applicationsChannel) {
                client.config.applications.channelId = client.config.applications.channelId || setup.channels.applicationsChannel;
            }
            if (setup.roles.approvedRole) {
                client.config.applications.approvedRoleId = client.config.applications.approvedRoleId || setup.roles.approvedRole;
            }
            if (setup.channels.jobsChannel) {
                client.config.jobs.channelId = client.config.jobs.channelId || setup.channels.jobsChannel;
            }
            if (setup.channels.bansChannel) {
                client.config.bans.channelId = client.config.bans.channelId || setup.channels.bansChannel;
            }
            if (setup.channels.wallOfShameChannel) {
                client.config.bans.wallOfShameChannelId = client.config.bans.wallOfShameChannelId || setup.channels.wallOfShameChannel;
            }
            if (setup.channels.statsChannel) {
                client.config.stats.channelId = client.config.stats.channelId || setup.channels.statsChannel;
            }
            if (setup.channels.joinToCreateChannel) {
                client.config.tempVoice.joinToCreateChannelId = client.config.tempVoice.joinToCreateChannelId || setup.channels.joinToCreateChannel;
            }
            if (setup.channels.webhookChannel) {
                client.config.webhook.channelId = client.config.webhook.channelId || setup.channels.webhookChannel;
            }
            if (setup.channels.transcriptsChannel) {
                client.config.tickets.logChannelId = client.config.tickets.logChannelId || setup.channels.transcriptsChannel;
            }
            if (setup.channels.generalChannel) {
                client.config.welcomeChannelId = client.config.welcomeChannelId || setup.channels.generalChannel;
            }

            // Auto-populate staff role IDs from created roles
            const staffRoleIds = client.config.tickets.staffRoleIds || [];
            const jobsStaffRoleIds = client.config.jobs.staffRoleIds || [];
            const appStaffRoleIds = client.config.applications.staffRoleIds || [];
            if (setup.roles.staffRole && !staffRoleIds.includes(setup.roles.staffRole)) {
                staffRoleIds.push(setup.roles.staffRole);
                client.config.tickets.staffRoleIds = staffRoleIds;
            }
            if (setup.roles.staffRole && !jobsStaffRoleIds.includes(setup.roles.staffRole)) {
                jobsStaffRoleIds.push(setup.roles.staffRole);
                client.config.jobs.staffRoleIds = jobsStaffRoleIds;
            }
            if (setup.roles.staffRole && !appStaffRoleIds.includes(setup.roles.staffRole)) {
                appStaffRoleIds.push(setup.roles.staffRole);
                client.config.applications.staffRoleIds = appStaffRoleIds;
            }
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
