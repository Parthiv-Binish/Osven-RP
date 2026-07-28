const { SlashCommandBuilder } = require('discord.js');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('ping')
        .setDescription('Check bot latency'),

    async execute(interaction, client) {
        const latency = Math.round(client.ws.ping);
        await interaction.reply(`🏓 Pong! Latency: ${latency}ms`);
    },
};
