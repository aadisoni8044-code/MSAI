/**
 * NV ZIP — Theme Controller
 * Handles switching between Dark, Light, and Frosted Glass themes,
 * saving preferences in localStorage and managing UI dropdown states.
 */

class ThemeController {
  constructor() {
    this.themeToggleBtn = document.getElementById('theme-toggle-btn');
    this.themeMenu = document.getElementById('theme-menu');
    this.themeOptions = document.querySelectorAll('.theme-option');
    this.currentTheme = localStorage.getItem('nv_zip_theme') || 'dark';

    this.init();
  }

  init() {
    this.applyTheme(this.currentTheme);

    if (this.themeToggleBtn && this.themeMenu) {
      this.themeToggleBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        this.themeMenu.classList.toggle('hidden');
      });

      document.addEventListener('click', () => {
        if (!this.themeMenu.classList.contains('hidden')) {
          this.themeMenu.classList.add('hidden');
        }
      });
    }

    this.themeOptions.forEach(option => {
      option.addEventListener('click', (e) => {
        const themeVal = e.currentTarget.getAttribute('data-theme-val');
        if (themeVal) {
          this.setTheme(themeVal);
        }
      });
    });
  }

  setTheme(themeName) {
    this.currentTheme = themeName;
    localStorage.setItem('nv_zip_theme', themeName);
    this.applyTheme(themeName);
    if (this.themeMenu) {
      this.themeMenu.classList.add('hidden');
    }
  }

  applyTheme(themeName) {
    document.documentElement.setAttribute('data-theme', themeName);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.themeController = new ThemeController();
});
