const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');

function ensureFile(name) {
    const filePath = path.join(DATA_DIR, name);
    if (!fs.existsSync(filePath)) {
        fs.writeFileSync(filePath, JSON.stringify([]));
    }
    return filePath;
}

function read(name) {
    const filePath = ensureFile(name);
    try {
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch {
        return [];
    }
}

function write(name, data) {
    const filePath = ensureFile(name);
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

module.exports = { read, write };
