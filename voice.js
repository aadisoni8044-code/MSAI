/**
 * Nv Translate - Voice Layer
 * Handles Text-to-Speech (TTS) and Speech-to-Text (STT) using Web Speech APIs.
 */

/**
 * Check if Text-to-Speech is supported.
 */
export function isTTSSupported() {
  return 'speechSynthesis' in window && 'SpeechSynthesisUtterance' in window;
}

/**
 * Check if Speech Recognition (STT) is supported.
 */
export function isSpeechRecognitionSupported() {
  return 'SpeechRecognition' in window || 'webkitSpeechRecognition' in window;
}

/**
 * Text-to-speech synthesis function.
 * @param {string} text - Text to speak
 * @param {string} speechCode - BCP-47 language tag (e.g., 'en-US', 'hi-IN')
 * @param {Object} options - Optional parameters (rate, pitch, volume, onEnd, onError)
 * @returns {boolean} Whether speech utterance was started successfully
 */
export function speakText(text, speechCode = 'en-US', options = {}) {
  if (!isTTSSupported()) {
    if (options.onError) options.onError(new Error('Text-to-Speech is not supported in this browser.'));
    return false;
  }

  if (!text || !text.trim()) {
    return false;
  }

  // Cancel any ongoing speech
  window.speechSynthesis.cancel();

  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = speechCode || 'en-US';
  utterance.rate = options.rate || 1.0;
  utterance.pitch = options.pitch || 1.0;
  utterance.volume = options.volume || 1.0;

  if (options.onStart) utterance.onstart = options.onStart;
  if (options.onEnd) utterance.onend = options.onEnd;
  utterance.onerror = (e) => {
    console.warn('TTS error:', e);
    if (options.onError) options.onError(e);
  };

  window.speechSynthesis.speak(utterance);
  return true;
}

/**
 * Cancel any current speech synthesis.
 */
export function stopSpeaking() {
  if (isTTSSupported()) {
    window.speechSynthesis.cancel();
  }
}

/**
 * Initialize Speech Recognition instance.
 * @param {Object} callbacks - { onResult, onError, onStart, onEnd }
 * @param {string} speechCode - BCP-47 language tag
 * @returns {Object|null} SpeechRecognition controller object or null
 */
export function createSpeechRecognizer(callbacks = {}, speechCode = 'en-US') {
  if (!isSpeechRecognitionSupported()) {
    if (callbacks.onError) callbacks.onError(new Error('Speech recognition is not supported in this browser.'));
    return null;
  }

  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  const recognizer = new SpeechRecognition();

  recognizer.continuous = false;
  recognizer.interimResults = true;
  recognizer.lang = speechCode || 'en-US';

  recognizer.onstart = () => {
    if (callbacks.onStart) callbacks.onStart();
  };

  recognizer.onresult = (event) => {
    let transcript = '';
    let isFinal = false;

    for (let i = event.resultIndex; i < event.results.length; i++) {
      transcript += event.results[i][0].transcript;
      if (event.results[i].isFinal) {
        isFinal = true;
      }
    }

    if (callbacks.onResult) {
      callbacks.onResult({ transcript, isFinal });
    }
  };

  recognizer.onerror = (event) => {
    let errorMsg = 'Speech recognition error occurred.';
    if (event.error === 'not-allowed') {
      errorMsg = 'Microphone permission denied. Please enable microphone access in your browser.';
    } else if (event.error === 'no-speech') {
      errorMsg = 'No speech detected. Please try again.';
    } else if (event.error === 'network') {
      errorMsg = 'Network error occurred during speech recognition.';
    }
    if (callbacks.onError) callbacks.onError(new Error(errorMsg));
  };

  recognizer.onend = () => {
    if (callbacks.onEnd) callbacks.onEnd();
  };

  return recognizer;
}
