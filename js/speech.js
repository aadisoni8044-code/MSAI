/**
 * Web Speech API Text-to-Speech (TTS) Module for MSAI
 * Pure Vanilla JS using native window.speechSynthesis & SpeechSynthesisUtterance
 */

class MSAISpeechManager {
  constructor() {
    this.synth = typeof window !== 'undefined' && 'speechSynthesis' in window ? window.speechSynthesis : null;
    this.currentMessageId = null;
    this.activeButton = null;
    this.voices = [];
    this.utteranceQueue = [];
    this.isSpeaking = false;
    this.onStateChangeCallback = null;

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
   * Detect language code for a text segment
   */
  detectLanguage(text) {
    if (!text) return 'en';

    // Devanagari script range (Hindi / Marathi)
    if (/[\u0900-\u097F]/.test(text)) {
      return 'hi';
    }
    // Bengali script range
    if (/[\u0980-\u09FF]/.test(text)) {
      return 'bn';
    }
    // Spanish characters check (ñ, á, é, í, ó, ú, ¿, ¡)
    if (/[ñáéíóú¿¡]/i.test(text)) {
      return 'es';
    }

    return 'en';
  }

  /**
   * Find actual SpeechSynthesisVoice matching the target language code
   */
  getBestVoiceForLang(langCode) {
    if (!this.voices || this.voices.length === 0) {
      this.loadVoices();
    }

    const targetMap = {
      hi: ['hi-in', 'hi', 'mr-in', 'mr'],
      bn: ['bn-in', 'bn-bd', 'bn'],
      es: ['es-es', 'es-mx', 'es-us', 'es'],
      en: ['en-in', 'en-us', 'en-gb', 'en']
    };

    const targetLocales = targetMap[langCode] || ['en-us', 'en'];

    // 1. Try exact match
    for (const loc of targetLocales) {
      const match = this.voices.find(v => v.lang.toLowerCase().replace('_', '-') === loc);
      if (match) return match;
    }

    // 2. Try prefix match
    for (const loc of targetLocales) {
      const prefix = loc.split('-')[0];
      const match = this.voices.find(v => v.lang.toLowerCase().startsWith(prefix));
      if (match) return match;
    }

    // 3. Fallback to default or first available voice
    return this.voices.find(v => v.default) || this.voices[0] || null;
  }

  /**
   * Splits mixed text into language-homogenous segments
   */
  segmentMixedText(text) {
    if (!text) return [];

    // Split sentences or clause blocks
    const clauses = text.match(/[^.!?।]+[.!?।]?/g) || [text];
    const segments = [];

    for (const clause of clauses) {
      const trimmed = clause.trim();
      if (!trimmed) continue;

      const lang = this.detectLanguage(trimmed);

      // Merge with previous segment if language matches
      if (segments.length > 0 && segments[segments.length - 1].lang === lang) {
        segments[segments.length - 1].text += ' ' + trimmed;
      } else {
        segments.push({ lang, text: trimmed });
      }
    }

    return segments;
  }

  /**
   * Chunks long text segments to prevent Web Speech API buffer timeout
   */
  chunkText(text, maxChars = 200) {
    if (text.length <= maxChars) return [text];

    const words = text.split(' ');
    const chunks = [];
    let current = '';

    for (const word of words) {
      if ((current + ' ' + word).length > maxChars) {
        if (current) chunks.push(current.trim());
        current = word;
      } else {
        current += (current ? ' ' : '') + word;
      }
    }
    if (current) chunks.push(current.trim());
    return chunks;
  }

  /**
   * Main method to toggle or speak a specific message
   */
  speakMessage(messageId, textContent, buttonElement, onStateChange) {
    if (!this.isSupported()) {
      console.warn('Web Speech API is not supported in this browser.');
      return false;
    }

    // Toggle off if clicking the currently speaking message
    if (this.currentMessageId === messageId && (this.synth.speaking || this.isSpeaking)) {
      this.stop();
      if (onStateChange) onStateChange(false);
      return false;
    }

    // Stop previous speech
    this.stop();

    const cleanText = this.extractCleanText(textContent);
    if (!cleanText) return false;

    this.currentMessageId = messageId;
    this.activeButton = buttonElement;
    this.onStateChangeCallback = onStateChange;
    this.utteranceQueue = [];

    const segments = this.segmentMixedText(cleanText);

    for (const seg of segments) {
      const chunks = this.chunkText(seg.text);
      const voice = this.getBestVoiceForLang(seg.lang);
      const langLocale = seg.lang === 'hi' ? 'hi-IN' : (seg.lang === 'bn' ? 'bn-IN' : (seg.lang === 'es' ? 'es-ES' : 'en-US'));

      if (typeof window !== 'undefined' && window.location.hostname === 'localhost') {
        console.log(`[MSAI Speech] Lang: ${seg.lang} | Voice: ${voice ? voice.name : 'Default'} (${voice ? voice.lang : langLocale})`);
      }

      for (const chunkText of chunks) {
        const utterance = new SpeechSynthesisUtterance(chunkText);
        if (voice) utterance.voice = voice;
        utterance.lang = voice ? voice.lang : langLocale;
        utterance.rate = 1.0;
        utterance.pitch = 1.0;
        this.utteranceQueue.push(utterance);
      }
    }

    if (this.utteranceQueue.length === 0) return false;

    this.isSpeaking = true;
    if (this.onStateChangeCallback) this.onStateChangeCallback(true);
    if (this.activeButton) {
      this.activeButton.classList.add('speaking-active');
      this.activeButton.setAttribute('title', 'Stop speaking');
    }

    this.playNextInQueue();
    return true;
  }

  playNextInQueue() {
    if (!this.isSpeaking || this.utteranceQueue.length === 0) {
      this.resetCurrentState();
      return;
    }

    const nextUtterance = this.utteranceQueue.shift();

    nextUtterance.onend = () => {
      this.playNextInQueue();
    };

    nextUtterance.onerror = (err) => {
      console.error('[MSAI Speech] Error:', err);
      this.playNextInQueue();
    };

    this.synth.speak(nextUtterance);
  }

  stop() {
    this.isSpeaking = false;
    this.utteranceQueue = [];
    if (this.synth) {
      this.synth.cancel();
    }
    this.resetCurrentState();
  }

  resetCurrentState() {
    if (this.activeButton) {
      this.activeButton.classList.remove('speaking-active');
      this.activeButton.setAttribute('title', 'Speaking');
    }
    if (this.isSpeaking && this.onStateChangeCallback) {
      this.onStateChangeCallback(false);
    }
    this.isSpeaking = false;
    this.currentMessageId = null;
    this.activeButton = null;
    this.onStateChangeCallback = null;
  }
}

export const msaiSpeech = new MSAISpeechManager();
if (typeof window !== 'undefined') {
  window.MSAISpeech = msaiSpeech;
}
