import { storage } from './storage.js';

class LanguageManager {
  constructor() {
    this.currentLang = 'en';
    this.translations = {};
  }

  async init() {
    this.currentLang = storage.get('language', 'en');
    await this.loadLanguage(this.currentLang);
  }

  async loadLanguage(lang) {
    try {
      const res = await fetch(`data/${lang}.json`);
      if (!res.ok) throw new Error(`Failed to load ${lang}.json`);
      this.translations = await res.json();
      this.currentLang = lang;
      storage.set('language', lang);
      this.updateUI();
    } catch (err) {
      console.error(`Language load error for ${lang}:`, err);
      if (lang !== 'en') await this.loadLanguage('en');
    }
  }

  t(key) {
    return this.translations[key] || key;
  }

  updateUI() {
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (this.translations[key]) {
        el.textContent = this.translations[key];
      }
    });

    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
      const key = el.getAttribute('data-i18n-placeholder');
      if (this.translations[key]) {
        el.placeholder = this.translations[key];
      }
    });
  }
}

export const languageManager = new LanguageManager();