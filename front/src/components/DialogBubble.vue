<template>
    <div class="shadow p-2 text-white" 
        v-bind:class="bindClass">
            <slot></slot>
    </div>
</template>

<script>
export default {
    name: 'vue-dialog-bubble',
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
    }
}
</script>

<style scoped>
/* Use this to edit https://projects.verou.me/bubbly/ */

.speech-bubble-right {
	position: relative;
	background: #00aabb;
	border-radius: .4em;
}

.speech-bubble-right:after {
	content: '';
	position: absolute;
	right: 0;
	top: 50%;
	width: 0;
	height: 0;
	border: 10px solid transparent;
	border-left-color: #00aabb;
	border-right: 0;
	margin-top: -10px;
	margin-right: -10px;
}

.speech-bubble-left {
	position: relative;
	background: #943295;
	border-radius: .4em;
}

.speech-bubble-left:after {
	content: '';
	position: absolute;
	left: 0;
	top: 50%;
	width: 0;
	height: 0;
	border: 10px solid transparent;
	border-right-color: #943295;
	border-left: 0;
	margin-top: -10px;
	margin-left: -10px;
}

.speech-bubble-left, .speech-bubble-right {
    width: 75%;
}

/* LESS THAN 75 */
@media (max-width: 74.9em) { 
    .speech-bubble-left, .speech-bubble-right {
        width: 75%;
    }
}

/* LESS THAN 62 */
@media (max-width: 61.9em) { 
    .speech-bubble-left, .speech-bubble-right {
        width: 75%;
    }
}

/* LESS THAN 48 */
@media (max-width: 47.9em) { 
    .speech-bubble-left, .speech-bubble-right {
        width: 75%;
    }
}

/* LESS THAN 34 */
@media (max-width: 33.9em) { 
    .speech-bubble-left, .speech-bubble-right {
        width: 100%;
    }
}
</style>