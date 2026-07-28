window.addEventListener('message', function(event) {
    var data = event.data;
    if (data.action === 'open') {
        document.getElementById('radio-ui').style.display = 'block';
        if (data.channel) {
            document.getElementById('channel-value').textContent = data.channel;
        }
    } else if (data.action === 'close') {
        document.getElementById('radio-ui').style.display = 'none';
    }
});

document.getElementById('join-btn').addEventListener('click', function() {
    var channel = document.getElementById('channel-input').value;
    if (channel) {
        fetch('https://osven-radio/joinChannel', {
            method: 'POST',
            body: JSON.stringify({ channel: channel }),
            headers: { 'Content-Type': 'application/json' }
        });
    }
});

document.getElementById('leave-btn').addEventListener('click', function() {
    fetch('https://osven-radio/leaveChannel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    });
});

document.getElementById('volume-slider').addEventListener('input', function() {
    fetch('https://osven-radio/volumeChange', {
        method: 'POST',
        body: JSON.stringify({ volume: this.value }),
        headers: { 'Content-Type': 'application/json' }
    });
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        fetch('https://osven-radio/close', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
    }
});
