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
                this.userInput = this.userInput.trim()
                if (ev.keyCode === 13) {
                    this.sendMessage()
                }
            }
        },
        template: `
            <div class="d-flex">
                <textarea 
                    class="form-control no-resize" 
                    rows="3"
                    v-on:keyup="validateEnterPress"
                    v-model="userInput"></textarea>
                <button class="btn btn-primary" v-on:click="sendMessage">Send</button>
            </div>`,
    })

    let frame = Vue.component('vue-frame', {
        template: `
        <div class="bg-light rounded border border-secondary shadow h-100"><slot></slot></div>`,
    })

    let bubble = Vue.component('vue-dialog-bubble', {
        props: {
            message: {
                type: String,
                required: true,
                default: "bla bla"
            },
            fromBot: {
                type: Boolean,
                required: false
            }
        },
        computed: {
            bindClass: function() {
                return {
                    'align-right': !this.fromBot,
                    'bg-info': this.fromBot
                }
            }
        },
        template: `
        <div class="bg-secondary text-white rounded shadow w-75 p-2" 
            v-bind:class="bindClass">{{ message }}</div>`,
    })

    let app = new Vue({
        el: '#app',
        component: [frame, input, loading],
        data: {
            messages: [],
            loading: false
        },
        methods: {
            sendMessage: async function(ev) {
                this.messages.push({message: ev, fromBot: false})

                this.toggleLoading()
                let response = await axios.post('/message', {
                    message: ev
                })
                this.messages.push({message: response.data, fromBot: true})
                this.scrollToBottom()
                this.toggleLoading()
            },
            scrollToBottom: function() {
                setTimeout(()=> {
                    let el = this.$refs['loading']
                    el.scrollIntoView()
                }, 300)
            },
            toggleLoading: function() {
                this.loading = !this.loading
            }
        },
        template: `
        <vue-frame>
            <div>
                <div class="p-3 top-pannel scroll">
                    <vue-dialog-bubble 
                        :message="msg.message" 
                        :from-bot="msg.fromBot"
                        class="mb-3"
                        :key="index"
                        v-for="(msg, index) in messages"/>
                    <div class="mb-5" ref="loading">
                        <vue-loading :loading="loading" />
                    </div>
                </div>
                <div class="p-3 bottom-pannel w-100 bg-info">
                    <vue-input-area v-on:sent="sendMessage" />
                </div>
            </div>
        </vue-frame>`
    })
})()