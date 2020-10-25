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
            this.history.push(this.userInput)
            this.index = this.history.length - 1
            this.$emit('sent', this.userInput)
            this.userInput = ''
        },
        validateEnterPress: function(ev) {
            if (ev.keyCode === 13) {
                this.userInput = this.userInput.trim()
                this.sendMessage()
            }

            // Key up
            if (ev.keyCode === 38 && this.history.length > 0) {
                this.index--
                if (this.index < 0) {
                    this.index = this.history.length - 1
                }
                this.userInput = this.history[this.index]
            }

            // Key down
            if (ev.keyCode === 40) {
                // this.userInput = this.userInput.trim()
                this.sendMessage()
            }
        }
    }
}
</script>