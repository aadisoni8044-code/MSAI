/**
 * MSAI - Voice Input & Speech Synthesis Module
 */

import { toast } from "./toast.js";
import { storage } from "./storage.js";

class VoiceService {
  constructor() {
    this.recognition = null;
    this.isListening = false;
    this.synth = typeof window !== "undefined" ? window.speechSynthesis : null;
    this.currentUtterance = null;
    this.currentlySpeakingMsgId = null;
    this.initRecognition();
  }

  initRecognition() {
    if (typeof window === "undefined") return;

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      console.warn("Speech Recognition API is not supported in this browser.");
      return;
    }

    try {
      this.recognition = new SpeechRecognition();
      this.recognition.continuous = true;
      this.recognition.interimResults = true;
      this.recognition.lang = "en-US";

      this.recognition.onstart = () => {
        this.isListening = true;
        this.updateMicUI(true);
        toast.info("Listening... Speak into your microphone.", 2000);
      };

      this.recognition.onerror = (event) => {
        console.error("Speech recognition error:", event.error);
        this.isListening = false;
        this.updateMicUI(false);
        if (event.error === "not-allowed") {
          toast.error("Microphone access denied. Please allow microphone permissions in your browser.");
        } else if (event.error !== "no-speech") {
          toast.warning(`Speech recognition: ${event.error}`);
        }
      };

      this.recognition.onend = () => {
        this.isListening = false;
        this.updateMicUI(false);
      };
    } catch (e) {
      console.warn("Speech recognition initialization failed:", e);
    }
  }

  isSupported() {
    return Boolean(this.recognition);
  }

  toggleListening(onTranscriptCallback) {
    if (!this.recognition) {
      toast.warning("Voice recognition is not supported in your browser.");
      return;
    }

    if (this.isListening) {
      this.stopListening();
    } else {
      this.startListening(onTranscriptCallback);
    }
  }

  startListening(onTranscriptCallback) {
    if (!this.recognition || this.isListening) return;

    this.recognition.onresult = (event) => {
      let interimTranscript = "";
      let finalTranscript = "";

      for (let i = event.resultIndex; i < event.results.length; ++i) {
        if (event.results[i].isFinal) {
          finalTranscript += event.results[i][0].transcript;
        } else {
          interimTranscript += event.results[i][0].transcript;
        }
      }

      const text = finalTranscript || interimTranscript;
      if (onTranscriptCallback && text) {
        onTranscriptCallback(text, Boolean(finalTranscript));
      }
    };

    try {
      this.recognition.start();
    } catch (e) {
      console.error("Failed to start speech recognition:", e);
    }
  }

  stopListening() {
    if (this.recognition && this.isListening) {
      try {
        this.recognition.stop();
      } catch (e) {
        console.warn("Error stopping recognition:", e);
      }
      this.isListening = false;
      this.updateMicUI(false);
    }
  }

  updateMicUI(active) {
    const micButtons = document.querySelectorAll(".composer-mic-btn");
    micButtons.forEach((btn) => {
      if (active) {
        btn.classList.add("listening", "animate-pulse");
        btn.setAttribute("title", "Stop listening");
      } else {
        btn.classList.remove("listening", "animate-pulse");
        btn.setAttribute("title", "Voice Input (Microphone)");
      }
    });
  }

  // --- Text-to-Speech (Read Aloud) ---

  speak(text, messageId = null, onEndCallback = null) {
    if (!this.synth) {
      toast.warning("Speech synthesis not supported in this browser.");
      return;
    }

    // If currently speaking this message, toggle stop
    if (this.currentlySpeakingMsgId === messageId && this.synth.speaking) {
      this.stopSpeaking();
      return;
    }

    this.stopSpeaking();

    // Strip markdown formatting for cleaner speech
    const cleanText = text
      .replace(/```[\s\S]*?```/g, "Code block omitted.")
      .replace(/`([^`]+)`/g, "$1")
      .replace(/\[([^\]]+)\]\([^)]+\)/g, "$1")
      .replace(/[*_~#]/g, "")
      .trim();

    if (!cleanText) return;

    this.currentUtterance = new SpeechSynthesisUtterance(cleanText);
    const settings = storage.getSettings();
    this.currentUtterance.rate = settings.speechSpeed || 1.0;

    this.currentlySpeakingMsgId = messageId;
    this.updateSpeakingUI(messageId, true);

    this.currentUtterance.onend = () => {
      this.currentlySpeakingMsgId = null;
      this.updateSpeakingUI(messageId, false);
      if (onEndCallback) onEndCallback();
    };

    this.currentUtterance.onerror = (e) => {
      console.warn("TTS Error:", e);
      this.currentlySpeakingMsgId = null;
      this.updateSpeakingUI(messageId, false);
    };

    this.synth.speak(this.currentUtterance);
  }

  stopSpeaking() {
    if (this.synth && this.synth.speaking) {
      this.synth.cancel();
    }
    if (this.currentlySpeakingMsgId) {
      this.updateSpeakingUI(this.currentlySpeakingMsgId, false);
      this.currentlySpeakingMsgId = null;
    }
  }

  updateSpeakingUI(messageId, isSpeaking) {
    if (!messageId) return;
    const btn = document.querySelector(`[data-speak-btn="${messageId}"]`);
    if (btn) {
      if (isSpeaking) {
        btn.classList.add("speaking-active");
        btn.setAttribute("title", "Stop speaking");
      } else {
        btn.classList.remove("speaking-active");
        btn.setAttribute("title", "Read Aloud");
      }
    }
  }
}

export const voiceService = new VoiceService();
