import { storage } from './storage.js';
import { themeManager } from './theme.js';
import { languageManager } from './language.js';
import { apiService } from './api.js';
import { exportData } from './export.js';
import { importData } from './import.js';
import { conversationManager } from './conversations.js';
import { openModal, closeModal } from './modal.js';
import { showNotification } from './notifications.js';

export function initSettings(onRefreshUI) {
  const langSelect = document.getElementById('setting-language');
  const themeSelect = document.getElementById('setting-theme');
  const modelSelect = document.getElementById('setting-model');
  const apiKeyInput = document.getElementById('setting-api-key');

  // Tab switching inside Settings modal
  const tabs = document.querySelectorAll('.settings-tab');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      const targetTab = tab.getAttribute('data-tab');
      document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.style.display = panel.id === targetTab ? 'block' : 'none';
      });
    });
  });

  if (langSelect) {
    langSelect.value = storage.get('language', 'en');
    langSelect.addEventListener('change', (e) => {
      languageManager.loadLanguage(e.target.value);
    });
  }

  if (themeSelect) {
    themeSelect.value = storage.get('theme', 'dark');
    themeSelect.addEventListener('change', (e) => {
      themeManager.setTheme(e.target.value);
    });
  }

  if (modelSelect) {
    modelSelect.value = storage.get('model', 'gemini-1.5-flash');
    modelSelect.addEventListener('change', (e) => {
      storage.set('model', e.target.value);
      const modelNameEl = document.getElementById('header-model-name');
      if (modelNameEl) {
        modelNameEl.textContent = e.target.value === 'gemini-1.5-pro' ? 'MSAI Pro' : 'MSAI Flash';
      }
    });
  }

  if (apiKeyInput) {
    apiKeyInput.value = apiService.getKey() === 'YOUR_API_KEY_HERE' ? '' : apiService.getKey();
    apiKeyInput.addEventListener('change', (e) => {
      apiService.setKey(e.target.value);
      showNotification('API Key updated successfully', 'success');
    });
  }

  // Data Tab Actions
  const exportBtn = document.getElementById('btn-export-data');
  if (exportBtn) {
    exportBtn.addEventListener('click', () => exportData());
  }

  const importTrigger = document.getElementById('btn-import-trigger');
  const fileImportInput = document.getElementById('file-import');
  if (importTrigger && fileImportInput) {
    importTrigger.addEventListener('click', () => fileImportInput.click());
    fileImportInput.addEventListener('change', (e) => {
      if (e.target.files.length > 0) {
        importData(e.target.files[0], () => {
          if (onRefreshUI) onRefreshUI();
          closeModal('modal-settings');
        });
      }
    });
  }

  const clearTrigger = document.getElementById('btn-clear-all-trigger');
  if (clearTrigger) {
    clearTrigger.addEventListener('click', () => {
      openModal('modal-clear-confirm');
    });
  }

  const confirmClearBtn = document.getElementById('btn-confirm-clear');
  if (confirmClearBtn) {
    confirmClearBtn.addEventListener('click', () => {
      conversationManager.clearAll();
      if (onRefreshUI) onRefreshUI();
      closeModal('modal-clear-confirm');
      closeModal('modal-settings');
      showNotification('All conversations cleared', 'info');
    });
  }
}