<template>
    <div class="d-flex">
        <textarea 
            class="form-control no-resize input-shape" 
            rows="3"
            v-on:keyup="validateEnterPress"
            v-model="userInput"></textarea>
        <button class="btn button-background text-white button-shape" v-on:click="sendMessage">Send</button>
    </div>
</template>

<script>
export default {
    name: 'vue-input-area',
    data: function() {
        return {
            userInput: '',
            history: [],
            index: 0
        }
    },
    methods: {
        sendMessage: function() {
            if (this.userInput === "") {
                return
            }
            this.$emit('sent', this.userInput)
            this.addToHistory(this.userInput)
            this.userInput = ''
        },
        validateEnterPress: function(ev) {
            switch(ev.keyCode) {
                case 13:
                    this.handleKeyEnter()
                    break
                case 38:
                    this.handleKeyUp()
                    break
                case 40:
                    this.handleKeyDown()
                    break
                default:
                    break 
            }
        },
        handleKeyUp: function() {
            if (this.history.length === 0) {
                return
            }

            this.index--
            if (this.index < 0) {
                this.index = this.history.length - 1
            }
            this.userInput = this.history[this.index]
        },
        handleKeyDown: function() {
            if (this.history.length === 0) {
                return
            }

            this.index++
            if (this.index > this.history.length - 1) {
                this.index = 0
            }
            this.userInput = this.history[this.index]
        },
        handleKeyEnter: function() {
            this.userInput = this.userInput.trim()
            this.sendMessage()
        },
        addToHistory: function(message) {
            this.history.push(message)
            this.index = this.history.length - 1
        }
    }
}
</script>