import { toast } from './toast.js';

/**
 * Web Speech API Voice Input Module
 */
export class VoiceInputManager {
    constructor() {
        this.recognition = null;
        this.isListening = false;
        this.onResultCallback = null;
        this.init();
    }

    init() {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (SpeechRecognition) {
            this.recognition = new SpeechRecognition();
            this.recognition.continuous = false;
            this.recognition.interimResults = false;
            this.recognition.lang = 'en-US';

            this.recognition.onresult = (event) => {
                const transcript = event.results[0][0].transcript;
                if (this.onResultCallback) {
                    this.onResultCallback(transcript);
                }
            };

            this.recognition.onerror = (event) => {
                console.error('Speech recognition error:', event.error);
                toast.show('Voice recognition error: ' + event.error, 'error');
                this.stop();
            };

            this.recognition.onend = () => {
                this.isListening = false;
            };
        }
    }

    start(onResult) {
        if (!this.recognition) {
            toast.show('Speech recognition is not supported in this browser.', 'warning');
            return;
        }

        this.onResultCallback = onResult;
        try {
            this.recognition.start();
            this.isListening = true;
            toast.show('Listening...', 'info');
        } catch (e) {
            this.stop();
        }
    }

    stop() {
        if (this.recognition && this.isListening) {
            this.recognition.stop();
            this.isListening = false;
        }
    }

    toggle(onResult) {
        if (this.isListening) {
            this.stop();
        } else {
            this.start(onResult);
        }
    }
}

export const voiceInput = new VoiceInputManager();
