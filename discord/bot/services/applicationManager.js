const storage = require('./storage');

const FILE = 'applications.json';

// Application statuses: pending, approved, rejected
const STATUS = { PENDING: 'pending', APPROVED: 'approved', REJECTED: 'rejected' };

function getAll() {
    return storage.read(FILE);
}

function save(all) {
    storage.write(FILE, all);
}

function create(data) {
    const all = getAll();
    const app = {
        id: all.length > 0 ? Math.max(...all.map(a => a.id)) + 1 : 1,
        userId: data.userId,
        username: data.username,
        type: data.type,          // 'whitelist' or 'job'
        jobType: data.jobType || null,
        answers: data.answers,    // array of { question, answer }
        status: STATUS.PENDING,
        reviewedBy: null,
        reviewNote: null,
        createdAt: new Date().toISOString(),
        reviewedAt: null,
    };
    all.push(app);
    save(all);
    return app;
}

function getPending(type) {
    return getAll().filter(a => a.status === STATUS.PENDING && a.type === type);
}

function getByUser(userId) {
    return getAll().filter(a => a.userId === userId);
}

function review(appId, reviewerId, reviewerName, status, note) {
    const all = getAll();
    const app = all.find(a => a.id === appId);
    if (!app) return null;
    app.status = status;
    app.reviewedBy = { id: reviewerId, name: reviewerName };
    app.reviewNote = note || null;
    app.reviewedAt = new Date().toISOString();
    save(all);
    return app;
}

function getRecentCooldown(userId, type, cooldownMs) {
    const apps = getByUser(userId);
    const cutoff = Date.now() - cooldownMs;
    return apps.find(a => a.type === type && new Date(a.createdAt).getTime() > cutoff);
}

module.exports = { STATUS, getAll, create, getPending, getByUser, review, getRecentCooldown };
