const { SlashCommandBuilder, EmbedBuilder, ButtonBuilder, ButtonStyle, ActionRowBuilder, PermissionFlagsBits } = require('discord.js');
const ticketManager = require('../services/ticketManager');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('ticket')
        .setDescription('Support ticket system')
        .addSubcommand(sub => sub.setName('open').setDescription('Open a support ticket')
            .addStringOption(opt => opt.setName('subject').setDescription('Brief subject').setRequired(true))
            .addStringOption(opt => opt.setName('reason').setDescription('Describe your issue').setRequired(true)))
        .addSubcommand(sub => sub.setName('close').setDescription('Close your current support ticket'))
        .addSubcommand(sub => sub.setName('add').setDescription('Add a user to the ticket (staff only)')
            .addUserOption(opt => opt.setName('user').setDescription('User to add').setRequired(true))),

    async execute(interaction, client) {
        const sub = interaction.options.getSubcommand();
        const config = client.config.tickets;
        if (!config?.enabled) {
            return interaction.reply({ content: '❌ Tickets are currently disabled.', ephemeral: true });
        }

        if (sub === 'open') {
            const existing = ticketManager.getOpenByUser(interaction.user.id);
            if (existing) {
                return interaction.reply({
                    content: `⚠️ You already have an open ticket: <#${existing.channelId}>. Please close it before opening a new one.`,
                    ephemeral: true,
                });
            }

            await interaction.deferReply({ ephemeral: true });

            const subject = interaction.options.getString('subject');
            const reason = interaction.options.getString('reason');

            const channel = await interaction.guild.channels.create({
                name: `ticket-${interaction.user.username.toLowerCase().replace(/[^a-z0-9]/g, '')}`,
                type: 0, // GuildText
                parent: config.categoryId,
                permissionOverwrites: [
                    { id: interaction.guild.roles.everyone, deny: [PermissionFlagsBits.ViewChannel] },
                    { id: interaction.user.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] },
                    ...(config.staffRoleIds || []).map(roleId => ({
                        id: roleId,
                        allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory],
                    })),
                ],
            });

            ticketManager.create({
                userId: interaction.user.id,
                username: interaction.user.username,
                channelId: channel.id,
                subject,
                reason,
            });

            const embed = new EmbedBuilder()
                .setColor(0x2FB6A6)
                .setTitle('Support Ticket')
                .setDescription(`**Subject:** ${subject}\n**Issue:** ${reason}`)
                .setFooter({ text: `User ID: ${interaction.user.id}` })
                .setTimestamp();

            const closeBtn = new ButtonBuilder()
                .setCustomId('ticket_close')
                .setLabel('Close Ticket')
                .setStyle(ButtonStyle.Danger)
                .setEmoji('🔒');

            await channel.send({ content: `<@${interaction.user.id}> — Support team will be with you shortly.`, embeds: [embed], components: [new ActionRowBuilder().addComponents(closeBtn)] });
            await interaction.editReply({ content: `✅ Ticket created: ${channel}`);
        }

        else if (sub === 'close') {
            const ticket = ticketManager.getByChannel(interaction.channelId);
            if (!ticket || ticket.userId !== interaction.user.id) {
                return interaction.reply({ content: '❌ This command only works in your own open ticket channel.', ephemeral: true });
            }

            const closed = ticketManager.close(interaction.channelId, interaction.user.id, interaction.user.username);
            if (closed) {
                await interaction.reply('🔒 Closing ticket in 5 seconds...');
                setTimeout(() => interaction.channel.delete().catch(() => {}), 5000);
            }
        }

        else if (sub === 'add') {
            const ticket = ticketManager.getByChannel(interaction.channelId);
            if (!ticket) {
                return interaction.reply({ content: '❌ This is not a ticket channel.', ephemeral: true });
            }

            const isStaff = (config.staffRoleIds || []).some(rid => interaction.member.roles.cache.has(rid));
            if (!isStaff && ticket.userId !== interaction.user.id) {
                return interaction.reply({ content: '❌ You do not have permission.', ephemeral: true });
            }

            const user = interaction.options.getUser('user');
            await interaction.channel.permissionOverwrites.create(user.id, {
                ViewChannel: true,
                SendMessages: true,
                ReadMessageHistory: true,
            });
            await interaction.reply({ content: `✅ Added ${user} to the ticket.`, ephemeral: true });
        }
    },
};
