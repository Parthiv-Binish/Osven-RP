// ═══════════════════════════════════════════════════════════════════════════
//  Osven City HUD v2.0 — Client UI Logic
// ═══════════════════════════════════════════════════════════════════════════

const state = {
    health: 100,
    maxHealth: 100,
    armor: 0,
    oxygen: -1,
    hunger: 100,
    thirst: 100,
    stress: 0,
    cash: 0,
    bank: 0,
    bankVisible: false,
    voiceRange: 0,
};

// ── DOM refs ──
const $ = id => document.getElementById(id);
const el = {
    playerName: $('player-name'),
    jobTitle: $('job-title'),
    cashDisplay: $('cash-display'),
    bankDisplay: $('bank-display'),
    healthFill: $('health-fill'),
    armorRing: $('armor-ring'),
    armorFill: $('armor-fill'),
    hungerFill: $('hunger-fill'),
    thirstFill: $('thirst-fill'),
    stressBar: $('stress-bar'),
    stressFill: $('stress-fill'),
    voiceIndicator: $('voice-indicator'),
    oxygenOverlay: $('oxygen-overlay'),
    oxygenFill: $('oxygen-fill'),
    notifications: $('notification-container'),
};

// ── SVG ring circumference (r=18 → 2πr ≈ 113.097) ──
const CIRCUMFERENCE = 2 * Math.PI * 18;

function setRingFill(el, pct) {
    if (!el) return;
    const offset = CIRCUMFERENCE - (CIRCUMFERENCE * Math.min(pct, 100) / 100);
    el.style.strokeDasharray = `${CIRCUMFERENCE}`;
    el.style.strokeDashoffset = `${offset}`;
}

// ── NUI Message Handler ──
window.addEventListener('message', function(event) {
    const { action, data } = event.data;
    if (!action) return;

    switch (action) {
        case 'setPlayerName':
            el.playerName.textContent = data;
            break;

        case 'updateVitals':
            if (data.health !== undefined) {
                state.health = data.health;
                state.maxHealth = data.maxHealth || 100;
                const pct = (state.health / state.maxHealth) * 100;
                setRingFill(el.healthFill, pct);
            }
            if (data.armor !== undefined) {
                state.armor = data.armor;
                if (state.armor > 0) {
                    el.armorRing.classList.remove('hidden');
                    setRingFill(el.armorFill, state.armor);
                } else {
                    el.armorRing.classList.add('hidden');
                }
            }
            if (data.oxygen !== undefined) {
                state.oxygen = data.oxygen;
                if (state.oxygen >= 0) {
                    el.oxygenOverlay.classList.remove('hidden');
                    setRingFill(el.oxygenFill, (state.oxygen / 10) * 100);
                } else {
                    el.oxygenOverlay.classList.add('hidden');
                }
            }
            break;

        case 'updateStatus':
            if (data.hunger !== undefined) {
                state.hunger = data.hunger;
                el.hungerFill.style.width = `${Math.min(state.hunger, 100)}%`;
            }
            if (data.thirst !== undefined) {
                state.thirst = data.thirst;
                el.thirstFill.style.width = `${Math.min(state.thirst, 100)}%`;
            }
            if (data.stress !== undefined) {
                state.stress = data.stress;
                if (state.stress >= 40) {
                    el.stressBar.classList.remove('hidden');
                    el.stressFill.style.width = `${Math.min(state.stress, 100)}%`;
                } else {
                    el.stressBar.classList.add('hidden');
                }
            }
            break;

        case 'updateMoney':
            if (data.cash !== undefined) {
                state.cash = data.cash;
                el.cashDisplay.textContent = `₹${formatNumber(state.cash)}`;
            }
            if (data.bank !== undefined) {
                state.bank = data.bank;
                state.bankVisible = data.bankVisible || false;
                el.bankDisplay.textContent = state.bankVisible
                    ? `₹${formatNumber(state.bank)}`
                    : '•••';
            }
            if (data.job) {
                el.jobTitle.textContent = `${data.job}${data.jobGrade ? ' — ' + data.jobGrade : ''}`;
            }
            break;

        case 'setVoice':
            if (data.range !== undefined) {
                state.voiceRange = data.range;
                if (state.voiceRange > 0) {
                    el.voiceIndicator.classList.remove('hidden');
                    const icons = { 1: '🔈', 2: '🔉', 3: '🔊' };
                    el.voiceIndicator.querySelector('#voice-icon').textContent = icons[state.voiceRange] || '🔊';
                } else {
                    el.voiceIndicator.classList.add('hidden');
                }
            }
            break;

        case 'notify':
            showNotification(data);
            break;
    }
});

// ── Notifications ──
function showNotification(data) {
    const notif = document.createElement('div');
    notif.className = `notification ${data.type || 'info'}`;

    if (data.title) {
        const title = document.createElement('div');
        title.className = 'notification-title';
        title.textContent = data.title;
        notif.appendChild(title);
    }

    const msg = document.createElement('div');
    msg.className = 'notification-message';
    msg.textContent = data.message || '';
    notif.appendChild(msg);

    if (data.type === 'admin') {
        notif.classList.add('admin');
        const dismiss = document.createElement('div');
        dismiss.className = 'notification-time';
        dismiss.textContent = 'Dismiss';
        dismiss.style.cursor = 'pointer';
        dismiss.style.marginTop = '4px';
        dismiss.onclick = () => notif.remove();
        notif.appendChild(dismiss);
    } else {
        const time = document.createElement('div');
        time.className = 'notification-time';
        const now = new Date();
        time.textContent = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        notif.appendChild(time);
        setTimeout(() => {
            notif.style.animation = 'slideOut 0.28s ease-out forwards';
            setTimeout(() => notif.remove(), 280);
        }, data.duration || 5000);
    }

    el.notifications.appendChild(notif);
}

// ── Utility ──
function formatNumber(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// ── Ready ──
document.addEventListener('DOMContentLoaded', function() {
    setRingFill(el.healthFill, 100);
    setRingFill(el.armorFill, 0);
    el.armorRing.classList.add('hidden');
    el.oxygenOverlay.classList.add('hidden');
    el.stressBar.classList.add('hidden');
    el.voiceIndicator.classList.add('hidden');
});
