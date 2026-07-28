const storage = require('./storage');

const FILE = 'tickets.json';

function getAll() {
    return storage.read(FILE);
}

function save(all) {
    storage.write(FILE, all);
}

function create(data) {
    const all = getAll();
    const ticket = {
        id: all.length > 0 ? Math.max(...all.map(t => t.id)) + 1 : 1,
        userId: data.userId,
        username: data.username,
        channelId: data.channelId,
        subject: data.subject,
        reason: data.reason,
        status: 'open',
        createdAt: new Date().toISOString(),
        closedAt: null,
        closedBy: null,
    };
    all.push(ticket);
    save(all);
    return ticket;
}

function close(channelId, closerId, closerName) {
    const all = getAll();
    const ticket = all.find(t => t.channelId === channelId && t.status === 'open');
    if (!ticket) return null;
    ticket.status = 'closed';
    ticket.closedAt = new Date().toISOString();
    ticket.closedBy = { id: closerId, name: closerName };
    save(all);
    return ticket;
}

function getByChannel(channelId) {
    return getAll().find(t => t.channelId === channelId) || null;
}

function getByUser(userId) {
    return getAll().filter(t => t.userId === userId);
}

function getOpenByUser(userId) {
    return getAll().find(t => t.userId === userId && t.status === 'open');
}

module.exports = { getAll, create, close, getByChannel, getByUser, getOpenByUser };
