/**
 * Theme Manager Module
 * Handles light/dark theme switching and persistence.
 */

export class ThemeManager {
    constructor() {
        this.currentTheme = localStorage.getItem("msai_theme") || "dark";
    }

    init() {
        this.applyTheme(this.currentTheme);
    }

    applyTheme(theme) {
        this.currentTheme = theme;
        document.documentElement.setAttribute("data-theme", theme);
        localStorage.setItem("msai_theme", theme);

        const darkIcon = document.getElementById("theme-icon-dark");
        const lightIcon = document.getElementById("theme-icon-light");
        const themeText = document.getElementById("theme-text");

        if (theme === "dark") {
            if (darkIcon) darkIcon.style.display = "block";
            if (lightIcon) lightIcon.style.display = "none";
            if (themeText) themeText.textContent = "Light Mode";
        } else {
            if (darkIcon) darkIcon.style.display = "none";
            if (lightIcon) lightIcon.style.display = "block";
            if (themeText) themeText.textContent = "Dark Mode";
        }
    }

    toggle() {
        const newTheme = this.currentTheme === "dark" ? "light" : "dark";
        this.applyTheme(newTheme);
        return newTheme;
    }
}

export const theme = new ThemeManager();
