/**
 * MSAI Language Manager
 * Supports English (en), Hindi (hi), Spanish (es), Bengali (bn)
 */

window.MSAI = window.MSAI || {};

window.MSAI.Language = {
  currentLang: 'en',
  translations: {},
  loadedLocales: {},

  async init() {
    this.currentLang = window.MSAI.Storage.get('msai_lang_v1') || 'en';
    await this.loadLocale(this.currentLang);
    this.applyTranslations();
  },

  async loadLocale(lang) {
    if (this.loadedLocales[lang]) {
      this.translations = this.loadedLocales[lang];
      this.currentLang = lang;
      return;
    }

    try {
      const res = await fetch(`./locales/${lang}.json`);
      if (!res.ok) throw new Error(`Failed to load ${lang} locale`);
      const data = await res.json();
      this.loadedLocales[lang] = data;
      this.translations = data;
      this.currentLang = lang;
    } catch (err) {
      console.warn(`Locale load failed for ${lang}, falling back to English.`, err);
      if (lang !== 'en') {
        await this.loadLocale('en');
      }
    }
  },

  async setLanguage(lang) {
    await this.loadLocale(lang);
    window.MSAI.Storage.set('msai_lang_v1', lang);
    this.applyTranslations();
    if (window.MSAI.Notifications) {
      window.MSAI.Notifications.show(this.get('messages.settingsSaved', 'Language changed'));
    }
  },

  get(keyPath, fallback = '') {
    const keys = keyPath.split('.');
    let current = this.translations;
    for (const k of keys) {
      if (current && current[k] !== undefined) {
        current = current[k];
      } else {
        return fallback || keyPath;
      }
    }
    return current;
  },

  applyTranslations() {
    document.querySelectorAll('[data-i18n]').forEach((el) => {
      const key = el.getAttribute('data-i18n');
      const translation = this.get(key);
      if (translation) {
        if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
          if (el.hasAttribute('placeholder')) {
            el.setAttribute('placeholder', translation);
          }
        } else {
          el.textContent = translation;
        }
      }
    });

    document.querySelectorAll('[data-i18n-placeholder]').forEach((el) => {
      const key = el.getAttribute('data-i18n-placeholder');
      const translation = this.get(key);
      if (translation) {
        el.setAttribute('placeholder', translation);
      }
    });

    document.querySelectorAll('[data-i18n-title]').forEach((el) => {
      const key = el.getAttribute('data-i18n-title');
      const translation = this.get(key);
      if (translation) {
        el.setAttribute('title', translation);
      }
    });

    document.documentElement.setAttribute('lang', this.currentLang);
  }
};
