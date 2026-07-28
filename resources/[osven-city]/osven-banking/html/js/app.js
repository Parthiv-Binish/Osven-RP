new Vue({
    el: '#app',
    data: {
        visible: false,
        mode: 'branch',
        cash: 0,
        bank: 0,
        transactions: [],
        activeTab: 'transfer',
        tabs: [
            { id: 'transfer', label: 'Transfer' },
            { id: 'statement', label: 'Statement' },
            { id: 'loans', label: 'Loans' },
        ],
        transfer: {
            recipient: '',
            amount: 0,
            note: '',
            lookupName: '',
            lookupError: '',
            pending: false,
            result: '',
            resultType: '',
        },
        atmAmount: 0,
        atmResult: '',
        atmResultType: '',
    },
    computed: {
        canTransfer: function () {
            return this.transfer.recipient.trim() !== '' &&
                   this.transfer.amount > 0 &&
                   this.transfer.amount <= this.bank &&
                   this.transfer.lookupName !== '';
        },
    },
    methods: {
        formatMoney: function (n) {
            return Number(n).toLocaleString('en-US');
        },
        lookupRecipient: function () {
            var val = this.transfer.recipient.trim();
            if (val.length < 3) {
                this.transfer.lookupName = '';
                this.transfer.lookupError = '';
                return;
            }
            var self = this;
            fetch('https://' + (window.location.hostname || 'osven-banking') + '/bank:lookup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ query: val })
            }).then(function (r) { return r.json(); }).then(function (res) {
                if (res.name) {
                    self.transfer.lookupName = res.name;
                    self.transfer.lookupError = '';
                } else {
                    self.transfer.lookupName = '';
                    self.transfer.lookupError = 'No user found';
                }
            }).catch(function () {
                self.transfer.lookupError = 'Lookup failed';
            });
        },
        doTransfer: function () {
            if (!this.canTransfer) return;
            var self = this;
            this.transfer.pending = true;
            this.transfer.result = '';
            fetch('https://' + (window.location.hostname || 'osven-banking') + '/bank:transfer', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    recipient: this.transfer.recipient,
                    amount: this.transfer.amount,
                    note: this.transfer.note,
                })
            }).then(function (r) { return r.json(); }).then(function (res) {
                self.transfer.pending = false;
                if (res.success) {
                    self.transfer.result = 'Transfer successful';
                    self.transfer.resultType = 'is-success';
                    self.bank = res.newBalance;
                    self.transfer.amount = 0;
                    self.transfer.note = '';
                    setTimeout(function () { self.transfer.result = ''; }, 3000);
                } else {
                    self.transfer.result = res.error || 'Transfer failed';
                    self.transfer.resultType = 'is-error';
                }
            }).catch(function () {
                self.transfer.pending = false;
                self.transfer.result = 'Connection error';
                self.transfer.resultType = 'is-error';
            });
        },
        atmWithdraw: function () {
            if (this.atmAmount <= 0 || this.atmAmount > this.bank) return;
            var self = this;
            fetch('https://' + (window.location.hostname || 'osven-banking') + '/bank:atm', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'withdraw', amount: this.atmAmount })
            }).then(function (r) { return r.json(); }).then(function (res) {
                if (res.success) {
                    self.cash = res.newCash;
                    self.bank = res.newBank;
                    self.atmResult = 'Withdrawn $' + self.formatMoney(self.atmAmount);
                    self.atmResultType = 'is-success';
                    self.atmAmount = 0;
                    setTimeout(function () { self.atmResult = ''; }, 3000);
                } else {
                    self.atmResult = res.error || 'Withdrawal failed';
                    self.atmResultType = 'is-error';
                }
            });
        },
        atmDeposit: function () {
            if (this.atmAmount <= 0 || this.atmAmount > this.cash) return;
            var self = this;
            fetch('https://' + (window.location.hostname || 'osven-banking') + '/bank:atm', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'deposit', amount: this.atmAmount })
            }).then(function (r) { return r.json(); }).then(function (res) {
                if (res.success) {
                    self.cash = res.newCash;
                    self.bank = res.newBank;
                    self.atmResult = 'Deposited $' + self.formatMoney(self.atmAmount);
                    self.atmResultType = 'is-success';
                    self.atmAmount = 0;
                    setTimeout(function () { self.atmResult = ''; }, 3000);
                } else {
                    self.atmResult = res.error || 'Deposit failed';
                    self.atmResultType = 'is-error';
                }
            });
        },
        close: function () {
            this.visible = false;
            SetNuiFocus(false, false);
            fetch('https://' + (window.location.hostname || 'osven-banking') + '/bank:close', {
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
            if (data.type === 'OPEN_BANKING') {
                self.mode = data.mode || 'branch';
                self.cash = data.cash || 0;
                self.bank = data.bank || 0;
                self.transactions = data.transactions || [];
                self.activeTab = 'transfer';
                self.transfer.recipient = '';
                self.transfer.amount = 0;
                self.transfer.note = '';
                self.transfer.lookupName = '';
                self.transfer.lookupError = '';
                self.transfer.result = '';
                self.atmAmount = 0;
                self.atmResult = '';
                self.visible = true;
            }
        });
    },
});
