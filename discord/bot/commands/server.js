const { SlashCommandBuilder, EmbedBuilder } = require('discord.js');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('server')
        .setDescription('Show Osven City server status and info'),

    async execute(interaction, client) {
        await interaction.deferReply();

        try {
            const res = await fetch(`https://servers-frontend.fivem.net/api/servers/single/${client.config.serverId}`, {
                headers: { 'User-Agent': 'OsvenCityBot/1.0' },
            });

            if (!res.ok) {
                return interaction.editReply('❌ Could not fetch server info. Is the server online?');
            }

            const data = await res.json();
            const info = data.Data;
            const vars = info.vars || {};

            const embed = new EmbedBuilder()
                .setColor(0xE8A33D)
                .setTitle('Osven City')
                .setURL(`https://servers.fivem.net/servers/detail/${client.config.serverId}`)
                .addFields(
                    { name: 'Players', value: `${info.Clients ?? 0}/${info.SvMaxclients ?? 48}`, inline: true },
                    { name: 'Status', value: '🟢 Online', inline: true },
                    { name: 'OneSync', value: info.Official ? 'Yes' : 'No', inline: true },
                    { name: 'Hostname', value: vars.sv_hostName || 'Osven City', inline: false },
                    { name: 'Server ID', value: client.config.serverId, inline: false },
                )
                .setFooter({ text: 'Osven City Bot' })
                .setTimestamp();

            await interaction.editReply({ embeds: [embed] });
        } catch (err) {
            console.error('[osven-bot] /server error:', err.message);
            await interaction.editReply('❌ Error fetching server info.');
        }
    },
};
