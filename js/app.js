/**
 * MSAI Application Entry Point
 * Coordinates bootstrapping of all client-side modules
 */
import { themeManager } from './theme.js';
import { i18n } from './language.js';
import { conversations } from './conversations.js';
import { chatController } from './chat.js';
import { sidebarController } from './sidebar.js';
import { settingsController } from './settings.js';
import { searchController } from './search.js';
import { modalManager } from './modal.js';
import { notifications } from './notifications.js';
import { setupKeyboardShortcuts } from './keyboard.js';
import { initializeAPI } from './api.js';
import { subscriptionsController } from './subscriptions.js';

document.addEventListener('DOMContentLoaded', async () => {
  // 1. Initialize Theme
  themeManager.init();

  // 2. Initialize Notifications Container
  notifications.init();

  // 3. Initialize Internationalization (en, hi, bn, es)
  await i18n.init();

  // 4. Initialize LocalStorage Conversations
  conversations.init();

  // 5. Initialize Modals
  modalManager.init();

  // 6. Initialize Settings
  settingsController.init();

  // 7. Initialize Subscriptions Controller
  await subscriptionsController.init();

  // 8. Initialize Search
  searchController.init();

  // 9. Initialize Sidebar
  sidebarController.init();

  // 10. Initialize Chat Flow & Composer
  chatController.init();

  // 11. Setup Global Keyboard Shortcuts
  setupKeyboardShortcuts();

  // 12. Initialize API readiness
  initializeAPI();

  // Model Dropdown in Header
  setupHeaderModelDropdown();

  console.log('MSAI Web Application initialized successfully.');
});

function setupHeaderModelDropdown() {
  const btn = document.getElementById('btnHeaderModel');
  const menu = document.getElementById('headerModelDropdown');
  if (!btn || !menu) return;

  // Sync initial state from settings
  const currentModel = settingsController.settings.model || 'gemini-3.8-flash';
  let matched = false;
  menu.querySelectorAll('.model-option').forEach(opt => {
    if (opt.getAttribute('data-model') === currentModel) {
      menu.querySelectorAll('.model-option').forEach(o => o.classList.remove('active'));
      opt.classList.add('active');
      const modelName = opt.querySelector('.model-option-name')?.textContent || currentModel;
      const txt = document.getElementById('modelSelectorText');
      if (txt) txt.textContent = modelName;
      matched = true;
    }
  });

  btn.addEventListener('click', (e) => {
    e.stopPropagation();
    menu.classList.toggle('open');
  });

  document.addEventListener('click', () => {
    menu.classList.remove('open');
  });

  menu.querySelectorAll('.model-option').forEach(opt => {
    opt.addEventListener('click', () => {
      const modelId = opt.getAttribute('data-model');
      const modelName = opt.querySelector('.model-option-name')?.textContent || modelId;

      menu.querySelectorAll('.model-option').forEach(o => o.classList.remove('active'));
      opt.classList.add('active');

      const txt = document.getElementById('modelSelectorText');
      if (txt) txt.textContent = modelName;

      // Update in settings
      const settings = settingsController.settings;
      settings.model = modelId;
      settingsController.saveSettings();

      menu.classList.remove('open');
    });
  });
}
