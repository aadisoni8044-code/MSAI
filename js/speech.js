/**
 * Web Speech API Text-to-Speech (TTS) Module for MSAI
 * Pure Vanilla JS using native window.speechSynthesis & SpeechSynthesisUtterance
 */

class MSAISpeechManager {
  constructor() {
    this.synth = typeof window !== 'undefined' && 'speechSynthesis' in window ? window.speechSynthesis : null;
    this.currentMessageId = null;
    this.currentUtterance = null;
    this.activeButton = null;
    this.voices = [];

    if (this.synth) {
      this.loadVoices();
      if (this.synth.onvoiceschanged !== undefined) {
        this.synth.onvoiceschanged = () => this.loadVoices();
      }
    }
  }

  isSupported() {
    return !!this.synth && typeof SpeechSynthesisUtterance !== 'undefined';
  }

  loadVoices() {
    if (!this.synth) return;
    this.voices = this.synth.getVoices();
  }

  /**
   * Cleans HTML markup, UI elements, and code block copy/language labels from message text
   */
  extractCleanText(containerOrText) {
    if (typeof containerOrText === 'string') {
      return containerOrText.replace(/<[^>]*>/g, '').trim();
    }

    if (!containerOrText) return '';

    // Clone element to sanitize without affecting DOM
    const clone = containerOrText.cloneNode(true);

    // Remove code block copy buttons, header labels, timestamps, etc.
    const toRemove = clone.querySelectorAll('.code-block-header, .code-block-copy-btn, .message-actions, .message-avatar, button, svg');
    toRemove.forEach(el => el.remove());

    let text = clone.innerText || clone.textContent || '';

    // Normalize spaces and line breaks
    text = text.replace(/\n+/g, ' ').replace(/\s+/g, ' ').trim();
    return text;
  }

  /**
   * Detect language or select the best available voice (Hindi, English, Gujarati, Marathi)
   */
  getBestVoiceForText(text) {
    if (!this.voices || this.voices.length === 0) {
      this.loadVoices();
    }

    // Check Devanagari script range for Hindi/Marathi
    const hasDevanagari = /[\u0900-\u097F]/.test(text);
    // Check Gujarati script range
    const hasGujarati = /[\u0A80-\u0AFF]/.test(text);

    let targetLangPrefix = 'en';
    if (hasGujarati) {
      targetLangPrefix = 'gu';
    } else if (hasDevanagari) {
      targetLangPrefix = 'hi';
    }

    // Attempt exact match first
    let matchingVoice = this.voices.find(v => v.lang.toLowerCase().startsWith(targetLangPrefix));

    if (!matchingVoice && targetLangPrefix === 'hi') {
      // Fallback for Marathi if 'mr' exists or stay with 'hi'
      matchingVoice = this.voices.find(v => v.lang.toLowerCase().startsWith('mr'));
    }

    if (!matchingVoice) {
      // Fallback to English or default voice
      matchingVoice = this.voices.find(v => v.lang.toLowerCase().startsWith('en')) || this.voices[0];
    }

    return { voice: matchingVoice, lang: targetLangPrefix };
  }

  /**
   * Main method to toggle or speak a specific message
   */
  speakMessage(messageId, textContent, buttonElement, onStateChange) {
    if (!this.isSupported()) {
      console.warn('Web Speech API is not supported in this browser.');
      return false;
    }

    // If currently speaking this exact message, stop it
    if (this.currentMessageId === messageId && this.synth.speaking) {
      this.stop();
      if (onStateChange) onStateChange(false);
      return false;
    }

    // Stop any previous speech before starting a new message
    this.stop();

    const cleanText = this.extractCleanText(textContent);
    if (!cleanText) return false;

    const utterance = new SpeechSynthesisUtterance(cleanText);
    const { voice, lang } = this.getBestVoiceForText(cleanText);

    if (voice) {
      utterance.voice = voice;
    }
    utterance.lang = lang === 'hi' ? 'hi-IN' : (lang === 'gu' ? 'gu-IN' : 'en-US');
    utterance.rate = 1.0;
    utterance.pitch = 1.0;

    this.currentMessageId = messageId;
    this.currentUtterance = utterance;
    this.activeButton = buttonElement;

    utterance.onstart = () => {
      if (onStateChange) onStateChange(true);
      if (buttonElement) {
        buttonElement.classList.add('speaking-active');
        buttonElement.setAttribute('title', 'Stop speaking');
      }
    };

    utterance.onend = () => {
      this.resetCurrentState(onStateChange);
    };

    utterance.onerror = (err) => {
      console.error('Speech synthesis error:', err);
      this.resetCurrentState(onStateChange);
    };

    this.synth.speak(utterance);
    return true;
  }

  stop() {
    if (this.synth) {
      this.synth.cancel();
    }
    if (this.activeButton) {
      this.activeButton.classList.remove('speaking-active');
      this.activeButton.setAttribute('title', 'Speaking');
    }
    this.currentMessageId = null;
    this.currentUtterance = null;
    this.activeButton = null;
  }

  resetCurrentState(onStateChange) {
    if (this.activeButton) {
      this.activeButton.classList.remove('speaking-active');
      this.activeButton.setAttribute('title', 'Speaking');
    }
    this.currentMessageId = null;
    this.currentUtterance = null;
    this.activeButton = null;
    if (onStateChange) onStateChange(false);
  }
}

export const msaiSpeech = new MSAISpeechManager();
