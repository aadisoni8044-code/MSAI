/**
 * Nv Translate - API Layer
 * Handles translation API requests (MyMemory, LibreTranslate, or Demo fallback).
 */

const STORAGE_KEY_API_CONFIG = 'nv_translate_api_config';

// Default configuration
const defaultConfig = {
  provider: 'mymemory', // 'mymemory' | 'libretranslate' | 'demo'
  libreEndpoint: 'https://libretranslate.com',
  libreApiKey: '',
  mymemoryEmail: ''
};

/**
 * Get stored API configuration or defaults.
 */
export function getApiConfig() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY_API_CONFIG);
    return saved ? { ...defaultConfig, ...JSON.parse(saved) } : { ...defaultConfig };
  } catch (e) {
    return { ...defaultConfig };
  }
}

/**
 * Save API configuration.
 */
export function saveApiConfig(config) {
  const current = getApiConfig();
  const updated = { ...current, ...config };
  localStorage.setItem(STORAGE_KEY_API_CONFIG, JSON.stringify(updated));
  return updated;
}

/**
 * Detect language of a given text.
 * @param {string} text
 * @returns {Promise<{detectedLanguage: string, confidence?: number}>}
 */
export async function detectLanguage(text) {
  if (!text || !text.trim()) {
    return { detectedLanguage: 'en' };
  }

  const config = getApiConfig();

  if (config.provider === 'libretranslate' && config.libreEndpoint) {
    try {
      const response = await fetch(`${config.libreEndpoint.replace(/\/$/, '')}/detect`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          q: text,
          api_key: config.libreApiKey || undefined
        })
      });
      if (response.ok) {
        const data = await response.json();
        if (Array.isArray(data) && data.length > 0) {
          return { detectedLanguage: data[0].language, confidence: data[0].confidence };
        }
      }
    } catch (e) {
      console.warn('LibreTranslate detect failed, falling back:', e);
    }
  }

  // Basic client-side heuristic detector fallback for demo/mymemory
  const sample = text.trim().slice(0, 100);
  if (/[\u0900-\u097F]/.test(sample)) return { detectedLanguage: 'hi' };
  if (/[\u0600-\u06FF]/.test(sample)) return { detectedLanguage: 'ar' };
  if (/[\u0980-\u09FF]/.test(sample)) return { detectedLanguage: 'bn' };
  if (/[\u0B80-\u0BFF]/.test(sample)) return { detectedLanguage: 'ta' };
  if (/[\u0C00-\u0C7F]/.test(sample)) return { detectedLanguage: 'te' };
  if (/[\u3040-\u30FF\u4E00-\u9FAF]/.test(sample)) return { detectedLanguage: 'ja' };
  if (/[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AF]/.test(sample)) return { detectedLanguage: 'ko' };
  if (/[\u0400-\u04FF]/.test(sample)) return { detectedLanguage: 'ru' };
  if (/[\u0E00-\u0E7F]/.test(sample)) return { detectedLanguage: 'th' };

  return { detectedLanguage: 'en' };
}

/**
 * Translate text using selected provider.
 * @param {string} text - Source text to translate
 * @param {string} sourceLang - Source language code ('auto' or ISO code)
 * @param {string} targetLang - Target language code
 * @returns {Promise<{translatedText: string, detectedSourceLanguage?: string, provider: string, isDemo?: boolean}>}
 */
export async function translateText(text, sourceLang, targetLang) {
  if (!text || !text.trim()) {
    return { translatedText: '', provider: 'none' };
  }

  if (sourceLang === targetLang && sourceLang !== 'auto') {
    return { translatedText: text, detectedSourceLanguage: sourceLang, provider: 'direct' };
  }

  const config = getApiConfig();

  if (config.provider === 'demo') {
    return runDemoTranslation(text, sourceLang, targetLang);
  }

  if (config.provider === 'libretranslate') {
    return translateWithLibreTranslate(text, sourceLang, targetLang, config);
  }

  // Default: MyMemory
  try {
    return await translateWithMyMemory(text, sourceLang, targetLang, config);
  } catch (error) {
    console.error('MyMemory API error:', error);
    throw new Error(error.message || 'Failed to fetch translation from API.');
  }
}

/**
 * Translate using MyMemory API
 */
async function translateWithMyMemory(text, sourceLang, targetLang, config) {
  let langPair = `${sourceLang === 'auto' ? 'Autodetect' : sourceLang}|${targetLang}`;
  let url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${encodeURIComponent(langPair)}`;

  if (config.mymemoryEmail) {
    url += `&de=${encodeURIComponent(config.mymemoryEmail)}`;
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`MyMemory API returned status ${response.status}`);
  }

  const data = await response.json();

  if (data.responseStatus !== 200 && data.responseStatus !== '200') {
    const errorMsg = data.responseDetails || 'Translation request failed.';
    throw new Error(errorMsg);
  }

  const translatedText = data.responseData?.translatedText;
  if (translatedText === undefined || translatedText === null) {
    throw new Error('Invalid response structure from translation service.');
  }

  let detectedSourceLanguage = sourceLang;
  if (sourceLang === 'auto') {
    const detection = await detectLanguage(text);
    detectedSourceLanguage = detection.detectedLanguage || 'en';
  }

  return {
    translatedText,
    detectedSourceLanguage,
    provider: 'MyMemory'
  };
}

/**
 * Translate using LibreTranslate API
 */
async function translateWithLibreTranslate(text, sourceLang, targetLang, config) {
  const endpoint = `${(config.libreEndpoint || 'https://libretranslate.com').replace(/\/$/, '')}/translate`;

  let source = sourceLang;
  if (source === 'auto') {
    const detection = await detectLanguage(text);
    source = detection.detectedLanguage || 'en';
  }

  const payload = {
    q: text,
    source: source,
    target: targetLang,
    format: 'text'
  };

  if (config.libreApiKey) {
    payload.api_key = config.libreApiKey;
  }

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`LibreTranslate Error (${response.status}): ${errText || response.statusText}`);
  }

  const data = await response.json();
  if (!data || !data.translatedText) {
    throw new Error('Invalid response received from LibreTranslate API.');
  }

  return {
    translatedText: data.translatedText,
    detectedSourceLanguage: source,
    provider: 'LibreTranslate'
  };
}

/**
 * Demo fallback translation mode
 */
function runDemoTranslation(text, sourceLang, targetLang) {
  const dictionary = {
    'hello': { es: 'Hola', fr: 'Bonjour', de: 'Hallo', hi: 'नमस्ते', ar: 'مرحبا', zh: '你好', ja: 'こんにちは', ru: 'Здравствуйте' },
    'thank you': { es: 'Gracias', fr: 'Merci', de: 'Danke', hi: 'धन्यवाद', ar: 'شكرا', zh: '谢谢', ja: 'ありがとう', ru: 'Спасибо' },
    'welcome': { es: 'Bienvenido', fr: 'Bienvenue', de: 'Willkommen', hi: 'स्वागत है', ar: 'أهلاً بك', zh: '欢迎', ja: 'ようこそ', ru: 'Добро пожаловать' },
    'good morning': { es: 'Buenos días', fr: 'Bonjour', de: 'Guten Morgen', hi: 'सुप्रभात', ar: 'صباح الخير', zh: '早安', ja: 'おはようございます', ru: 'Доброе утро' }
  };

  const lower = text.trim().toLowerCase();
  let translatedText = '';

  if (dictionary[lower] && dictionary[lower][targetLang]) {
    translatedText = dictionary[lower][targetLang];
  } else {
    translatedText = `[Demo Mode] Translated "${text}" (${sourceLang} ➔ ${targetLang})`;
  }

  return Promise.resolve({
    translatedText,
    detectedSourceLanguage: sourceLang === 'auto' ? 'en' : sourceLang,
    provider: 'Demo Mode',
    isDemo: true
  });
}
