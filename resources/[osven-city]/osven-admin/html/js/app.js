new Vue({
    el: '#app',
    data: {
        visible: false,
        activeTab: 'players',
        tabs: [
            { id: 'players', label: 'Players' },
            { id: 'world', label: 'World' },
            { id: 'territories', label: 'Territories' },
            { id: 'logs', label: 'Logs' },
        ],
        playerSearch: '',
        players: [],
        /* World */
        weather: 'EXTRASUNNY',
        weathers: ['EXTRASUNNY', 'CLEAR', 'CLOUDS', 'SMOG', 'FOGGY', 'OVERCAST', 'RAIN', 'THUNDER', 'CLEARING', 'NEUTRAL', 'SNOW', 'BLIZZARD', 'SNOWLIGHT', 'XMAS', 'HALLOWEEN'],
        timeHour: 12,
        timeMinute: 0,
        vehicleModel: '',
        announcement: '',
        /* Territories */
        territories: [],
        gangOptions: ['lostmc', 'ballas', 'vagos', 'cartel', 'families', 'triads'],
        /* Logs */
        logFilter: '',
        logs: [],
        /* Confirmation */
        confirmVisible: false,
        confirmActionType: '',
        confirmTarget: null,
        confirmReason: '',
        confirmAmount: 0,
        confirmItemName: '',
    },
    computed: {
        filteredPlayers: function () {
            var self = this;
            var s = this.playerSearch.toLowerCase();
            if (!s) return this.players;
            return this.players.filter(function (p) {
                return p.name.toLowerCase().includes(s) || String(p.serverId).includes(s);
            });
        },
        filteredLogs: function () {
            var self = this;
            var f = this.logFilter.toLowerCase();
            if (!f) return this.logs;
            return this.logs.filter(function (l) {
                return l.action.toLowerCase().includes(f) || l.actionType.toLowerCase().includes(f);
            });
        },
        confirmTitle: function () {
            var map = { kick: 'Kick Player', ban: 'Ban Player', giveMoney: 'Give Money', giveItem: 'Give Item' };
            return map[this.confirmActionType] || 'Confirm Action';
        },
        confirmDesc: function () {
            if (!this.confirmTarget) return '';
            var map = {
                kick: 'Kick ' + this.confirmTarget.name + '? This will disconnect them.',
                ban: 'Ban ' + this.confirmTarget.name + '? This cannot be undone.',
                giveMoney: 'Give money to ' + this.confirmTarget.name + '?',
                giveItem: 'Give item to ' + this.confirmTarget.name + '?',
            };
            return map[this.confirmActionType] || '';
        },
        confirmNeedsReason: function () {
            return this.confirmActionType === 'kick' || this.confirmActionType === 'ban';
        },
        confirmNeedsAmount: function () {
            return this.confirmActionType === 'giveMoney';
        },
    },
    methods: {
        doAction: function (action, serverId) {
            fetch('https://' + (window.location.hostname || 'osven-admin') + '/admin:action', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: action, target: serverId }),
            });
        },
        confirmAction: function (type, player) {
            this.confirmActionType = type;
            this.confirmTarget = player;
            this.confirmReason = '';
            this.confirmAmount = 0;
            this.confirmItemName = '';
            this.confirmVisible = true;
        },
        cancelConfirm: function () {
            this.confirmVisible = false;
            this.confirmTarget = null;
            this.confirmReason = '';
            this.confirmAmount = 0;
            this.confirmItemName = '';
        },
        executeConfirm: function () {
            if (!this.confirmTarget) return;
            if (this.confirmNeedsReason && !this.confirmReason.trim()) return;
            if (this.confirmNeedsAmount && (!this.confirmAmount || this.confirmAmount <= 0)) return;

            var payload = {
                action: this.confirmActionType,
                target: this.confirmTarget.serverId,
                reason: this.confirmReason,
                amount: this.confirmAmount,
                item: this.confirmItemName,
            };
            fetch('https://' + (window.location.hostname || 'osven-admin') + '/admin:action', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
            });
            this.cancelConfirm();
        },
        setWeather: function () {
            this.doAction('weather', this.weather);
        },
        setTime: function () {
            this.doAction('setTime', this.timeHour + ':' + this.timeMinute);
        },
        freezeTime: function () {
            this.doAction('freezeTime', '');
        },
        spawnVehicle: function () {
            this.doAction('spawnVehicle', this.vehicleModel);
            this.vehicleModel = '';
        },
        sendAnnouncement: function () {
            this.doAction('announce', this.announcement);
            this.announcement = '';
        },
        /* Territory methods */
        setTerritoryOwner: function (zoneId, gang) {
            fetch('https://' + (window.location.hostname || 'osven-admin') + '/admin:territoryAction', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'setOwner', zoneId: zoneId, gang: gang || 'none' }),
            });
        },
        resetAllTerritories: function () {
            if (!confirm('Reset ALL territories to unowned?')) return;
            fetch('https://' + (window.location.hostname || 'osven-admin') + '/admin:territoryAction', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'resetAll' }),
            });
        },
        close: function () {
            this.visible = false;
            this.confirmVisible = false;
            fetch('https://' + (window.location.hostname || 'osven-admin') + '/admin:close', {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
            });
        },
    },
    mounted: function () {
        var self = this;
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || !data.type) return;
            if (data.type === 'OPEN_ADMIN') {
                self.players = data.players || [];
                self.logs = data.logs || [];
                self.territories = (data.territories || []).map(function (t) { t.selectedGang = t.owner !== 'none' ? t.owner : 'none'; return t; });
                self.activeTab = 'players';
                self.playerSearch = '';
                self.logFilter = '';
                self.visible = true;
            }
        });
    },
});
