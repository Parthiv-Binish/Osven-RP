const { ActionRowBuilder, ModalBuilder, TextInputBuilder, TextInputStyle } = require('discord.js');

module.exports = function whitelistModal() {
    const modal = new ModalBuilder()
        .setCustomId('whitelist_apply')
        .setTitle('Osven City — Whitelist Application');

    const q1 = new TextInputBuilder()
        .setCustomId('q_age')
        .setLabel('How old are you?')
        .setStyle(TextInputStyle.Short)
        .setRequired(true)
        .setPlaceholder('18+ required');

    const q2 = new TextInputBuilder()
        .setCustomId('q_experience')
        .setLabel('Do you have FiveM RP experience?')
        .setStyle(TextInputStyle.Paragraph)
        .setRequired(true)
        .setPlaceholder('Describe your RP experience (servers, hours, etc.)');

    const q3 = new TextInputBuilder()
        .setCustomId('q_reason')
        .setLabel('Why do you want to join Osven City?')
        .setStyle(TextInputStyle.Paragraph)
        .setRequired(true)
        .setPlaceholder('Tell us why you want to be part of the community');

    const q4 = new TextInputBuilder()
        .setCustomId('q_rules')
        .setLabel('Will you follow the server rules?')
        .setStyle(TextInputStyle.Short)
        .setRequired(true)
        .setPlaceholder('Yes / No — explain briefly');

    const q5 = new TextInputBuilder()
        .setCustomId('q_referral')
        .setLabel('How did you find us?')
        .setStyle(TextInputStyle.Short)
        .setRequired(false)
        .setPlaceholder('e.g. Discord, friend, forum, TikTok');

    modal.addComponents(
        new ActionRowBuilder().addComponents(q1),
        new ActionRowBuilder().addComponents(q2),
        new ActionRowBuilder().addComponents(q3),
        new ActionRowBuilder().addComponents(q4),
        new ActionRowBuilder().addComponents(q5),
    );

    return modal;
};
