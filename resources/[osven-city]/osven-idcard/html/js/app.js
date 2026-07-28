new Vue({
    el: '#app',
    data: {
        visible: false,
        presented: false,
        name: '',
        dob: '',
        citizenId: '',
        job: '',
        driving: 'NONE',
        weapon: 'NONE',
        photo: '',
    },
    methods: {
        licenseClass: function (status) {
            if (status === 'VALID') return 'is-valid';
            if (status === 'SUSPENDED') return 'is-suspended';
            return 'is-none';
        },
        close: function () {
            this.visible = false;
            fetch('https://' + (window.location.hostname || 'osven-idcard') + '/id:close', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
            });
        },
    },
    mounted: function () {
        var self = this;
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || data.type !== 'SHOW_ID_CARD') return;

            self.name = data.name || '';
            self.dob = data.dob || '';
            self.citizenId = data.citizenId || '';
            self.job = data.job || 'Citizen';
            self.driving = data.driving || 'NONE';
            self.weapon = data.weapon || 'NONE';
            self.photo = data.photo || '';
            self.presented = data.presented || false;
            self.visible = true;
        });
    },
});
