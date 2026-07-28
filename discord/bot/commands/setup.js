const { SlashCommandBuilder, EmbedBuilder } = require('discord.js');
const { runSetup } = require('../services/autoSetup');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('setup')
        .setDescription('Auto-create all required channels, categories, and roles')
        .setDefaultMemberPermissions(8), // Administrator only

    async execute(interaction, client) {
        await interaction.deferReply({ ephemeral: true });

        const setup = await runSetup(interaction.guild, client);

        const embed = new EmbedBuilder()
            .setColor(0x2FB6A6)
            .setTitle('✅ Osven City — Setup Complete')
            .setDescription('All channels, categories, and roles have been created.')
            .addFields(
                { name: '📁 Categories', value: Object.entries(setup.categories).map(([k, v]) => `\`${k}\`: <#${v}>`).join('\n') || 'None', inline: true },
                { name: '📢 Channels', value: Object.entries(setup.channels).map(([k, v]) => `\`${k}\`: <#${v}>`).join('\n') || 'None', inline: true },
                { name: '👤 Roles', value: Object.entries(setup.roles).map(([k, v]) => `\`${k}\`: <@&${v}>`).join('\n') || 'None', inline: true },
            )
            .setFooter({ text: 'Copy these IDs into config.js for persistence' })
            .setTimestamp();

        // Also output raw IDs to console for easy copying
        console.log('\n[osven-bot] === SETUP IDs — Copy these into config.js ===');
        console.log(JSON.stringify(setup, null, 2));
        console.log('[osven-bot] ============================================\n');

        await interaction.editReply({ embeds: [embed] });
    },
};
