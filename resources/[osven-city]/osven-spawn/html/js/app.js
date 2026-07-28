new Vue({
    el: '#app',
    data: {
        visible: false,
        playerName: 'Citizen',
        locations: [],
        selected: null,
        spawning: false,
        lastTimestamp: null,
    },
    methods: {
        select: function (loc) {
            this.selected = loc.id;
        },
        doSpawn: function () {
            if (!this.selected || this.spawning) return;
            this.spawning = true;
            fetch('https://' + (window.location.hostname || 'osven-spawn') + '/spawn:select', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id: this.selected })
            });
        }
    },
    mounted: function () {
        var self = this;
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || data.type !== 'OPEN_SPAWN') return;

            self.playerName = data.data.name || 'Citizen';
            self.locations = data.data.locations || [];
            self.lastTimestamp = data.data.lastTimestamp || null;
            self.selected = null;
            self.spawning = false;
            self.visible = true;
        });
    }
});
