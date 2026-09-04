/**
 * Theme Manager (Dark, Light, System)
 */
import { storage } from './storage.js';
import { events } from './events.js';

class ThemeManager {
  constructor() {
    this.currentTheme = 'dark';
    this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
  }

  init() {
    const saved = storage.get('msai_theme', 'dark');
    this.setTheme(saved);

    this.mediaQuery.addEventListener('change', () => {
      if (this.currentTheme === 'system') {
        this.applyTheme('system');
      }
    });
  }

  setTheme(theme) {
    this.currentTheme = theme;
    storage.set('msai_theme', theme);
    this.applyTheme(theme);
    events.emit('theme:changed', theme);
  }

  applyTheme(theme) {
    const root = document.documentElement;
    if (theme === 'system') {
      const isDark = this.mediaQuery.matches;
      root.setAttribute('data-theme', isDark ? 'dark' : 'light');
    } else {
      root.setAttribute('data-theme', theme);
    }
  }

  getTheme() {
    return this.currentTheme;
  }
}

export const themeManager = new ThemeManager();
