new Vue({
    el: '#app',
    data: {
        showCircle: false,
        circleTotal: 1,
        circleCurrent: 1,
        circleTimer: 10,
        circleAngle: 0,
        circleTarget: 0,
        circleRunning: false,
        circleAnimFrame: null,

        showThermite: false,
        thermiteTimer: 10,
        thermiteGridSize: 6,
        thermiteCells: [],
        thermiteTargets: [],
        thermiteWrongLimit: 3,
        thermiteWrongCount: 0,
        thermiteStatus: '',
        thermiteInterval: null,
    },
    methods: {
        /* ===== CIRCLE ===== */
        startCircle: function (data) {
            this.showCircle = true;
            this.circleTotal = data.circles || 1;
            this.circleCurrent = 1;
            this.circleTimer = data.time || 10;
            this.circleAngle = 0;
            this.circleRunning = true;
            this.nextCircleRound();
        },
        nextCircleRound: function () {
            var canvas = this.$refs.circleCanvas;
            if (!canvas) return;
            var ctx = canvas.getContext('2d');
            var cx = 150, cy = 150, r = 120;

            // Target zone: random 60-degree arc
            this.circleTarget = Math.random() * 360;

            var startTime = Date.now();
            var duration = this.circleTimer * 1000;
            var speed = 4; // degrees per tick
            var self = this;

            function animate() {
                self.circleAngle = (self.circleAngle + speed) % 360;
                var elapsed = Date.now() - startTime;
                var remaining = Math.max(0, Math.ceil((duration - elapsed) / 1000));
                self.circleTimer = remaining;

                ctx.clearRect(0, 0, 300, 300);

                // Background circle
                ctx.beginPath();
                ctx.arc(cx, cy, r, 0, Math.PI * 2);
                ctx.strokeStyle = '#2a2f3a';
                ctx.lineWidth = 12;
                ctx.stroke();

                // Target zone (green arc)
                var targetStart = (self.circleTarget - 30) * Math.PI / 180;
                var targetEnd = (self.circleTarget + 30) * Math.PI / 180;
                ctx.beginPath();
                ctx.arc(cx, cy, r, targetStart, targetEnd);
                ctx.strokeStyle = '#2FB6A6';
                ctx.lineWidth = 14;
                ctx.stroke();

                // Moving dot
                var dotAngle = self.circleAngle * Math.PI / 180;
                var dx = cx + r * Math.cos(dotAngle);
                var dy = cy + r * Math.sin(dotAngle);
                ctx.beginPath();
                ctx.arc(dx, dy, 10, 0, Math.PI * 2);
                ctx.fillStyle = '#E8A33D';
                ctx.fill();
                ctx.strokeStyle = '#EDEFF2';
                ctx.lineWidth = 2;
                ctx.stroke();

                // Center dot
                ctx.beginPath();
                ctx.arc(cx, cy, 4, 0, Math.PI * 2);
                ctx.fillStyle = '#8B93A1';
                ctx.fill();

                if (elapsed < duration && self.circleRunning) {
                    self.circleAnimFrame = requestAnimationFrame(animate);
                } else if (elapsed >= duration) {
                    self.circleFail();
                }
            }

            animate();
        },
        circleSuccess: function () {
            if (this.circleCurrent >= this.circleTotal) {
                this.showCircle = false;
                this.circleRunning = false;
                if (this.circleAnimFrame) cancelAnimationFrame(this.circleAnimFrame);
                fetch('https://osven-ui/circle-success', { method: 'POST', headers: { 'Content-Type': 'application/json' } });
            } else {
                this.circleCurrent++;
                this.circleTimer = this.circleTimer;
                this.nextCircleRound();
            }
        },
        circleFail: function () {
            this.showCircle = false;
            this.circleRunning = false;
            if (this.circleAnimFrame) cancelAnimationFrame(this.circleAnimFrame);
            fetch('https://osven-ui/circle-fail', { method: 'POST', headers: { 'Content-Type': 'application/json' } });
        },
        onCircleClick: function () {
            if (!this.circleRunning) return;
            var angle = this.circleAngle;
            var target = this.circleTarget;
            var diff = Math.abs(angle - target);
            var wrapped = Math.min(diff, 360 - diff);
            if (wrapped <= 30) {
                this.circleSuccess();
            } else {
                this.circleFail();
            }
        },

        /* ===== THERMITE ===== */
        startThermite: function (data) {
            this.showThermite = true;
            this.thermiteGridSize = data.gridsize || 6;
            this.thermiteTimer = data.time || 10;
            this.thermiteWrongLimit = data.wrong || 3;
            this.thermiteWrongCount = 0;
            this.thermiteStatus = 'Click the highlighted cells';
            this.thermiteTargets = [];

            // Build grid
            var total = this.thermiteGridSize * this.thermiteGridSize;
            this.thermiteCells = [];
            for (var i = 0; i < total; i++) {
                this.thermiteCells.push({ highlighted: false, state: 'idle' });
            }

            // Pick random targets (5-8 cells)
            var targetCount = Math.min(Math.floor(Math.random() * 4) + 5, total);
            var targets = [];
            while (targets.length < targetCount) {
                var idx = Math.floor(Math.random() * total);
                if (targets.indexOf(idx) === -1) targets.push(idx);
            }
            this.thermiteTargets = targets;

            // Highlight targets for 2 seconds
            var self = this;
            targets.forEach(function (idx) { self.thermiteCells[idx].highlighted = true; });

            setTimeout(function () {
                // Hide highlights
                self.thermiteCells.forEach(function (c) { c.highlighted = false; });
                self.thermiteStatus = 'Remember the pattern! Click correct cells.';
                // Force reactivity
                self.thermiteCells = self.thermiteCells.slice();

                // Start timer
                var startTime = Date.now();
                var duration = self.thermiteTimer * 1000;
                self.thermiteInterval = setInterval(function () {
                    var elapsed = Date.now() - startTime;
                    var remaining = Math.max(0, Math.ceil((duration - elapsed) / 1000));
                    self.thermiteTimer = remaining;
                    if (remaining <= 0) {
                        self.thermiteEnd(false);
                    }
                }, 200);
            }, 2000);
        },
        thermiteClick: function (idx) {
            if (this.thermiteCells[idx].state !== 'idle' || !this.thermiteInterval) return;

            var isTarget = this.thermiteTargets.indexOf(idx) !== -1;
            if (isTarget) {
                this.thermiteCells[idx].state = 'correct';
                this.thermiteCells = this.thermiteCells.slice();
                // Check if all found
                var found = this.thermiteCells.filter(function (c) { return c.state === 'correct'; }).length;
                if (found >= this.thermiteTargets.length) {
                    this.thermiteEnd(true);
                }
            } else {
                this.thermiteCells[idx].state = 'wrong';
                this.thermiteWrongCount++;
                this.thermiteStatus = 'Wrong! ' + this.thermiteWrongCount + '/' + this.thermiteWrongLimit;
                this.thermiteCells = this.thermiteCells.slice();
                if (this.thermiteWrongCount >= this.thermiteWrongLimit) {
                    this.thermiteEnd(false);
                }
            }
        },
        thermiteEnd: function (success) {
            if (this.thermiteInterval) { clearInterval(this.thermiteInterval); this.thermiteInterval = null; }
            this.showThermite = false;
            fetch('https://osven-ui/thermite-callback', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ success: success }),
            });
        },
    },
    mounted: function () {
        var self = this;
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || !data.action) return;

            if (data.action === 'circle-start') {
                self.startCircle(data);
            } else if (data.action === 'thermite-start') {
                self.startThermite(data);
            }
        });

        // Click handler for circle
        document.addEventListener('click', function (e) {
            if (self.showCircle) self.onCircleClick();
        });
    },
});
