const { EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
const appManager = require('../services/applicationManager');
const ticketManager = require('../services/ticketManager');

module.exports = {
    name: 'interactionCreate',
    async execute(interaction, client) {
        // Slash commands
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

        // Modals (applications)
        if (interaction.isModalSubmit()) {
            await handleModal(interaction, client);
            return;
        }

        // Buttons (review, ticket close)
        if (interaction.isButton()) {
            await handleButton(interaction, client);
            return;
        }
    },
};

async function handleModal(interaction, client) {
    const { customId } = interaction;

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

        // Notify admin channel
        if (client.config.applications.channelId) {
            const ch = client.channels.cache.get(client.config.applications.channelId);
            if (ch) {
                const embed = new EmbedBuilder()
                    .setColor(0xE8A33D)
                    .setTitle(`New Whitelist Application #${app.id}`)
                    .setDescription(`**Applicant:** ${interaction.user} (\`${interaction.user.id}\`)\n**Submitted:** <t:${Math.floor(Date.now() / 1000)}:R>`)
                    .addFields(answers.map(a => ({ name: a.question, value: a.answer.substring(0, 1024), inline: false })))
                    .setFooter({ text: 'Use /admin review to process applications' });

                const approveBtn = new ButtonBuilder().setCustomId(`app_approve_${app.id}`).setLabel('Approve').setStyle(ButtonStyle.Success).setEmoji('✅');
                const rejectBtn = new ButtonBuilder().setCustomId(`app_reject_${app.id}`).setLabel('Reject').setStyle(ButtonStyle.Danger).setEmoji('❌');
                await ch.send({ embeds: [embed], components: [new ActionRowBuilder().addComponents(approveBtn, rejectBtn)] });
            }
        }

        await interaction.reply({ content: '✅ Your whitelist application has been submitted! Staff will review it shortly.', ephemeral: true });
    }

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

        if (client.config.jobs.channelId) {
            const ch = client.channels.cache.get(client.config.jobs.channelId);
            if (ch) {
                const embed = new EmbedBuilder()
                    .setColor(0x2FB6A6)
                    .setTitle(`New ${jobName} Application #${app.id}`)
                    .setDescription(`**Applicant:** ${interaction.user} (\`${interaction.user.id}\`)\n**Submitted:** <t:${Math.floor(Date.now() / 1000)}:R>`)
                    .addFields(answers.map(a => ({ name: a.question, value: a.value.substring(0, 1024), inline: false })))
                    .setFooter({ text: 'Use /admin review to process applications' });

                const approveBtn = new ButtonBuilder().setCustomId(`app_approve_${app.id}`).setLabel('Approve').setStyle(ButtonStyle.Success).setEmoji('✅');
                const rejectBtn = new ButtonBuilder().setCustomId(`app_reject_${app.id}`).setLabel('Reject').setStyle(ButtonStyle.Danger).setEmoji('❌');
                await ch.send({ embeds: [embed], components: [new ActionRowBuilder().addComponents(approveBtn, rejectBtn)] });
            }
        }

        await interaction.reply({ content: `✅ Your ${jobName} application has been submitted!`, ephemeral: true });
    }
}

async function handleButton(interaction, client) {
    const { customId } = interaction;

    // Whitelist apply button (from persistent message)
    if (customId === 'apply_whitelist_btn') {
        const whitelistModal = require('../modals/whitelistApply');
        await interaction.showModal(whitelistModal());
        return;
    }

    // Application approve/reject
    if (customId.startsWith('app_')) {
        const parts = customId.split('_');
        const action = parts[1]; // approve, reject, skip
        const appId = parseInt(parts[2]);

        if (action === 'skip') {
            await interaction.update({ content: '⏭️ Skipped — use `/admin review` for the next one.', embeds: [], components: [] });
            return;
        }

        const app = appManager.review(appId, interaction.user.id, interaction.user.username, action === 'approve' ? 'approved' : 'rejected', null);
        if (!app) {
            await interaction.reply({ content: '❌ Application not found.', ephemeral: true });
            return;
        }

        // DM the applicant
        try {
            const user = await interaction.client.users.fetch(app.userId);
            if (user) {
                if (action === 'approve') {
                    await user.send(`✅ **Whitelist Approved!** You have been whitelisted on Osven City. Join the server and start playing!`);
                    // Assign the approved role
                    const member = await interaction.guild.members.fetch(app.userId).catch(() => null);
                    if (member && client.config.applications.approvedRoleId) {
                        await member.roles.add(client.config.applications.approvedRoleId).catch(() => {});
                    }
                } else {
                    await user.send(`❌ **Application Rejected**\nYour ${app.type} application (#${app.id}) was not approved. You may re-apply later.`);
                }
            }
        } catch (e) { /* DM may be closed */ }

        await interaction.update({
            content: `✅ Application #${appId} **${action === 'approve' ? 'Approved' : 'Rejected'}** by ${interaction.user}`,
            embeds: [],
            components: [],
        });
    }

    // Ticket close
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

        // Log transcript
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
