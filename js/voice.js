/**
 * Voice Input Handler Module using Web Speech API
 */

export class VoiceManager {
    constructor() {
        this.recognition = null;
        this.isListening = false;
        this.onResultCallback = null;
        this.onStateChangeCallback = null;

        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (SpeechRecognition) {
            this.recognition = new SpeechRecognition();
            this.recognition.continuous = false;
            this.recognition.interimResults = true;
            this.recognition.lang = 'en-US';

            this.recognition.onresult = (event) => {
                let transcript = '';
                for (let i = event.resultIndex; i < event.results.length; i++) {
                    transcript += event.results[i][0].transcript;
                }
                if (this.onResultCallback) {
                    this.onResultCallback(transcript);
                }
            };

            this.recognition.onend = () => {
                this.isListening = false;
                if (this.onStateChangeCallback) {
                    this.onStateChangeCallback(false);
                }
            };

            this.recognition.onerror = (event) => {
                console.warn("Speech recognition error:", event.error);
                this.isListening = false;
                if (this.onStateChangeCallback) {
                    this.onStateChangeCallback(false, event.error);
                }
            };
        }
    }

    isSupported() {
        return !!this.recognition;
    }

    start(onResult, onStateChange) {
        if (!this.isSupported()) {
            alert("Speech recognition is not supported in this browser.");
            return;
        }

        this.onResultCallback = onResult;
        this.onStateChangeCallback = onStateChange;

        if (this.isListening) {
            this.stop();
        } else {
            try {
                this.recognition.start();
                this.isListening = true;
                if (this.onStateChangeCallback) {
                    this.onStateChangeCallback(true);
                }
            } catch (err) {
                console.error("Failed to start voice recognition:", err);
            }
        }
    }

    stop() {
        if (this.recognition && this.isListening) {
            this.recognition.stop();
            this.isListening = false;
            if (this.onStateChangeCallback) {
                this.onStateChangeCallback(false);
            }
        }
    }
}

export const voice = new VoiceManager();
