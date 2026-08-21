import { storage } from './storage.js';

/**
 * Dark / Light Theme Manager
 */
class ThemeManager {
    constructor() {
        this.currentTheme = 'dark';
    }

    init() {
        const savedTheme = storage.getSetting('theme', 'dark');
        this.setTheme(savedTheme);
    }

    setTheme(theme) {
        this.currentTheme = theme;
        document.documentElement.setAttribute('data-theme', theme);
        storage.setSetting('theme', theme);

        const themeText = document.querySelector('#theme-toggle-btn .btn-text');
        if (themeText) {
            themeText.textContent = theme === 'dark' ? 'Light Mode' : 'Dark Mode';
        }
    }

    toggleTheme() {
        const newTheme = this.currentTheme === 'dark' ? 'light' : 'dark';
        this.setTheme(newTheme);
        return newTheme;
    }
}

export const themeManager = new ThemeManager();
