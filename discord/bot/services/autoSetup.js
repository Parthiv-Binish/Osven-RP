const { PermissionFlagsBits, ChannelType } = require('discord.js');
const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');
const SETUP_FILE = path.join(DATA_DIR, 'setup.json');

const DEFAULT_SETUP = {
    categories: {},
    channels: {},
    roles: {},
};

function readSetup() {
    try {
        if (fs.existsSync(SETUP_FILE)) {
            const data = JSON.parse(fs.readFileSync(SETUP_FILE, 'utf8'));
            if (Array.isArray(data)) return { ...DEFAULT_SETUP };
            return { ...DEFAULT_SETUP, ...data };
        }
    } catch { }
    return { ...DEFAULT_SETUP };
}

function writeSetup(data) {
    if (!fs.existsSync(DATA_DIR)) {
        fs.mkdirSync(DATA_DIR, { recursive: true });
    }
    fs.writeFileSync(SETUP_FILE, JSON.stringify(data, null, 2));
}

function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function runSetup(guild, client) {
    console.log('[osven-bot] Running auto-setup...');

    const setup = readSetup();
    let created = false;

    // ── Categories ──
    const categoryMappings = {
        '🎫 Tickets': 'ticketsCategory',
        '🔊 Voice Channels': 'tempVoiceCategory',
    };

    for (const [catName, configKey] of Object.entries(categoryMappings)) {
        if (setup.categories[configKey]) {
            const exists = guild.channels.cache.get(setup.categories[configKey]);
            if (exists) continue;
        }
        const cat = await guild.channels.create({
            name: catName,
            type: ChannelType.GuildCategory,
            permissionOverwrites: [
                { id: guild.roles.everyone, deny: [PermissionFlagsBits.ViewChannel] },
            ],
        });
        if (catName === '🎫 Tickets') {
            await cat.permissionOverwrites.edit(guild.roles.everyone, { ViewChannel: false });
        }
        setup.categories[configKey] = cat.id;
        created = true;
        console.log(`[osven-bot] Created category: ${catName} (${cat.id})`);
        await delay(500);
    }

    // Make ticket category visible to staff (fetch existing roles)
    const ticketCatId = setup.categories['ticketsCategory'];
    if (ticketCatId) {
        const ticketCat = guild.channels.cache.get(ticketCatId);
        if (ticketCat) {
            const staffRoleIds = client.config.tickets?.staffRoleIds || [];
            for (const rid of staffRoleIds) {
                try {
                    await ticketCat.permissionOverwrites.edit(rid, { ViewChannel: true });
                } catch { }
            }
        }
    }

    // ── Text Channels ──
    const channelMappings = [
        { name: 'whitelist-apps', configKey: 'applicationsChannel', topic: 'Whitelist applications for staff review' },
        { name: 'job-apps', configKey: 'jobsChannel', topic: 'Job applications for staff review' },
        { name: 'ban-logs', configKey: 'bansChannel', topic: 'Ban notifications' },
        { name: 'mod-logs', configKey: 'webhookChannel', topic: 'Join/leave/report logs' },
        { name: 'transcripts', configKey: 'transcriptsChannel', topic: 'Ticket transcripts' },
    ];

    for (const ch of channelMappings) {
        if (setup.channels[ch.configKey]) {
            const exists = guild.channels.cache.get(setup.channels[ch.configKey]);
            if (exists) continue;
        }
        const parentId = ch.name.includes('log') || ch.name === 'transcripts'
            ? null
            : setup.categories['ticketsCategory'] || null;
        const newCh = await guild.channels.create({
            name: ch.name,
            type: ChannelType.GuildText,
            topic: ch.topic,
            parent: parentId,
        });
        setup.channels[ch.configKey] = newCh.id;
        created = true;
        console.log(`[osven-bot] Created channel: #${ch.name} (${newCh.id})`);
        await delay(500);
    }

    // ── Voice Channels ──
    const voiceMappings = [
        { name: '📊 Stats', configKey: 'statsChannel' },
        { name: '🔊 Join to Create', configKey: 'joinToCreateChannel' },
    ];

    for (const vc of voiceMappings) {
        if (setup.channels[vc.configKey]) {
            const exists = guild.channels.cache.get(setup.channels[vc.configKey]);
            if (exists) continue;
        }
        const newVc = await guild.channels.create({
            name: vc.name,
            type: ChannelType.GuildVoice,
            parent: setup.categories['tempVoiceCategory'] || null,
        });
        setup.channels[vc.configKey] = newVc.id;
        created = true;
        console.log(`[osven-bot] Created voice channel: ${vc.name} (${newVc.id})`);
        await delay(500);
    }

    // ── Roles ──
    const roleMappings = [
        { name: 'Approved', configKey: 'approvedRole', color: '#2FB6A6', reason: 'Whitelist approved role' },
        { name: 'Admin', configKey: 'adminRole', color: '#C23B3B', reason: 'Server administrator' },
        { name: 'Mod', configKey: 'modRole', color: '#E8A33D', reason: 'Server moderator' },
        { name: 'Staff', configKey: 'staffRole', color: '#8B93A1', reason: 'Support staff' },
    ];

    for (const rl of roleMappings) {
        if (setup.roles[rl.configKey]) {
            const exists = guild.roles.cache.get(setup.roles[rl.configKey]);
            if (exists) continue;
        }
        const newRole = await guild.roles.create({
            name: rl.name,
            color: rl.color,
            reason: rl.reason,
        });
        setup.roles[rl.configKey] = newRole.id;
        created = true;
        console.log(`[osven-bot] Created role: @${rl.name} (${newRole.id})`);
        await delay(500);
    }

    // ── Wall of Shame channel (inside ban category) ──
    if (setup.channels['bansChannel']) {
        const banCatName = '🚫 Bans';
        let banCatId = setup.categories['bansCategory'];
        if (banCatId) {
            const exists = guild.channels.cache.get(banCatId);
            if (!exists) banCatId = null;
        }
        if (!banCatId) {
            const banCat = await guild.channels.create({
                name: banCatName,
                type: ChannelType.GuildCategory,
                permissionOverwrites: [
                    { id: guild.roles.everyone, deny: [PermissionFlagsBits.ViewChannel] },
                ],
            });
            setup.categories['bansCategory'] = banCat.id;
            created = true;
            console.log(`[osven-bot] Created category: ${banCatName} (${banCat.id})`);
            await delay(500);

            // Move ban-logs channel into this category
            const banLogCh = guild.channels.cache.get(setup.channels['bansChannel']);
            if (banLogCh) {
                await banLogCh.setParent(banCat.id, { lockPermissions: true });
            }
        }
    }

    // Wall of Shame channel
    let wallKey = 'wallOfShameChannel';
    if (!setup.channels[wallKey]) {
        const parentId = setup.categories['bansCategory'] || null;
        const wos = await guild.channels.create({
            name: 'wall-of-shame',
            type: ChannelType.GuildText,
            topic: 'Permanent bans (Wall of Shame)',
            parent: parentId,
        });
        setup.channels[wallKey] = wos.id;
        created = true;
        console.log(`[osven-bot] Created channel: #wall-of-shame (${wos.id})`);
        await delay(500);
    }

    if (created) {
        writeSetup(setup);
        console.log('[osven-bot] Setup complete — IDs saved to setup.json');
    } else {
        console.log('[osven-bot] Setup already complete, nothing to create');
    }

    return setup;
}

module.exports = { runSetup };
