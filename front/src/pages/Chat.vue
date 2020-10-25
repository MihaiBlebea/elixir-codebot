<template>
    <vue-frame>
        <div class="p-3 top-pannel scroll">

            <vue-dialog-bubble  
                :from-bot="msg.fromBot"
                class="mb-3"
                :key="index"
                v-for="(msg, index) in messages">
                    <div v-text="msg.text"></div>
            </vue-dialog-bubble>

            <div class="mb-5" ref="loading">
                <vue-loading :loading="loading" />
            </div>
        </div>
        <div class="p-3 bottom-pannel w-100">
            <vue-input-area v-on:sent="sendMessage" />
        </div>
    </vue-frame>
</template>

<script>
import Frame from './../components/Frame'
import DialogBubble from './../components/DialogBubble'
import InputArea from './../components/InputArea'
import Loading from './../components/Loading'
import axios from 'axios'

export default {
    name: 'vue-chat',
    components: {
        'vue-frame': Frame,
        'vue-dialog-bubble': DialogBubble,
        'vue-input-area': InputArea,
        'vue-loading': Loading
    },
    data: function() {
        return {
            messages: [],
            loading: false,
            requestOptions: { timeout: 2 * 1000 },
            defaultMessage: "Sorry, could not get that. Please repeat."
        }
    },
    methods: {
        sendMessage: async function(ev) {
            this.storeMessage({
                text: ev,
            })

            this.toggleLoading()

            try {
                let response = await axios.post('http://localhost:3000/message', {
                    message: ev
                }, this.requestOptions)

                if (response.status === 200) {
                    this.playNotification()
                    for (let i = 0; i < response.data.messages.length; i++) {
                        let msg = response.data.messages[i]
                        this.playNotification()
                        msg.fromBot = true
                        this.storeMessage(msg)
                        if (i < response.data.messages.length - 1) {
                            await this.sleep(500)
                        }
                    }
                }
            } catch(error) {
                console.error(error)
                this.playNotification()
                this.storeMessage({
                    text: this.defaultMessage,
                })
            } finally {
                this.scrollToBottom()
                this.toggleLoading()
            }
        },
        scrollToBottom: function() {
            setTimeout(()=> {
                let el = this.$refs['loading']
                el.scrollIntoView()
            }, 300)
        },
        toggleLoading: function() {
            this.loading = !this.loading
        },
        playNotification: function() {
            let audio = new Audio('https://raw.githubusercontent.com/MihaiBlebea/elixir-codebot/master/front/src/assets/audio.mp3');
            audio.play();
        },
        storeMessage: function({ text, created, fromBot }) {
            if (fromBot === undefined) {
                fromBot = false
            }
            this.messages.push({ text: text, fromBot, time: created})
        },
        sleep: function(ms) {
            return new Promise(resolve => setTimeout(resolve, ms))
        }
    }
}
</script>

<style scoped>
.scroll {
    overflow: scroll;
}
</style>