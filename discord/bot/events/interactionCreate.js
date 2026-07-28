const { EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle, PermissionFlagsBits, ChannelType } = require('discord.js');
const appManager = require('../services/applicationManager');
const ticketManager = require('../services/ticketManager');

const JOB_ROLE_MAP = {
    police: 'policeRoleId',
    ems: 'emsRoleId',
    realestate: 'realEstateRoleId',
};

module.exports = {
    name: 'interactionCreate',
    async execute(interaction, client) {
        if (interaction.isChatInputCommand()) {
            const command = client.commands.get(interaction.commandName);
            if (!command) return;
            try {
                await command.execute(interaction, client);
            } catch (err) {
                console.error(`[osven-bot] Command ${interaction.commandName} error:`, err.message);
                const reply = { content: 'An error occurred while executing that command.', ephemeral: true };
                if (interaction.replied || interaction.deferred) {
                    await interaction.followUp(reply).catch(() => {});
                } else {
                    await interaction.reply(reply).catch(() => {});
                }
            }
            return;
        }

        if (interaction.isModalSubmit()) {
            await handleModal(interaction, client);
            return;
        }

        if (interaction.isButton()) {
            await handleButton(interaction, client);
            return;
        }
    },
};

async function handleModal(interaction, client) {
    const { customId } = interaction;

    // ── Whitelist application ──
    if (customId === 'whitelist_apply') {
        const answers = [
            { question: 'Age', answer: interaction.fields.getTextInputValue('q_age') },
            { question: 'RP Experience', answer: interaction.fields.getTextInputValue('q_experience') },
            { question: 'Why join?', answer: interaction.fields.getTextInputValue('q_reason') },
            { question: 'Will follow rules?', answer: interaction.fields.getTextInputValue('q_rules') },
            { question: 'Referral', answer: interaction.fields.getTextInputValue('q_referral') || 'Not specified' },
        ];

        const app = appManager.create({
            userId: interaction.user.id,
            username: interaction.user.username,
            type: 'whitelist',
            answers,
        });

        await sendToReview(interaction, client, app, 'Whitelist', 0xE8A33D);
        await interaction.reply({ content: '✅ Your whitelist application has been submitted! Staff will review it shortly.', ephemeral: true });
    }

    // ── Job application ──
    else if (customId.startsWith('job_apply_')) {
        const jobType = customId.replace('job_apply_', '');
        const jobName = jobType.charAt(0).toUpperCase() + jobType.slice(1);

        const answers = [
            { question: 'Age', answer: interaction.fields.getTextInputValue('q_age') },
            { question: 'Experience', answer: interaction.fields.getTextInputValue('q_experience') },
            { question: 'Why this job?', answer: interaction.fields.getTextInputValue('q_reason') },
            { question: 'Availability', answer: interaction.fields.getTextInputValue('q_availability') },
        ];

        const app = appManager.create({
            userId: interaction.user.id,
            username: interaction.user.username,
            type: 'job',
            jobType: jobName,
            answers,
        });

        await sendToReview(interaction, client, app, `${jobName} Job`, 0x2FB6A6);
        await interaction.reply({ content: `✅ Your ${jobName} application has been submitted! Staff will review it shortly.`, ephemeral: true });
    }

    // ── Gang application ──
    else if (customId === 'gang_apply') {
        const gangName = interaction.fields.getTextInputValue('q_gangName').trim();
        const reason = interaction.fields.getTextInputValue('q_reason');
        const rules = interaction.fields.getTextInputValue('q_rules');
        const coLeaderRaw = interaction.fields.getTextInputValue('q_coleaders').trim();
        const memberRaw = interaction.fields.getTextInputValue('q_members').trim();

        const coLeaderIds = coLeaderRaw ? coLeaderRaw.split(',').map(s => s.trim()).filter(Boolean) : [];
        const memberIds = memberRaw ? memberRaw.split(',').map(s => s.trim()).filter(Boolean) : [];

        const answers = [
            { question: 'Gang Name', answer: gangName },
            { question: 'Why approved?', answer: reason },
            { question: 'Co-Leaders', answer: coLeaderIds.length > 0 ? coLeaderIds.join(', ') : 'None specified' },
            { question: 'Members', answer: memberIds.length > 0 ? memberIds.join(', ') : 'None specified' },
            { question: 'Rules agreement', answer: rules },
        ];

        const app = appManager.create({
            userId: interaction.user.id,
            username: interaction.user.username,
            type: 'gang',
            gangName,
            coLeaderIds,
            memberIds,
            answers,
        });

        await sendToReview(interaction, client, app, `Gang — ${gangName}`, 0x9B59B6);
        await interaction.reply({ content: `✅ Your **${gangName}** gang application has been submitted! Staff will review it shortly.`, ephemeral: true });
    }
}

async function handleButton(interaction, client) {
    const { customId } = interaction;

    // ── Application buttons (show modals) ──
    const applyBtns = {
        'apply_whitelist_btn': '../modals/whitelistApply',
        'apply_police_btn': '../modals/jobApply',
        'apply_ems_btn': '../modals/jobApply',
        // 'apply_mechanic_btn' and 'apply_news_btn' removed per request
        'apply_realestate_btn': '../modals/jobApply',
        'apply_gang_btn': '../modals/gangApply',
    };

    if (applyBtns[customId]) {
        if (customId === 'apply_whitelist_btn') {
            const m = require(applyBtns[customId]);
            await interaction.showModal(m());
        } else if (customId === 'apply_gang_btn') {
            const m = require(applyBtns[customId]);
            await interaction.showModal(m());
        } else {
            const jobMap = {
                'apply_police_btn': 'Police',
                'apply_ems_btn': 'EMS',
                // 'apply_mechanic_btn' and 'apply_news_btn' removed per request
                'apply_realestate_btn': 'Real Estate',
            };
            const m = require(applyBtns[customId]);
            await interaction.showModal(m(jobMap[customId]));
        }
        return;
    }

    // ── Application approve / reject ──
    if (customId.startsWith('app_')) {
        const parts = customId.split('_');
        const action = parts[1];
        const appId = parseInt(parts[2]);

        // Defer immediately so interaction doesn't expire during async work
        await interaction.deferUpdate();

        if (action === 'skip') {
            await interaction.editReply({ content: '⏭️ Skipped — use `/admin review` for the next one.', embeds: [], components: [] });
            return;
        }

        const app = appManager.review(appId, interaction.user.id, interaction.user.username, action === 'approve' ? 'approved' : 'rejected', null);
        if (!app) {
            await interaction.editReply({ content: '❌ Application not found.', components: [] });
            return;
        }

        if (action === 'approve') {
            await handleApproval(interaction, client, app);
        } else {
            const reply = `❌ **Application Rejected**\nYour **${app.type === 'gang' ? app.gangName : app.type === 'job' ? app.jobType : 'Whitelist'}** application (#${app.id}) was not approved.`;
            try {
                const user = await interaction.client.users.fetch(app.userId);
                if (user) await user.send(reply);
            } catch {}
        }

        await interaction.editReply({
            content: `✅ Application #${appId} **${action === 'approve' ? 'Approved' : 'Rejected'}** by ${interaction.user}`,
            embeds: [],
            components: [],
        });
    }

    // ── Ticket close ──
    else if (customId === 'ticket_close') {
        const ticket = ticketManager.getByChannel(interaction.channelId);
        if (!ticket) {
            return interaction.reply({ content: '❌ This is not a ticket channel.', ephemeral: true });
        }

        const isStaff = (client.config.tickets.staffRoleIds || []).some(rid => interaction.member.roles.cache.has(rid));
        if (!isStaff && ticket.userId !== interaction.user.id) {
            return interaction.reply({ content: '❌ Only the ticket owner or staff can close this ticket.', ephemeral: true });
        }

        ticketManager.close(interaction.channelId, interaction.user.id, interaction.user.username);

        if (client.config.tickets.logChannelId) {
            const logCh = client.channels.cache.get(client.config.tickets.logChannelId);
            if (logCh) {
                const messages = await interaction.channel.messages.fetch({ limit: 100 });
                const transcript = messages.reverse().map(m => `[${m.createdAt.toISOString()}] ${m.author.tag}: ${m.content}`).join('\n');
                const logEmbed = new EmbedBuilder()
                    .setColor(0x8B93A1)
                    .setTitle('Ticket Closed')
                    .setDescription(`**User:** <@${ticket.userId}>\n**Subject:** ${ticket.subject}\n**Closed by:** ${interaction.user}`)
                    .setTimestamp();
                await logCh.send({ embeds: [logEmbed], files: [{ attachment: Buffer.from(transcript, 'utf8'), name: `transcript-${ticket.id}.txt` }] });
            }
        }

        await interaction.reply('🔒 Closing ticket in 5 seconds...');
        setTimeout(() => interaction.channel.delete().catch(() => {}), 5000);
    }
}

async function sendToReview(interaction, client, app, title, color) {
    const chId = client.config.applications.staffReviewChannelId || client.config.applications.channelId;
    if (!chId) return;
    const ch = client.channels.cache.get(chId);
    if (!ch) return;

    const embed = new EmbedBuilder()
        .setColor(color)
        .setTitle(`New ${title} Application #${app.id}`)
        .setDescription(`**Applicant:** ${interaction.user} (\`${interaction.user.id}\`)\n**Submitted:** <t:${Math.floor(Date.now() / 1000)}:R>`)
        .addFields(app.answers.map(a => ({ name: a.question, value: a.answer.substring(0, 1024), inline: false })))
        .setFooter({ text: 'Review below' });

    const approveBtn = new ButtonBuilder().setCustomId(`app_approve_${app.id}`).setLabel('Approve').setStyle(ButtonStyle.Success).setEmoji('✅');
    const rejectBtn = new ButtonBuilder().setCustomId(`app_reject_${app.id}`).setLabel('Reject').setStyle(ButtonStyle.Danger).setEmoji('❌');
    await ch.send({ embeds: [embed], components: [new ActionRowBuilder().addComponents(approveBtn, rejectBtn)] });
}

async function handleApproval(interaction, client, app) {
    const guild = interaction.guild;

    if (app.type === 'whitelist') {
        try {
            const user = await client.users.fetch(app.userId);
            if (user) await user.send('✅ **Whitelist Approved!** You have been whitelisted on Osven City. Join the server and start playing!');
        } catch {}
        const member = await guild.members.fetch(app.userId).catch(() => null);
        if (member && client.config.applications.approvedRoleId) {
            await member.roles.add(client.config.applications.approvedRoleId).catch(() => {});
        }
    }

    else if (app.type === 'job') {
        const jobLower = app.jobType.toLowerCase().replace(/\s+/g, '');
        const roleKey = JOB_ROLE_MAP[jobLower];
        const roleId = client.config.jobs[roleKey];
        const channelId = client.config.jobs[`${jobLower}ChannelId`];

        try {
            const user = await client.users.fetch(app.userId);
            if (user) await user.send(`✅ **${app.jobType} Application Approved!** You have been accepted into the ${app.jobType} department on Osven City.`);
        } catch {}

        const member = await guild.members.fetch(app.userId).catch(() => null);
        if (member && roleId) {
            await member.roles.add(roleId).catch(() => {});
        }
        if (member && client.config.applications.approvedRoleId) {
            await member.roles.add(client.config.applications.approvedRoleId).catch(() => {});
        }

        // Grant access to private department channel
        if (channelId) {
            const ch = guild.channels.cache.get(channelId);
            if (ch && member) {
                await ch.permissionOverwrites.edit(member, { ViewChannel: true, SendMessages: true, ReadMessageHistory: true }).catch(() => {});
            }
        }
    }

    else if (app.type === 'gang') {
        const gangSlug = app.gangName.toLowerCase().replace(/[^a-z0-9]/g, '');
        const catId = client.config.jobs.categoryId;

        // Create gang-specific roles
        let leaderRole, coLeaderRole, memberRole;
        try {
            leaderRole = await guild.roles.create({
                name: `${app.gangName} Leader`,
                color: '#9B59B6',
                hoist: true,
                reason: `Gang approval: ${app.gangName}`,
            });
            coLeaderRole = await guild.roles.create({
                name: `${app.gangName} Co-Leader`,
                color: '#8E44AD',
                hoist: true,
                reason: `Gang approval: ${app.gangName}`,
            });
            memberRole = await guild.roles.create({
                name: `${app.gangName} Member`,
                color: '#6C3483',
                hoist: true,
                reason: `Gang approval: ${app.gangName}`,
            });
            await delay(500);
        } catch (err) {
            console.error(`[osven-bot] Failed to create gang roles: ${err.message}`);
        }

        // Create private gang channel
        let gangChannel;
        try {
            gangChannel = await guild.channels.create({
                name: `💀 ${gangSlug}-hq`,
                type: ChannelType.GuildText,
                topic: `Private HQ for ${app.gangName}`,
                parent: catId || undefined,
                permissionOverwrites: [
                    { id: guild.roles.everyone, deny: [PermissionFlagsBits.ViewChannel] },
                    ...(leaderRole ? [{ id: leaderRole.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] }] : []),
                    ...(coLeaderRole ? [{ id: coLeaderRole.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] }] : []),
                    ...(memberRole ? [{ id: memberRole.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] }] : []),
                ],
            });
            await delay(500);
        } catch (err) {
            console.error(`[osven-bot] Failed to create gang channel: ${err.message}`);
        }

        // Assign applicant as Leader
        const applicant = await guild.members.fetch(app.userId).catch(() => null);
        if (applicant) {
            if (leaderRole) await applicant.roles.add(leaderRole).catch(() => {});
            try {
                const user = await client.users.fetch(app.userId);
                if (user) await user.send(`✅ **${app.gangName} Gang Approved!** You have been set as Leader. Your private HQ channel is ready.`);
            } catch {}
        }

        // Assign co-leaders
        for (const uid of app.coLeaderIds) {
            const member = await guild.members.fetch(uid).catch(() => null);
            if (!member) continue;
            if (coLeaderRole) await member.roles.add(coLeaderRole).catch(() => {});
            if (gangChannel) {
                await gangChannel.permissionOverwrites.edit(member, { ViewChannel: true, SendMessages: true, ReadMessageHistory: true }).catch(() => {});
            }
            try {
                const user = await client.users.fetch(uid);
                if (user) await user.send(`✅ You have been assigned as **Co-Leader** of **${app.gangName}** on Osven City!`);
            } catch {}
        }

        // Assign members
        for (const uid of app.memberIds) {
            const member = await guild.members.fetch(uid).catch(() => null);
            if (!member) continue;
            if (memberRole) await member.roles.add(memberRole).catch(() => {});
            if (gangChannel) {
                await gangChannel.permissionOverwrites.edit(member, { ViewChannel: true, SendMessages: true, ReadMessageHistory: true }).catch(() => {});
            }
            try {
                const user = await client.users.fetch(uid);
                if (user) await user.send(`✅ You have been added as a **Member** of **${app.gangName}** on Osven City!`);
            } catch {}
        }
    }
}

function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
