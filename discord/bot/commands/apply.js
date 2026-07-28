const { SlashCommandBuilder, EmbedBuilder, ActionRowBuilder, StringSelectMenuBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
const whitelistModal = require('../modals/whitelistApply');
const jobModal = require('../modals/jobApply');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('apply')
        .setDescription('Submit a whitelist or job application')
        .addSubcommand(sub => sub.setName('whitelist').setDescription('Apply for server whitelist'))
        .addSubcommand(sub => sub.setName('job').setDescription('Apply for a job').addStringOption(opt =>
            opt.setName('type').setDescription('Job type').setRequired(true)
                .addChoices(
                    { name: 'Police', value: 'police' },
                    { name: 'EMS', value: 'ems' },
                    { name: 'Mechanic', value: 'mechanic' },
                    { name: 'Real Estate', value: 'realestate' },
                    { name: 'News', value: 'news' }
                )
        )),

    async execute(interaction, client) {
        const sub = interaction.options.getSubcommand();

        if (sub === 'whitelist') {
            if (!client.config.applications?.enabled) {
                return interaction.reply({ content: '❌ Applications are currently disabled.', ephemeral: true });
            }

            const appManager = require('../services/applicationManager');
            const cooldown = appManager.getRecentCooldown(interaction.user.id, 'whitelist',
                (client.config.applications.cooldownDays || 7) * 86400000);
            if (cooldown) {
                const days = Math.ceil((Date.now() - new Date(cooldown.createdAt).getTime()) / 86400000);
                return interaction.reply({
                    content: `⏳ You applied ${days} day(s) ago. Please wait ${client.config.applications.cooldownDays - days} more day(s) before reapplying.`,
                    ephemeral: true,
                });
            }

            const modal = whitelistModal();
            await interaction.showModal(modal);
        } else if (sub === 'job') {
            if (!client.config.jobs?.enabled) {
                return interaction.reply({ content: '❌ Job applications are currently disabled.', ephemeral: true });
            }

            const type = interaction.options.getString('type');
            const modal = jobModal(type.charAt(0).toUpperCase() + type.slice(1));
            await interaction.showModal(modal);
        }
    },
};
