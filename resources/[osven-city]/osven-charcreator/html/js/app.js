new Vue({
    el: '#app',
    data: {
        visible: false,
        currentStep: 0,
        steps: ['Identity', 'Appearance', 'Outfit'],
        form: {
            firstName: '',
            lastName: '',
            gender: 'male',
            dob: '',
            backstory: '',
            appearance: {},
            outfit: null,
        },
        errors: {},
        appearanceSections: [
            {
                id: 'heritage',
                label: 'Heritage',
                open: true,
                sliders: [
                    { id: 'heritage_father', label: 'Father', min: 0, max: 100 },
                    { id: 'heritage_mother', label: 'Mother', min: 0, max: 100 },
                    { id: 'heritage_skin', label: 'Skin Tone', min: 0, max: 100 },
                ],
            },
            {
                id: 'hair',
                label: 'Hair',
                open: false,
                sliders: [
                    { id: 'hair_style', label: 'Style', min: 0, max: 72 },
                    { id: 'hair_color', label: 'Color', min: 0, max: 63 },
                    { id: 'hair_highlight', label: 'Highlights', min: 0, max: 63 },
                ],
            },
            {
                id: 'facial',
                label: 'Facial Hair',
                open: false,
                sliders: [
                    { id: 'beard_style', label: 'Style', min: 0, max: 28 },
                    { id: 'beard_color', label: 'Color', min: 0, max: 63 },
                    { id: 'beard_opacity', label: 'Opacity', min: 0, max: 100 },
                ],
            },
            {
                id: 'makeup',
                label: 'Makeup',
                open: false,
                sliders: [
                    { id: 'makeup_style', label: 'Style', min: 0, max: 74 },
                    { id: 'makeup_color', label: 'Color', min: 0, max: 63 },
                    { id: 'makeup_opacity', label: 'Opacity', min: 0, max: 100 },
                ],
            },
        ],
        outfits: [
            { id: 'casual', label: 'Casual' },
            { id: 'business', label: 'Business' },
            { id: 'street', label: 'Street' },
            { id: 'sporty', label: 'Sporty' },
        ],
    },
    computed: {
        isStepValid: function () {
            if (this.currentStep === 0) {
                return this.form.firstName.trim() !== '' &&
                       this.form.lastName.trim() !== '' &&
                       this.form.gender !== '' &&
                       this.form.dob.trim() !== '';
            }
            if (this.currentStep === 1) {
                return true;
            }
            if (this.currentStep === 2) {
                return this.form.outfit !== null;
            }
            return false;
        },
    },
    methods: {
        nextStep: function () {
            if (!this.isStepValid) return;
            this.errors = {};
            if (this.currentStep < 2) this.currentStep++;
        },
        prevStep: function () {
            if (this.currentStep > 0) this.currentStep--;
            this.errors = {};
        },
        goToStep: function (idx) {
            if (idx < this.currentStep) {
                this.currentStep = idx;
            }
        },
        confirmCharacter: function () {
            if (!this.isStepValid) return;
            this.visible = false;
            fetch('https://' + (window.location.hostname || 'osven-charcreator') + '/char:confirm', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    firstName: this.form.firstName,
                    lastName: this.form.lastName,
                    gender: this.form.gender,
                    dob: this.form.dob,
                    backstory: this.form.backstory,
                    appearance: this.form.appearance,
                    outfit: this.form.outfit,
                }),
            });
        },
        validateStep: function () {
            this.errors = {};
            if (this.currentStep === 0) {
                if (!this.form.firstName.trim()) this.errors.firstName = true;
                if (!this.form.lastName.trim()) this.errors.lastName = true;
                if (!this.form.dob.trim()) this.errors.dob = true;
            }
        },
    },
    mounted: function () {
        var self = this;
        // Init appearance defaults
        this.appearanceSections.forEach(function (section) {
            section.sliders.forEach(function (slider) {
                self.$set(self.form.appearance, slider.id, 0);
            });
        });

        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || data.type !== 'OPEN_CHARACTER_CREATOR') return;

            self.form.firstName = '';
            self.form.lastName = '';
            self.form.gender = 'male';
            self.form.dob = '';
            self.form.backstory = '';
            self.form.outfit = null;
            self.appearanceSections.forEach(function (section) {
                section.sliders.forEach(function (slider) {
                    self.$set(self.form.appearance, slider.id, 0);
                });
            });
            self.currentStep = 0;
            self.errors = {};
            self.visible = true;
        });
    },
});
