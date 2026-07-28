module.exports = {
    name: 'voiceStateUpdate',
    async execute(oldState, newState, client) {
    const tv = client.config.tempVoice;
    if (!tv?.joinToCreateChannelId || !tv?.categoryId) return;

        // User joined the "join-to-create" channel
        if (newState.channelId === tv.joinToCreateChannelId && oldState.channelId !== tv.joinToCreateChannelId) {
            const guild = newState.guild;
            const member = newState.member;

            try {
                const channel = await guild.channels.create({
                    name: `${member.displayName}'s Channel`,
                    type: 2, // GuildVoice
                    parent: tv.categoryId,
                    userLimit: 0,
                    permissionOverwrites: [
                        {
                            id: member.id,
                            allow: ['ManageChannels', 'MuteMembers', 'DeafenMembers', 'MoveMembers'],
                        },
                        {
                            id: guild.roles.everyone,
                            allow: ['Connect'],
                        },
                    ],
                });

                // Move user to their new channel
                await member.voice.setChannel(channel);

                // Clean up empty temp channels periodically
                const checkInterval = setInterval(async () => {
                    if (channel.members.size === 0) {
                        clearInterval(checkInterval);
                        await channel.delete().catch(() => {});
                    }
                }, 30000); // check every 30s
            } catch (err) {
                console.error('[osven-bot] Failed to create temp VC:', err.message);
            }
        }

        // User left the join-to-create channel (clean up empty temp channels)
        if (oldState.channelId && oldState.channelId !== tv.joinToCreateChannelId) {
            const channel = oldState.channel;
            if (channel && channel.parentId === tv.categoryId && channel.members.size === 0) {
                if (channel.id !== tv.joinToCreateChannelId) {
                    setTimeout(() => {
                        // Re-check after delay in case someone is reconnecting
                        const ch = oldState.guild.channels.cache.get(channel.id);
                        if (ch && ch.members.size === 0) {
                            ch.delete().catch(() => {});
                        }
                    }, 5000);
                }
            }
        }
    },
};
