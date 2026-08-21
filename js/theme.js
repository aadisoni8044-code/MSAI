/**
 * MSAI - Theme Management (Dark & Light Theme)
 */

import { storage } from "./storage.js";
import { toast } from "./toast.js";

class ThemeManager {
  constructor() {
    this.currentTheme = "dark";
  }

  init() {
    const settings = storage.getSettings();
    this.currentTheme = settings.theme || "dark";
    this.applyTheme(this.currentTheme, false);
  }

  applyTheme(theme, notify = true) {
    this.currentTheme = theme;
    document.documentElement.setAttribute("data-theme", theme);

    if (theme === "dark") {
      document.documentElement.classList.add("dark");
      document.documentElement.classList.remove("light");
    } else {
      document.documentElement.classList.add("light");
      document.documentElement.classList.remove("dark");
    }

    // Save to settings
    const settings = storage.getSettings();
    settings.theme = theme;
    storage.saveSettings(settings);

    // Update theme toggle buttons in UI
    this.updateToggleButtons();

    // Sync select dropdown in settings modal if present
    const selectEl = document.getElementById("setting-theme");
    if (selectEl && selectEl.value !== theme) {
      selectEl.value = theme;
    }

    if (notify) {
      toast.info(`Switched to ${theme === "dark" ? "Dark" : "Light"} Mode`, 1800);
    }
  }

  toggleTheme() {
    const newTheme = this.currentTheme === "dark" ? "light" : "dark";
    this.applyTheme(newTheme, true);
    return newTheme;
  }

  updateToggleButtons() {
    const themeToggles = document.querySelectorAll(".theme-toggle-btn");
    themeToggles.forEach((btn) => {
      const isDark = this.currentTheme === "dark";
      btn.setAttribute("title", isDark ? "Switch to Light Mode" : "Switch to Dark Mode");
      btn.setAttribute("aria-label", isDark ? "Switch to Light Mode" : "Switch to Dark Mode");

      const iconContainer = btn.querySelector(".theme-icon-slot");
      if (iconContainer) {
        iconContainer.innerHTML = isDark
          ? `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/></svg>`
          : `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/></svg>`;
      }

      const textContainer = btn.querySelector(".theme-text-slot");
      if (textContainer) {
        textContainer.textContent = isDark ? "Light Mode" : "Dark Mode";
      }
    });
  }
}

export const themeManager = new ThemeManager();
