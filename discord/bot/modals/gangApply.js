const { ActionRowBuilder, ModalBuilder, TextInputBuilder, TextInputStyle } = require('discord.js');

module.exports = function gangModal() {
    const modal = new ModalBuilder()
        .setCustomId('gang_apply')
        .setTitle('Osven City — Gang Application');

    const q1 = new TextInputBuilder()
        .setCustomId('q_gangName')
        .setLabel('What is your gang name?')
        .setStyle(TextInputStyle.Short)
        .setRequired(true)
        .setPlaceholder('e.g. The Ballas, Grove Street, Vagos');

    const q2 = new TextInputBuilder()
        .setCustomId('q_reason')
        .setLabel('Why should this gang be approved?')
        .setStyle(TextInputStyle.Paragraph)
        .setRequired(true)
        .setPlaceholder('Describe your RP plans, backstory, and activity');

    const q3 = new TextInputBuilder()
        .setCustomId('q_coleaders')
        .setLabel('Co-Leader Discord IDs (comma-separated)')
        .setStyle(TextInputStyle.Paragraph)
        .setRequired(false)
        .setPlaceholder('e.g. 123456789012345678, 987654321098765432');

    const q4 = new TextInputBuilder()
        .setCustomId('q_members')
        .setLabel('Member Discord IDs (comma-separated)')
        .setStyle(TextInputStyle.Paragraph)
        .setRequired(false)
        .setPlaceholder('e.g. 111111111111111111, 222222222222222222');

    const q5 = new TextInputBuilder()
        .setCustomId('q_rules')
        .setLabel('Will all members follow server rules?')
        .setStyle(TextInputStyle.Short)
        .setRequired(true)
        .setPlaceholder('Yes — and explain how you will enforce them');

    modal.addComponents(
        new ActionRowBuilder().addComponents(q1),
        new ActionRowBuilder().addComponents(q2),
        new ActionRowBuilder().addComponents(q3),
        new ActionRowBuilder().addComponents(q4),
        new ActionRowBuilder().addComponents(q5),
    );

    return modal;
};
