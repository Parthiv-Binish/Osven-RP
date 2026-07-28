new Vue({
    el: '#app',
    data: {
        visible: false,
        remainingSeconds: 0,
        communityActive: false,
        progressPct: 0,
        timerInterval: null,
    },
    computed: {
        formattedTime: function () {
            var m = Math.floor(this.remainingSeconds / 60);
            var s = this.remainingSeconds % 60;
            return String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
        },
    },
    methods: {
        startCommunityService: function () {
            this.communityActive = true;
            fetch('https://' + (window.location.hostname || 'osven-jail') + '/jail:startCS', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
            });
        },
        startTimer: function (seconds) {
            var self = this;
            if (this.timerInterval) clearInterval(this.timerInterval);
            this.remainingSeconds = seconds;
            this.timerInterval = setInterval(function () {
                self.remainingSeconds--;
                if (self.remainingSeconds <= 0) {
                    clearInterval(self.timerInterval);
                    self.timerInterval = null;
                    self.visible = false;
                    self.communityActive = false;
                }
            }, 1000);
        },
    },
    mounted: function () {
        var self = this;
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || !data.type) return;

            if (data.type === 'START_SENTENCE') {
                self.visible = true;
                self.communityActive = false;
                self.progressPct = 0;
                self.startTimer(data.seconds || 0);
            } else if (data.type === 'RELEASED') {
                self.visible = false;
                self.communityActive = false;
                if (self.timerInterval) {
                    clearInterval(self.timerInterval);
                    self.timerInterval = null;
                }
            } else if (data.type === 'COMMUNITY_PROGRESS') {
                self.progressPct = data.percent || 0;
                if (data.secondsLeft !== undefined) {
                    self.remainingSeconds = data.secondsLeft;
                }
            }
        });
    },
});
