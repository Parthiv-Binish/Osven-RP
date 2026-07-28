const http = require('http');
const { EmbedBuilder } = require('discord.js');
const banManager = require('./services/banManager');

module.exports = function startWebhook(client) {
    const config = client.config.webhook;
    if (!config?.port || config.port === 0) return;

    const server = http.createServer((req, res) => {
        if (req.method !== 'POST' || req.url !== '/webhook') {
            res.writeHead(405);
            return res.end();
        }

        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', async () => {
            try {
                const data = JSON.parse(body);
                if (data.secret !== config.secret) {
                    res.writeHead(403);
                    return res.end('Forbidden');
                }

                await handleEvent(client, data.event, data.data);
                res.writeHead(200);
                res.end('OK');
            } catch (err) {
                console.error('[osven-bot] Webhook error:', err.message);
                res.writeHead(400);
                res.end('Bad Request');
            }
        });
    });

    server.listen(config.port, () => {
        console.log(`[osven-bot] Webhook server listening on port ${config.port}`);
    });
};

async function handleEvent(client, event, data) {
    switch (event) {
        case 'playerConnecting':
            return sendEmbed(client, playerJoinEmbed(data));
        case 'playerDropped':
            return sendEmbed(client, playerLeaveEmbed(data));
        case 'playerReport':
            return sendEmbed(client, reportEmbed(data));
        case 'staffAction':
            return sendEmbed(client, staffActionEmbed(data));
        case 'playerBan':
            return handleBan(client, data);
        case 'serverStart':
            return sendEmbed(client, serverStartEmbed(data));
        case 'serverStop':
            return sendEmbed(client, serverStopEmbed(data));
    }
}

async function sendEmbed(client, embed) {
    const chId = client.config.webhook.channelId;
    if (!chId || !embed) return;
    const ch = client.channels.cache.get(chId);
    if (ch) await ch.send({ embeds: [embed] }).catch(() => {});
}

async function handleBan(client, data) {
    // Log to ban manager
    banManager.addBan(data);

    const isPerm = data.isPermanent || data.duration === 'permanent';
    const color = isPerm ? 0xC23B3B : 0xE8A33D;
    const title = isPerm ? '🚫 Permanent Ban' : '⛔ Temporary Ban';

    const embed = new EmbedBuilder()
        .setColor(color)
        .setTitle(title)
        .addFields(
            { name: 'Player', value: data.playerName, inline: true },
            { name: 'Banned By', value: data.bannedBy, inline: true },
            { name: 'Duration', value: data.duration || (isPerm ? 'Permanent' : 'Unknown'), inline: true },
            { name: 'Reason', value: data.reason || 'No reason provided', inline: false },
            ...(data.discordId ? [{ name: 'Discord', value: `<@${data.discordId}>`, inline: true }] : []),
            ...(data.citizenId ? [{ name: 'Citizen ID', value: `\`${data.citizenId}\``, inline: true }] : []),
        )
        .setTimestamp();

    // Send to ban channel
    const banChId = client.config.bans?.channelId;
    if (banChId) {
        const ch = client.channels.cache.get(banChId);
        if (ch) await ch.send({ embeds: [embed] }).catch(() => {});
    }

    // Send permanent bans to wall of shame
    if (isPerm && client.config.bans?.wallOfShameChannelId) {
        const wallCh = client.channels.cache.get(client.config.bans.wallOfShameChannelId);
        if (wallCh) {
            const wallEmbed = new EmbedBuilder()
                .setColor(0xC23B3B)
                .setTitle('🚫 Wall of Shame')
                .setDescription(`**${data.playerName}** has been permanently banned from Osven City.`)
                .addFields(
                    { name: 'Reason', value: data.reason || 'No reason provided', inline: false },
                    { name: 'Banned by', value: data.bannedBy, inline: true },
                    { name: 'Date', value: `<t:${Math.floor(Date.now() / 1000)}:F>`, inline: true },
                )
                .setFooter({ text: 'This ban is permanent and non-negotiable.' })
                .setTimestamp();
            await wallCh.send({ embeds: [wallEmbed] }).catch(() => {});
        }
    }
}

function playerJoinEmbed(data) {
    return new EmbedBuilder()
        .setColor(0x2FB6A6).setTitle('Player Joined')
        .setDescription(`**${data.name}** joined the server`)
        .addFields({ name: 'Discord', value: data.discordId ? `<@${data.discordId}>` : 'Unknown', inline: true })
        .setTimestamp();
}

function playerLeaveEmbed(data) {
    return new EmbedBuilder()
        .setColor(0xC23B3B).setTitle('Player Left')
        .setDescription(`**${data.name}** left the server`)
        .addFields(
            { name: 'Discord', value: data.discordId ? `<@${data.discordId}>` : 'Unknown', inline: true },
            { name: 'Reason', value: data.reason || 'Unknown', inline: false }
        ).setTimestamp();
}

function reportEmbed(data) {
    return new EmbedBuilder()
        .setColor(0xE8A33D).setTitle('Player Report')
        .addFields(
            { name: 'Reporter', value: `${data.reporter?.name || 'Unknown'} (ID: ${data.reporter?.id || '?'})`, inline: true },
            { name: 'Target', value: `${data.target?.name || 'Unknown'} (ID: ${data.target?.id || '?'})`, inline: true },
            { name: 'Reason', value: data.reason || 'None provided', inline: false }
        ).setTimestamp();
}

function staffActionEmbed(data) {
    return new EmbedBuilder()
        .setColor(0x8B93A1).setTitle('Staff Action')
        .addFields(
            { name: 'Staff', value: data.staff?.name || 'Unknown', inline: true },
            { name: 'Action', value: data.action || 'Unknown', inline: true },
            { name: 'Target', value: data.target || 'N/A', inline: true },
            { name: 'Detail', value: data.detail || 'N/A', inline: false }
        ).setTimestamp();
}

function serverStartEmbed(data) {
    return new EmbedBuilder()
        .setColor(0x2FB6A6).setTitle('🟢 Server Online')
        .setDescription('Osven City is now online.')
        .setTimestamp();
}

function serverStopEmbed(data) {
    return new EmbedBuilder()
        .setColor(0xC23B3B).setTitle('🔴 Server Offline')
        .setDescription('Osven City has gone offline.')
        .setTimestamp();
}
