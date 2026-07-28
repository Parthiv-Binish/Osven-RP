const storage = require('./storage');

const FILE = 'bans.json';

function getAll() {
    return storage.read(FILE);
}

function save(all) {
    storage.write(FILE, all);
}

function addBan(data) {
    const all = getAll();
    const ban = {
        id: all.length > 0 ? Math.max(...all.map(b => b.id)) + 1 : 1,
        playerName: data.playerName,
        discordId: data.discordId || null,
        citizenId: data.citizenId || null,
        reason: data.reason,
        bannedBy: data.bannedBy,
        duration: data.duration,    // 'permanent' or human-readable like '7 days'
        isPermanent: data.isPermanent || false,
        timestamp: new Date().toISOString(),
    };
    all.push(ban);
    save(all);
    return ban;
}

module.exports = { getAll, addBan };
