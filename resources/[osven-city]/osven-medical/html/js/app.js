new Vue({
    el: '#app',
    data: {
        state: 'normal',  // normal | limping | critical | downed
        countdown: 0,
        countdownInterval: null,
    },
    computed: {
        statusText: function () {
            var map = {
                limping: 'INJURED — MOVE CAREFULLY',
                critical: 'CRITICAL — SEEK TREATMENT',
                downed: 'AWAITING RESCUE',
            };
            return map[this.state] || '';
        },
        formattedCountdown: function () {
            var m = Math.floor(this.countdown / 60);
            var s = this.countdown % 60;
            return String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
        },
    },
    methods: {
        startCountdown: function (seconds) {
            var self = this;
            if (this.countdownInterval) clearInterval(this.countdownInterval);
            this.countdown = seconds;
            this.countdownInterval = setInterval(function () {
                self.countdown--;
                if (self.countdown <= 0) {
                    clearInterval(self.countdownInterval);
                    self.countdownInterval = null;
                    self.countdown = 0;
                }
            }, 1000);
        },
        clearCountdown: function () {
            if (this.countdownInterval) {
                clearInterval(this.countdownInterval);
                this.countdownInterval = null;
            }
            this.countdown = 0;
        },
    },
    mounted: function () {
        var self = this;
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || !data.type) return;

            switch (data.type) {
                case 'SET_MEDICAL_STATE':
                    self.state = data.state || 'normal';
                    if (data.countdown) {
                        self.startCountdown(data.countdown);
                    } else {
                        self.clearCountdown();
                    }
                    break;
                case 'CLEAR_MEDICAL_STATE':
                    self.state = 'normal';
                    self.clearCountdown();
                    break;
            }
        });
    },
});
