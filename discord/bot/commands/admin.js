const { SlashCommandBuilder, EmbedBuilder, ButtonBuilder, ButtonStyle, ActionRowBuilder } = require('discord.js');
const appManager = require('../services/applicationManager');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('admin')
        .setDescription('Admin commands for application management')
        .addSubcommand(sub => sub.setName('review').setDescription('Review pending whitelist applications')
            .addStringOption(opt => opt.setName('type').setDescription('Application type').setRequired(true)
                .addChoices({ name: 'Whitelist', value: 'whitelist' }, { name: 'Job', value: 'job' })))
        .addSubcommand(sub => sub.setName('stats').setDescription('Show application statistics')),

    async execute(interaction, client) {
        const sub = interaction.options.getSubcommand();
        const isStaff = [...(client.config.applications?.staffRoleIds || []), ...(client.config.jobs?.staffRoleIds || [])]
            .some(rid => interaction.member.roles.cache.has(rid));
        if (!isStaff && !interaction.member.permissions.has('Administrator')) {
            return interaction.reply({ content: '❌ You do not have permission to use this command.', ephemeral: true });
        }

        if (sub === 'review') {
            const type = interaction.options.getString('type');
            const pending = appManager.getPending(type);

            if (pending.length === 0) {
                return interaction.reply({ content: `✅ No pending ${type} applications.`, ephemeral: true });
            }

            const app = pending[0]; // Show one at a time
            const answers = app.answers.map(a => `**${a.question}**\n${a.answer}`).join('\n\n');

            const embed = new EmbedBuilder()
                .setColor(0xE8A33D)
                .setTitle(`${type === 'whitelist' ? 'Whitelist' : 'Job'} Application #${app.id}`)
                .setDescription(`**Applicant:** ${app.username} (<@${app.userId}>)\n**Submitted:** <t:${Math.floor(new Date(app.createdAt).getTime() / 1000)}:R>`)
                .addFields(
                    { name: 'Application', value: answers.substring(0, 1024) },
                    ...(app.jobType ? [{ name: 'Job Type', value: app.jobType, inline: true }] : []),
                )
                .setFooter({ text: `Application ${app.id} of ${pending.length} pending • User ID: ${app.userId}` });

            const approveBtn = new ButtonBuilder()
                .setCustomId(`app_approve_${app.id}`)
                .setLabel('Approve')
                .setStyle(ButtonStyle.Success)
                .setEmoji('✅');

            const rejectBtn = new ButtonBuilder()
                .setCustomId(`app_reject_${app.id}`)
                .setLabel('Reject')
                .setStyle(ButtonStyle.Danger)
                .setEmoji('❌');

            const skipBtn = new ButtonBuilder()
                .setCustomId(`app_skip_${app.id}`)
                .setLabel('Skip →')
                .setStyle(ButtonStyle.Secondary);

            await interaction.reply({
                embeds: [embed],
                components: [new ActionRowBuilder().addComponents(approveBtn, rejectBtn, skipBtn)],
                ephemeral: true,
            });
        }

        else if (sub === 'stats') {
            const all = appManager.getAll();
            const whitelistPending = all.filter(a => a.type === 'whitelist' && a.status === 'pending').length;
            const whitelistApproved = all.filter(a => a.type === 'whitelist' && a.status === 'approved').length;
            const whitelistRejected = all.filter(a => a.type === 'whitelist' && a.status === 'rejected').length;
            const jobPending = all.filter(a => a.type === 'job' && a.status === 'pending').length;
            const jobApproved = all.filter(a => a.type === 'job' && a.status === 'approved').length;
            const jobRejected = all.filter(a => a.type === 'job' && a.status === 'rejected').length;

            const embed = new EmbedBuilder()
                .setColor(0x2FB6A6)
                .setTitle('Application Statistics')
                .addFields(
                    { name: '📋 Whitelist', value: `Pending: ${whitelistPending}\nApproved: ${whitelistApproved}\nRejected: ${whitelistRejected}`, inline: true },
                    { name: '💼 Jobs', value: `Pending: ${jobPending}\nApproved: ${jobApproved}\nRejected: ${jobRejected}`, inline: true },
                    { name: 'Total', value: `${all.length} applications`, inline: false },
                )
                .setTimestamp();

            await interaction.reply({ embeds: [embed], ephemeral: true });
        }
    },
};
