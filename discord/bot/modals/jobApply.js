const { ActionRowBuilder, ModalBuilder, TextInputBuilder, TextInputStyle } = require('discord.js');

module.exports = function jobModal(jobType) {
    const modal = new ModalBuilder()
        .setCustomId(`job_apply_${jobType.toLowerCase()}`)
        .setTitle(`Osven City — ${jobType} Application`);

    const q1 = new TextInputBuilder()
        .setCustomId('q_age')
        .setLabel('How old are you?')
        .setStyle(TextInputStyle.Short)
        .setRequired(true)
        .setPlaceholder('18+ required');

    const q2 = new TextInputBuilder()
        .setCustomId('q_experience')
        .setLabel(`Do you have ${jobType} RP experience?`)
        .setStyle(TextInputStyle.Paragraph)
        .setRequired(true)
        .setPlaceholder(`Describe your ${jobType} experience`);

    const q3 = new TextInputBuilder()
        .setCustomId('q_reason')
        .setLabel(`Why do you want to join ${jobType}?`)
        .setStyle(TextInputStyle.Paragraph)
        .setRequired(true)
        .setPlaceholder('Tell us why you want this job');

    const q4 = new TextInputBuilder()
        .setCustomId('q_availability')
        .setLabel('How many hours can you play per week?')
        .setStyle(TextInputStyle.Short)
        .setRequired(true)
        .setPlaceholder('e.g. 10-15 hours');

    modal.addComponents(
        new ActionRowBuilder().addComponents(q1),
        new ActionRowBuilder().addComponents(q2),
        new ActionRowBuilder().addComponents(q3),
        new ActionRowBuilder().addComponents(q4),
    );

    return modal;
};
