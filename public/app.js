(function() {
    let loading = Vue.component('vue-loading', {
        props: {
            loading: {
                type: Boolean,
                required: false,
                default: false
            }
        },
        template: `<div v-if="loading" class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>`
    })
    
    let input = Vue.component('vue-input-area', {
        data: function() {
            return {
                userInput: ''
            }
        },
        props: {
            defaultMessage: {
                type: String
            }
        },
        methods: {
            sendMessage: function() {
                if (this.userInput === "") {
                    return
                }
                this.$emit('sent', this.userInput)
                this.userInput = ''
            },
            validateEnterPress: function(ev) {
                if (ev.keyCode === 13) {
                    this.userInput = this.userInput.trim()
                    this.sendMessage()
                }
            }
        },
        template: `
            <div class="d-flex">
                <textarea 
                    class="form-control no-resize input-shape" 
                    rows="3"
                    v-on:keyup="validateEnterPress"
                    v-model="userInput"></textarea>
                <button class="btn button-background text-white button-shape" v-on:click="sendMessage">Send</button>
            </div>`,
    })

    let frame = Vue.component('vue-frame', {
        template: `
        <div class="bg-light rounded border border-secondary shadow h-100"><slot></slot></div>`,
    })

    let bubble = Vue.component('vue-dialog-bubble', {
        props: {
            fromBot: {
                type: Boolean,
                required: false
            }
        },
        computed: {
            bindClass: function() {
                return {
                    'align-right': !this.fromBot,
                    'speech-bubble-right': !this.fromBot,
                    'speech-bubble-left': this.fromBot
                }
            }
        },
        template: `
        <div class="shadow p-2 text-white" 
            v-bind:class="bindClass">
                <slot></slot>
        </div>`,
    })

    let card = Vue.component('vue-card', {
        props: {
            image: {
                type: String,
                required: false
            },
            title: {
                type: String,
                required: false
            },
            description: {
                type: String,
                required: false
            },
            link: {
                type: String,
                required: true
            }
        },
        template: `
        <a :href="link" target="_blank" class="card">
            <img :src="image" class="card-img-top" alt="...">
            <div class="card-body text-dark p-1">
                <p class="card-title mb-1">{{ title }}</p>
                <p class="text-muted mb-0">{{ description }}</p>
            </div>
        </a>`
    })

    let list = Vue.component('vue-list', {
        props: {
            items: {
                type: Array,
                required: true
            },
            link: {
                type: String,
                required: false
            }
        },
        template: `
        <div>
            <div v-for="(item, index) in items" :key="index">
                <p class="mb-1"><strong>{{ item.signature }}</strong></p>
                <p>{{ item.description }}</p>
                <hr/>
            </div>
        <div>`
    })

    let app = new Vue({
        el: '#app',
        component: [frame, input, loading, card, bubble, list],
        data: {
            messages: [],
            loading: false,
            requestOptions: { timeout: 2 * 1000 },
            defaultMessage: "Sorry, could not get that. Please repeat."
        },
        methods: {
            sendMessage: async function(ev) {
                this.storeMessage({
                    message: ev, 
                    fromBot: false,
                    type: 'message',
                })

                this.toggleLoading()

                try {
                    let response = await axios.post('/message', {
                        message: ev
                    }, this.requestOptions)

                    if (response.status === 200) {
                        this.playNotification()
                        this.storeMessage({
                            message: response.data.message, 
                            fromBot: true,
                            type: response.data.type,
                            image: response.data.image,
                            title: response.data.title,
                            description: response.data.description,
                            link: response.data.link,
                            list: response.data.list
                        })
                    }
                } catch(error) {
                    console.error(error)
                    this.playNotification()
                    this.storeMessage({
                        message: this.defaultMessage, 
                        fromBot: true,
                        type: 'message',
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
                let audio = new Audio('https://raw.githubusercontent.com/danielstern/ngAudio/master/app/audio/button-3.mp3');
                audio.play();
            },
            storeMessage: function({ message, fromBot, type, image, title, description, link, list }) {
                this.messages.push({ message, fromBot, type, image, title, description, link, list})
            }
        },
        template: `
        <vue-frame>
            <div>
                <div class="p-3 top-pannel scroll">

                    <vue-dialog-bubble  
                        :from-bot="msg.fromBot"
                        class="mb-3"
                        :key="index"
                        v-for="(msg, index) in messages">
                            <div v-text="msg.message"></div>
                            <vue-card 
                                v-if="msg.type === 'card'"
                                :image="msg.image"
                                :title="msg.title"
                                :description="msg.description"
                                :link="msg.link" />

                            <vue-list v-if="msg.type === 'list'" :items="msg.list" :link="msg.link" />
                    </vue-dialog-bubble>

                    <div class="mb-5" ref="loading">
                        <vue-loading :loading="loading" />
                    </div>
                </div>
                <div class="p-3 bottom-pannel w-100">
                    <vue-input-area v-on:sent="sendMessage" />
                </div>
            </div>
        </vue-frame>`
    })
})()