import { storage } from './storage.js';

export const themeManager = {
  init() {
    const savedTheme = storage.get('theme', 'dark');
    const savedAccent = storage.get('accent', 'blue');
    this.setTheme(savedTheme);
    this.setAccent(savedAccent);
  },

  setTheme(theme) {
    const root = document.documentElement;
    if (theme === 'system') {
      const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
      root.setAttribute('data-theme', systemTheme);
    } else {
      root.setAttribute('data-theme', theme);
    }
    storage.set('theme', theme);
  },

  setAccent(color) {
    document.documentElement.setAttribute('data-accent', color);
    storage.set('accent', color);
  }
};