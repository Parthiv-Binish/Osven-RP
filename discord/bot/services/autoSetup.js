const { PermissionFlagsBits, ChannelType, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
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
    const categoryMappings = [
        { name: '📢 Information',   configKey: 'infoCategory' },
        { name: '💬 Community',     configKey: 'communityCategory' },
        { name: '🔒 Departments',   configKey: 'departmentsCategory' },
        { name: '🎫 Tickets',       configKey: 'ticketsCategory' },
        { name: '👮 Staff',         configKey: 'staffCategory' },
        { name: '🚫 Bans',          configKey: 'bansCategory' },
        { name: '🔊 Voice Channels', configKey: 'tempVoiceCategory' },
    ];

    for (const cat of categoryMappings) {
        if (setup.categories[cat.configKey]) {
            const exists = guild.channels.cache.get(setup.categories[cat.configKey]);
            if (exists) continue;
        }
        const isPrivate = cat.name.includes('Tickets') || cat.name.includes('Staff') || cat.name.includes('Bans');
        const overwrites = isPrivate
            ? [{ id: guild.roles.everyone, deny: [PermissionFlagsBits.ViewChannel] }]
            : [];
        const newCat = await guild.channels.create({
            name: cat.name,
            type: ChannelType.GuildCategory,
            permissionOverwrites: overwrites,
        });
        setup.categories[cat.configKey] = newCat.id;
        created = true;
        console.log(`[osven-bot] Created category: ${cat.name} (${newCat.id})`);
        await delay(500);
    }

    // Make staff/tickets categories visible to staff roles
    for (const catKey of ['staffCategory', 'ticketsCategory']) {
        const catId = setup.categories[catKey];
        if (!catId) continue;
        const cat = guild.channels.cache.get(catId);
        if (!cat) continue;
        const sids = client.config.tickets?.staffRoleIds || [];
        for (const rid of [...sids, setup.roles.staffRole].filter(Boolean)) {
            try { await cat.permissionOverwrites.edit(rid, { ViewChannel: true }); } catch { }
        }
    }

    // ── Text Channels ──
    const channelMappings = [
        { name: 'announcements',  configKey: 'announcementsChannel', topic: 'Server announcements & updates', cat: 'infoCategory' },
        { name: 'rules',          configKey: 'rulesChannel',         topic: 'Server rules & guidelines',       cat: 'infoCategory' },
        { name: 'apply',          configKey: 'applyChannel',         topic: 'Apply for jobs, whitelist, or gangs', cat: 'infoCategory' },
        { name: 'whitelist-apps', configKey: 'applicationsChannel',  topic: 'Whitelist applications',          cat: 'infoCategory' },
        { name: 'general',        configKey: 'generalChannel',       topic: 'General discussion',              cat: 'communityCategory' },
        { name: 'gameplay',       configKey: 'gameplayChannel',      topic: 'In-game discussion & stories',    cat: 'communityCategory' },
        { name: 'media',          configKey: 'mediaChannel',         topic: 'Screenshots & clips',             cat: 'communityCategory' },
        { name: 'suggestions',    configKey: 'suggestionsChannel',   topic: 'Suggestions for the server',      cat: 'communityCategory' },
        { name: 'police',         configKey: 'policeChannel',        topic: 'Law enforcement discussions',     cat: 'communityCategory' },
        { name: 'ems',            configKey: 'emsChannel',           topic: 'EMS & medical discussions',       cat: 'communityCategory' },
        { name: 'gangs',          configKey: 'gangsChannel',         topic: 'Gang-related chat',               cat: 'communityCategory' },
        { name: 'admin-chat',     configKey: 'adminChannel',         topic: 'Staff coordination (admin only)', cat: 'staffCategory' },
        { name: 'mod-logs',       configKey: 'webhookChannel',       topic: 'Join/leave/report logs',          cat: 'staffCategory' },
        { name: 'staff-review',   configKey: 'staffReviewChannel',   topic: 'Review & approve applications',   cat: 'staffCategory' },
        { name: 'ban-logs',       configKey: 'bansChannel',          topic: 'Ban notifications',               cat: 'bansCategory' },
        { name: 'wall-of-shame',  configKey: 'wallOfShameChannel',   topic: 'Permanent bans (Wall of Shame)',  cat: 'bansCategory' },
        { name: 'transcripts',    configKey: 'transcriptsChannel',   topic: 'Ticket transcripts',              cat: 'staffCategory' },
    ];

    for (const ch of channelMappings) {
        if (setup.channels[ch.configKey]) {
            const exists = guild.channels.cache.get(setup.channels[ch.configKey]);
            if (exists) continue;
        }
        const parentId = setup.categories[ch.cat] || null;
        const isStaff = ch.configKey === 'adminChannel' || ch.configKey === 'staffCategory' || ch.configKey === 'staffReviewChannel';
        const overwrites = isStaff
            ? [{ id: guild.roles.everyone, deny: [PermissionFlagsBits.ViewChannel] }]
            : [];
        const newCh = await guild.channels.create({
            name: ch.name,
            type: ChannelType.GuildText,
            topic: ch.topic,
            parent: parentId,
            permissionOverwrites: overwrites,
        });
        setup.channels[ch.configKey] = newCh.id;
        created = true;
        console.log(`[osven-bot] Created channel: #${ch.name} (${newCh.id})`);
        await delay(500);
    }

    // ── Department Channels (private, one per job/gang) ──
    const deptChannels = [
        { name: '🚔 police-hq',     roleKey: 'policeRole',   cat: 'departmentsCategory' },
        { name: '🚑 ems-hq',        roleKey: 'emsRole',      cat: 'departmentsCategory' },
        { name: '🔧 mechanics-hq',  roleKey: 'mechanicRole', cat: 'departmentsCategory' },
        { name: '🏢 realestate-hq', roleKey: 'realEstateRole', cat: 'departmentsCategory' },
        { name: '📰 news-hq',       roleKey: 'newsRole',     cat: 'departmentsCategory' },
    ];

    for (const dc of deptChannels) {
        if (setup.channels[dc.roleKey]) {
            const exists = guild.channels.cache.get(setup.channels[dc.roleKey]);
            if (exists) continue;
        }
        const parentId = setup.categories[dc.cat] || null;
        const roleId = setup.roles[dc.roleKey] || null;
        const overwrites = [{ id: guild.roles.everyone, deny: [PermissionFlagsBits.ViewChannel] }];
        if (roleId) overwrites.push({ id: roleId, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] });
        const newCh = await guild.channels.create({
            name: dc.name,
            type: ChannelType.GuildText,
            topic: `Private channel for ${dc.name.replace(/^[^\s]+\s/, '').replace('-hq', '')}`,
            parent: parentId,
            permissionOverwrites: overwrites,
        });
        setup.channels[dc.roleKey] = newCh.id;
        created = true;
        console.log(`[osven-bot] Created department channel: ${dc.name} (${newCh.id})`);
        await delay(500);
    }

    // Make admin-chat visible to staff roles
    const adminChId = setup.channels['adminChannel'];
    if (adminChId) {
        const adminCh = guild.channels.cache.get(adminChId);
        if (adminCh) {
            const sids = client.config.tickets?.staffRoleIds || [];
            for (const rid of [...sids, setup.roles.staffRole, setup.roles.adminRole, setup.roles.modRole].filter(Boolean)) {
                try { await adminCh.permissionOverwrites.edit(rid, { ViewChannel: true }); } catch { }
            }
        }
    }

    // ── Voice Channels ──
    const voiceMappings = [
        { name: '🚀 General',          configKey: 'generalVc' },
        { name: '🔊 Join to Create',   configKey: 'joinToCreateChannel' },
        { name: '📊 Stats',            configKey: 'statsChannel' },
        { name: '🔇 AFK',              configKey: 'afkVc' },
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
        { name: 'Visitor',      configKey: 'defaultRole',     color: '#8B93A1', reason: 'Default role on join', hoist: false },
        { name: 'Citizen',      configKey: 'approvedRole',    color: '#2FB6A6', reason: 'Whitelist approved role', hoist: true },
        { name: 'Staff',        configKey: 'staffRole',       color: '#8B93A1', reason: 'Support staff', hoist: true },
        { name: 'Mod',          configKey: 'modRole',         color: '#E8A33D', reason: 'Server moderator', hoist: true },
        { name: 'Admin',        configKey: 'adminRole',       color: '#C23B3B', reason: 'Server administrator', hoist: true },
        { name: 'Police',       configKey: 'policeRole',      color: '#2B6EB0', reason: 'Police department', hoist: true },
        { name: 'EMS',          configKey: 'emsRole',         color: '#FFFFFF', reason: 'EMS department', hoist: true },
        { name: 'Mechanic',     configKey: 'mechanicRole',    color: '#E67E22', reason: 'Mechanic department', hoist: true },
        { name: 'Real Estate',  configKey: 'realEstateRole',  color: '#1ABC9C', reason: 'Real Estate department', hoist: true },
        { name: 'News',         configKey: 'newsRole',        color: '#F1C40F', reason: 'News department', hoist: true },
        { name: 'Gang Leader',  configKey: 'gangLeaderRole',  color: '#9B59B6', reason: 'Gang leader', hoist: true },
        { name: 'Gang Co-Leader', configKey: 'gangCoLeaderRole', color: '#8E44AD', reason: 'Gang co-leader', hoist: true },
        { name: 'Gang Member',  configKey: 'gangMemberRole',  color: '#6C3483', reason: 'Gang member', hoist: true },
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
            hoist: rl.hoist,
        });
        setup.roles[rl.configKey] = newRole.id;
        created = true;
        console.log(`[osven-bot] Created role: @${rl.name} (${newRole.id})`);
        await delay(500);
    }

    // ── Persistent messages ──

    // Apply channel with all application buttons
    const applyChId = setup.channels['applyChannel'];
    if (applyChId) {
        const applyCh = guild.channels.cache.get(applyChId);
        if (applyCh) {
            const existing = (await applyCh.messages.fetch({ limit: 20 }).catch(() => []))
                .find(m => m.author.id === client.user.id && m.components.length > 0);
            if (!existing) {
                const embed = new EmbedBuilder()
                    .setColor(0xE8A33D)
                    .setTitle('📝 Apply for Osven City')
                    .setDescription('Select what you want to apply for below. Staff will review your application.')
                    .addFields(
                        { name: '👮 Jobs', value: 'Police, EMS, Mechanic, Real Estate, News', inline: true },
                        { name: '🎮 Whitelist', value: 'General server access', inline: true },
                        { name: '💀 Gangs', value: 'Join or create a gang', inline: true },
                    );
                const row1 = new ActionRowBuilder().addComponents(
                    new ButtonBuilder().setCustomId('apply_whitelist_btn').setLabel('🎮 Whitelist').setStyle(ButtonStyle.Success),
                    new ButtonBuilder().setCustomId('apply_police_btn').setLabel('👮 Police').setStyle(ButtonStyle.Primary),
                    new ButtonBuilder().setCustomId('apply_ems_btn').setLabel('🚑 EMS').setStyle(ButtonStyle.Primary),
                    new ButtonBuilder().setCustomId('apply_mechanic_btn').setLabel('🔧 Mechanic').setStyle(ButtonStyle.Primary),
                    new ButtonBuilder().setCustomId('apply_news_btn').setLabel('📰 News').setStyle(ButtonStyle.Primary),
                );
                const row2 = new ActionRowBuilder().addComponents(
                    new ButtonBuilder().setCustomId('apply_realestate_btn').setLabel('🏢 Real Estate').setStyle(ButtonStyle.Primary),
                    new ButtonBuilder().setCustomId('apply_gang_btn').setLabel('💀 Gang').setStyle(ButtonStyle.Danger),
                );
                await applyCh.send({ embeds: [embed], components: [row1, row2] });
                console.log('[osven-bot] Sent apply channel buttons');
            }
        }
    }

    // Rules in rules channel
    const rulesChId = setup.channels['rulesChannel'];
    if (rulesChId) {
        const rulesCh = guild.channels.cache.get(rulesChId);
        if (rulesCh) {
            const existing = (await rulesCh.messages.fetch({ limit: 10 }).catch(() => []))
                .find(m => m.author.id === client.user.id);
            if (!existing) {
                const embed = new EmbedBuilder()
                    .setColor(0x2FB6A6)
                    .setTitle('📜 Server Rules')
                    .setDescription('1. **Respect everyone** — No harassment, discrimination, or toxicity\n2. **No cheating** — No mods, exploits, or scripts\n3. **Stay in character** — This is an RP server\n4. **No RDM / VDM** — Random deathmatch & vehicle deathmatch are prohibited\n5. **Follow staff instructions** — Staff decisions are final\n6. **No metagaming** — Don\'t use out-of-character info in roleplay\n7. **No powergaming** — Don\'t force unrealistic scenarios\n8. **Have fun!** — This is a game, enjoy it')
                    .setFooter({ text: 'Violations may result in warnings, kicks, or bans' });
                await rulesCh.send({ embeds: [embed] });
                console.log('[osven-bot] Sent rules message');
            }
        }
    }

    // ── Save setup data ──
    if (created) {
        writeSetup(setup);
        console.log('[osven-bot] Setup complete — IDs saved to setup.json');
    } else {
        console.log('[osven-bot] Setup already complete, nothing to create');
    }

    return setup;
}

module.exports = { runSetup };
