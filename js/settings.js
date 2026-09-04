/**
 * Settings Modal Controller
 */
import { storage } from './storage.js';
import { themeManager } from './theme.js';
import { i18n } from './language.js';
import { conversations } from './conversations.js';
import { notifications } from './notifications.js';
import { exportConversationsJSON } from './export.js';
import { importConversationsJSON } from './import.js';
import { modalManager } from './modal.js';
import { initializeAPI } from './api.js';

class SettingsController {
  constructor() {
    this.settings = {
      theme: 'dark',
      language: 'en',
      model: 'gemini-3.8-flash',
      temperature: 0.7,
      enterToSend: true,
      autoScroll: true,
      saveHistory: true,
      animations: true,
      apiKey: ''
    };
  }

  init() {
    this.loadSettings();
    this.setupTabNavigation();
    this.setupFormBindings();
    this.setupActionButtons();

    document.querySelectorAll('[data-open-settings]').forEach(btn => {
      btn.addEventListener('click', () => {
        modalManager.open('settingsModal');
        this.populateForm();
      });
    });
  }

  loadSettings() {
    const saved = storage.get('msai_settings', {});
    this.settings = { ...this.settings, ...saved };

    // Auto-migrate deprecated models
    const deprecated = ['gemini-2.0-flash', 'gemini-1.5-pro', 'gemini-1.5-flash', 'gemini-2.0-pro', 'gemini-pro'];
    if (!this.settings.model || deprecated.includes(this.settings.model)) {
      this.settings.model = 'gemini-3.8-flash';
      this.saveSettings();
    }
  }

  saveSettings() {
    storage.set('msai_settings', this.settings);
    initializeAPI();
  }

  setupTabNavigation() {
    const tabButtons = document.querySelectorAll('.settings-tab-btn');
    const sections = document.querySelectorAll('.settings-section');

    tabButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const target = btn.getAttribute('data-tab');

        tabButtons.forEach(b => b.classList.remove('active'));
        sections.forEach(s => s.classList.remove('active'));

        btn.classList.add('active');
        const activeSec = document.getElementById(`settings-sec-${target}`);
        if (activeSec) activeSec.classList.add('active');
      });
    });
  }

  setupFormBindings() {
    // Language
    const langSelect = document.getElementById('settingsLanguage');
    if (langSelect) {
      langSelect.addEventListener('change', async (e) => {
        this.settings.language = e.target.value;
        this.saveSettings();
        await i18n.setLanguage(e.target.value);
      });
    }

    // Theme
    const themeSelect = document.getElementById('settingsTheme');
    if (themeSelect) {
      themeSelect.addEventListener('change', (e) => {
        this.settings.theme = e.target.value;
        this.saveSettings();
        themeManager.setTheme(e.target.value);
      });
    }

    // Model
    const modelSelect = document.getElementById('settingsModel');
    if (modelSelect) {
      modelSelect.addEventListener('change', (e) => {
        this.settings.model = e.target.value;
        this.saveSettings();
        const headerModelBtn = document.getElementById('modelSelectorText');
        if (headerModelBtn) {
          headerModelBtn.textContent = modelSelect.options[modelSelect.selectedIndex].text;
        }
      });
    }

    // API Key
    const apiKeyInput = document.getElementById('settingsApiKey');
    if (apiKeyInput) {
      apiKeyInput.addEventListener('change', (e) => {
        this.settings.apiKey = e.target.value.trim();
        this.saveSettings();
        notifications.success(i18n.get('notifications.saved', 'Settings saved'));
      });
    }

    // Temperature Slider
    const tempSlider = document.getElementById('settingsTemperature');
    const tempValue = document.getElementById('settingsTempValue');
    if (tempSlider && tempValue) {
      tempSlider.addEventListener('input', (e) => {
        const val = parseFloat(e.target.value);
        tempValue.textContent = val.toFixed(1);
        this.settings.temperature = val;
        this.saveSettings();
      });
    }

    // Enter to send toggle
    const enterToggle = document.getElementById('settingsEnterToSend');
    if (enterToggle) {
      enterToggle.addEventListener('change', (e) => {
        this.settings.enterToSend = e.target.checked;
        this.saveSettings();
      });
    }

    // Auto scroll toggle
    const scrollToggle = document.getElementById('settingsAutoScroll');
    if (scrollToggle) {
      scrollToggle.addEventListener('change', (e) => {
        this.settings.autoScroll = e.target.checked;
        this.saveSettings();
      });
    }

    // Animations toggle
    const animToggle = document.getElementById('settingsAnimations');
    if (animToggle) {
      animToggle.addEventListener('change', (e) => {
        this.settings.animations = e.target.checked;
        document.body.classList.toggle('reduce-motion', !e.target.checked);
        this.saveSettings();
      });
    }
  }

  setupActionButtons() {
    // Export
    const btnExport = document.getElementById('btnExportData');
    if (btnExport) {
      btnExport.addEventListener('click', () => {
        exportConversationsJSON();
        notifications.success(i18n.get('notifications.exported', 'Conversations exported'));
      });
    }

    // Import
    const fileImport = document.getElementById('fileImportInput');
    const btnImport = document.getElementById('btnImportData');
    if (btnImport && fileImport) {
      btnImport.addEventListener('click', () => fileImport.click());
      fileImport.addEventListener('change', async (e) => {
        const file = e.target.files?.[0];
        if (file) {
          const ok = await importConversationsJSON(file);
          if (ok) {
            notifications.success(i18n.get('notifications.imported', 'Import successful'));
          } else {
            notifications.error('Failed to import JSON file');
          }
          fileImport.value = '';
        }
      });
    }

    // Clear all
    const btnClear = document.getElementById('btnClearData');
    if (btnClear) {
      btnClear.addEventListener('click', () => {
        if (confirm(i18n.get('settings.clearConfirm', 'Are you sure you want to delete all conversations?'))) {
          conversations.clearAll();
          notifications.info(i18n.get('notifications.cleared', 'All conversations cleared'));
          modalManager.close('settingsModal');
        }
      });
    }
  }

  populateForm() {
    const langSelect = document.getElementById('settingsLanguage');
    if (langSelect) langSelect.value = this.settings.language || 'en';

    const themeSelect = document.getElementById('settingsTheme');
    if (themeSelect) themeSelect.value = this.settings.theme || 'dark';

    const modelSelect = document.getElementById('settingsModel');
    if (modelSelect) modelSelect.value = this.settings.model || 'gemini-3.8-flash';

    const apiKeyInput = document.getElementById('settingsApiKey');
    if (apiKeyInput) apiKeyInput.value = this.settings.apiKey || '';

    const tempSlider = document.getElementById('settingsTemperature');
    const tempValue = document.getElementById('settingsTempValue');
    if (tempSlider && tempValue) {
      tempSlider.value = this.settings.temperature ?? 0.7;
      tempValue.textContent = (this.settings.temperature ?? 0.7).toFixed(1);
    }

    const enterToggle = document.getElementById('settingsEnterToSend');
    if (enterToggle) enterToggle.checked = this.settings.enterToSend ?? true;

    const scrollToggle = document.getElementById('settingsAutoScroll');
    if (scrollToggle) scrollToggle.checked = this.settings.autoScroll ?? true;

    const animToggle = document.getElementById('settingsAnimations');
    if (animToggle) animToggle.checked = this.settings.animations ?? true;
  }
}

export const settingsController = new SettingsController();
