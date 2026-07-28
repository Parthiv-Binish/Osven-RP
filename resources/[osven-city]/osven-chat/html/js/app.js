var msgId = 0;

new Vue({
    el: '#app',
    data: {
        messages: [],
        visibleMessages: [],
        inputActive: false,
        inputText: '',
        historyVisible: false,
        historyFilter: '',
        timeoutIds: {},
    },
    computed: {
        filteredHistory: function () {
            var self = this;
            var filter = this.historyFilter.toLowerCase();
            if (!filter) return this.messages.slice().reverse();
            return this.messages.filter(function (m) {
                return m.message.toLowerCase().includes(filter) ||
                       m.sender.toLowerCase().includes(filter) ||
                       m.label.toLowerCase().includes(filter);
            }).reverse();
        }
    },
    methods: {
        addMessage: function (msg) {
            msg.id = ++msgId;
            msg.hovered = false;
            this.messages.push(msg);
            this.visibleMessages.push(msg);

            if (this.timeoutIds[msg.id]) clearTimeout(this.timeoutIds[msg.id]);
            this.timeoutIds[msg.id] = setTimeout(function () {
                this.removeMessage(msg);
            }.bind(this), 8000);

            if (this.messages.length > 200) {
                var old = this.messages.shift();
                this.removeMessage(old);
            }
        },
        removeMessage: function (msg) {
            var idx = this.visibleMessages.indexOf(msg);
            if (idx !== -1) this.visibleMessages.splice(idx, 1);
            delete this.timeoutIds[msg.id];
        },
        sendMessage: function () {
            var text = this.inputText.trim();
            if (text === '') { this.closeInput(); return; }

            var channel = 'local';
            if (text.startsWith('/me ')) { channel = 'me'; text = text.substring(4); }
            else if (text.startsWith('/do ')) { channel = 'do'; text = text.substring(4); }
            else if (text.startsWith('/ooc ')) { channel = 'ooc'; text = text.substring(5); }
            else if (text.startsWith('/pd ')) { channel = 'pd'; text = text.substring(4); }
            else if (text.startsWith('/ems ')) { channel = 'ems'; text = text.substring(5); }
            else if (text.startsWith('/g ')) { channel = 'gang'; text = text.substring(3); }
            else if (text.startsWith('/ad ')) { channel = 'ad'; text = text.substring(4); }
            else if (text.startsWith('/a ')) { channel = 'admin'; text = text.substring(3); }

            if (text !== '') {
                fetch('https://' + (window.location.hostname || 'osven-chat') + '/chat:send', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ channel: channel, message: text })
                });
            }
            this.closeInput();
        },
        openInput: function () {
            this.inputActive = true;
            this.inputText = '';
            this.historyVisible = false;
            this.$nextTick(function () {
                if (this.$refs.chatInput) this.$refs.chatInput.focus();
            }.bind(this));
        },
        closeInput: function () {
            this.inputActive = false;
            this.inputText = '';
            fetch('https://' + (window.location.hostname || 'osven-chat') + '/chat:focus', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ state: false })
            });
        },
        openHistory: function () {
            this.historyVisible = !this.historyVisible;
            this.historyFilter = '';
        },
        closeHistory: function () {
            this.historyVisible = false;
            this.historyFilter = '';
        },
        toggleHistory: function () {
            this.historyVisible = !this.historyVisible;
            if (!this.historyVisible) this.historyFilter = '';
        }
    },
    mounted: function () {
        window.addEventListener('message', function (event) {
            var data = event.data;
            if (!data || !data.type) return;

            switch (data.type) {
                case 'CHAT_MESSAGE':
                    this.addMessage(data.data);
                    break;
                case 'CHAT_OPEN':
                    this.openInput();
                    break;
                case 'CHAT_CLOSE':
                    this.closeInput();
                    this.historyVisible = false;
                    break;
                case 'TOGGLE_HISTORY':
                    this.toggleHistory();
                    break;
                case 'CLEAR_CHAT':
                    this.messages = [];
                    this.visibleMessages = [];
                    break;
            }
        }.bind(this));
    }
});
