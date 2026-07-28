const tips = [
    'Stay in character at all times.',
    'Respect other players — it\'s a shared world.',
    'Use /me for actions, /do for descriptions.',
    'Need help? Contact staff via /report.',
    'Keep an eye on your vitals in the HUD.',
    'Visit the bank to deposit your cash.',
    'Join a whitelisted job to earn money.',
    'Lock your vehicle to prevent theft.',
];

let tipIndex = 0;
let progress = 0;

function rotateTip() {
    const el = document.getElementById('tip-text');
    el.style.opacity = '0';
    setTimeout(() => {
        tipIndex = (tipIndex + 1) % tips.length;
        el.textContent = tips[tipIndex];
        el.style.opacity = '1';
    }, 280);
}

function simulateProgress() {
    const fill = document.getElementById('progress-fill');
    if (progress < 95) {
        progress += Math.random() * 3 + 1;
        if (progress > 95) progress = 95;
        fill.style.width = `${progress}%`;
    }
}

setInterval(rotateTip, 7000);
setInterval(simulateProgress, 300);

// Listen for NUI progress updates
window.addEventListener('message', function(event) {
    const data = event.data;
    if (data && data.progress !== undefined) {
        progress = data.progress;
        document.getElementById('progress-fill').style.width = `${Math.min(progress, 100)}%`;
    }
    if (data && data.type === 'shutdown') {
        // Loading complete - fade out
        document.body.style.transition = 'opacity 0.5s ease';
        document.body.style.opacity = '0';
    }
});
