const fs = require('fs');
const path = require('path');
const SETUP_FILE = path.join(__dirname, '..', 'data', 'setup.json');

module.exports = {
    name: 'guildMemberAdd',
    async execute(member, client) {
        // Read default role from setup
        let defaultRoleId = null;
        try {
            if (fs.existsSync(SETUP_FILE)) {
                const setup = JSON.parse(fs.readFileSync(SETUP_FILE, 'utf8'));
                defaultRoleId = setup.roles?.defaultRole || null;
            }
        } catch { }

        if (defaultRoleId) {
            const role = member.guild.roles.cache.get(defaultRoleId);
            if (role) {
                await member.roles.add(role).catch(() => {});
                console.log(`[osven-bot] Assigned @${role.name} to ${member.user.tag}`);
            }
        }

        // Welcome message in general channel
        let welcomeChId = client.config.welcomeChannelId || null;
        let applyChId = null;
        try {
            if (fs.existsSync(SETUP_FILE)) {
                const setup = JSON.parse(fs.readFileSync(SETUP_FILE, 'utf8'));
                if (!welcomeChId) welcomeChId = setup.channels?.generalChannel || null;
                applyChId = setup.channels?.applicationsChannel || null;
            }
        } catch { }

        if (welcomeChId) {
            const ch = member.guild.channels.cache.get(welcomeChId);
            if (ch) {
                const applyPing = applyChId ? `<#${applyChId}>` : 'the whitelist-apps channel';
                await ch.send(`👋 Welcome ${member} to **Osven City**! Head over to ${applyPing} to apply for whitelist!`).catch(() => {});
            }
        }
    },
};
