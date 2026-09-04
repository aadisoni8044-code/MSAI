/**
 * Internationalization (i18n) Language System
 * Supports 4 languages: en (English), hi (Hindi), bn (Bengali), es (Spanish)
 */
import { storage } from './storage.js';
import { events } from './events.js';

class LanguageManager {
  constructor() {
    this.currentLang = 'en';
    this.translations = {};
  }

  async init() {
    const savedLang = storage.get('msai_language', 'en');
    await this.setLanguage(savedLang);
  }

  async setLanguage(langCode) {
    const validLangs = ['en', 'hi', 'bn', 'es'];
    const selected = validLangs.includes(langCode) ? langCode : 'en';

    try {
      if (!this.translations[selected]) {
        const response = await fetch(`/data/${selected}.json`);
        this.translations[selected] = await response.json();
      }
      this.currentLang = selected;
      storage.set('msai_language', selected);
      document.documentElement.lang = selected;
      this.updateDOM();
      events.emit('language:changed', selected);
    } catch (err) {
      console.error(`Failed to load translation for ${selected}:`, err);
    }
  }

  get(keyPath, defaultText = '') {
    if (!this.translations[this.currentLang]) return defaultText;
    const parts = keyPath.split('.');
    let current = this.translations[this.currentLang];
    for (const part of parts) {
      if (current && typeof current === 'object' && part in current) {
        current = current[part];
      } else {
        return defaultText;
      }
    }
    return typeof current === 'string' ? current : defaultText;
  }

  updateDOM() {
    // Update all elements with data-i18n attribute
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      const text = this.get(key);
      if (text) {
        el.textContent = text;
      }
    });

    // Update placeholder attributes
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
      const key = el.getAttribute('data-i18n-placeholder');
      const text = this.get(key);
      if (text) {
        el.setAttribute('placeholder', text);
      }
    });

    // Update title/aria-label attributes
    document.querySelectorAll('[data-i18n-title]').forEach(el => {
      const key = el.getAttribute('data-i18n-title');
      const text = this.get(key);
      if (text) {
        el.setAttribute('title', text);
        el.setAttribute('aria-label', text);
      }
    });
  }
}

export const i18n = new LanguageManager();
