/**
 * MSAI Theme & Accent Color Manager
 */

window.MSAI = window.MSAI || {};

window.MSAI.Themes = {
  currentTheme: 'dark',
  currentAccent: 'blue',

  init() {
    this.currentTheme = window.MSAI.Storage.get('msai_theme_v1') || 'dark';
    this.currentAccent = window.MSAI.Storage.get('msai_accent_v1') || 'blue';
    this.applyTheme(this.currentTheme);
    this.applyAccent(this.currentAccent);

    // Listen to system theme preference changes if set to system
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (this.currentTheme === 'system') {
        this.updateSystemTheme(e.matches);
      }
    });
  },

  setTheme(theme) {
    this.currentTheme = theme;
    window.MSAI.Storage.set('msai_theme_v1', theme);
    this.applyTheme(theme);
  },

  applyTheme(theme) {
    let effectiveTheme = theme;
    if (theme === 'system') {
      effectiveTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    document.documentElement.setAttribute('data-theme', effectiveTheme);
  },

  updateSystemTheme(isDark) {
    document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
  },

  setAccent(accent) {
    this.currentAccent = accent;
    window.MSAI.Storage.set('msai_accent_v1', accent);
    this.applyAccent(accent);
  },

  applyAccent(accent) {
    document.documentElement.setAttribute('data-accent', accent);
  }
};
