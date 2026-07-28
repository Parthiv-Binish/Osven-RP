new Vue({
    el: '#app',
    data: {
        visible: false,
        view: 'menu',
        married: false,
        spouseName: '',
        targetId: '',
        proposalFrom: '',
        proposalRing: '',
        proposalData: null,
    },
    methods: {
        propose: function () {
            if (!this.targetId) return;
            fetch('https://osven-relationships/marriage:propose', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ target: this.targetId }),
            });
            this.targetId = '';
            this.close();
        },
        accept: function () {
            fetch('https://osven-relationships/marriage:acceptProposal', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
            });
            this.close();
        },
        decline: function () {
            fetch('https://osven-relationships/marriage:declineProposal', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
            });
            this.close();
        },
        divorce: function () {
            if (!confirm('File for divorce? This costs $10,000.')) return;
            fetch('https://osven-relationships/marriage:divorce', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
            });
            this.close();
        },
        close: function () {
            this.visible = false;
            fetch('https://osven-relationships/marriage:close', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
            });
        },
    },
    mounted: function () {
        var self = this;
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || !data.type) return;

            if (data.type === 'OPEN_MARRIAGE') {
                self.married = data.data.married;
                self.spouseName = data.data.spouseName || '';
                self.view = 'menu';
                self.visible = true;
            } else if (data.type === 'OPEN_PROPOSAL') {
                self.proposalFrom = data.data.fromName;
                self.proposalRing = data.data.ring;
                self.proposalData = data.data;
                self.view = 'proposal';
                self.visible = true;
            } else if (data.type === 'CLOSE_MARRIAGE') {
                self.visible = false;
            }
        });
    },
});
