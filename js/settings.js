/**
 * MSAI Settings & Color Theme Picker Controller
 */
window.MSAI = window.MSAI || {};

window.MSAI.Settings = {
  colors: [
    { id: 'blue', name: 'Blue', hex: '#3b82f6' },
    { id: 'purple', name: 'Purple', hex: '#8b5cf6' },
    { id: 'cyan', name: 'Cyan', hex: '#06b6d4' },
    { id: 'green', name: 'Green', hex: '#10b981' },
    { id: 'orange', name: 'Orange', hex: '#f97316' },
    { id: 'pink', name: 'Pink', hex: '#ec4899' },
    { id: 'red', name: 'Red', hex: '#ef4444' },
    { id: 'gold', name: 'Gold', hex: '#eab308' },
    { id: 'indigo', name: 'Indigo', hex: '#6366f1' },
    { id: 'teal', name: 'Teal', hex: '#14b8a6' }
  ],

  openModal() {
    const currentAccent = window.MSAI.Themes.currentAccent;
    const currentTheme = window.MSAI.Themes.currentTheme;
    const currentLang = window.MSAI.Language.currentLang;
    const savedApiKey = window.MSAI.Storage.get('msai_api_key_v1') || '';

    const modalContent = `
      <div class="modal-header">
        <h3 data-i18n="settings.title">Settings</h3>
        <button class="btn-icon btn-close-modal">✕</button>
      </div>
      <div class="modal-body">

        <!-- APPEARANCE & 10 ACCENT COLORS -->
        <div class="settings-section">
          <label class="settings-label" data-i18n="settings.accentColor">Accent Color (10 Options)</label>
          <div class="theme-selector-grid">
            ${this.colors.map(c => `
              <div class="color-swatch-card ${c.id === currentAccent ? 'active' : ''}" data-color="${c.id}">
                <div class="color-circle" style="background-color: ${c.hex};"></div>
                <span class="color-label">${c.name}</span>
              </div>
            `).join('')}
          </div>
        </div>

        <!-- THEME MODE -->
        <div class="settings-section">
          <label class="settings-label" data-i18n="settings.theme">Theme</label>
          <div style="display: flex; gap: 10px;">
            <button class="btn-secondary theme-btn ${currentTheme === 'dark' ? 'btn-primary' : ''}" data-theme="dark" data-i18n="settings.themeDark">Dark</button>
            <button class="btn-secondary theme-btn ${currentTheme === 'light' ? 'btn-primary' : ''}" data-theme="light" data-i18n="settings.themeLight">Light</button>
            <button class="btn-secondary theme-btn ${currentTheme === 'system' ? 'btn-primary' : ''}" data-theme="system" data-i18n="settings.themeSystem">System</button>
          </div>
        </div>

        <!-- LANGUAGE SELECTOR -->
        <div class="settings-section">
          <label class="settings-label" data-i18n="settings.selectLanguage">Language</label>
          <select id="setting-language-select" class="form-input">
            <option value="en" ${currentLang === 'en' ? 'selected' : ''}>English</option>
            <option value="hi" ${currentLang === 'hi' ? 'selected' : ''}>Hindi (हिंदी)</option>
            <option value="es" ${currentLang === 'es' ? 'selected' : ''}>Spanish (Español)</option>
            <option value="bn" ${currentLang === 'bn' ? 'selected' : ''}>Bengali (বাংলা)</option>
          </select>
        </div>

        <!-- API KEY CONFIGURATION -->
        <div class="settings-section">
          <label class="settings-label" data-i18n="settings.apiKeyLabel">Google AI (Gemini) API Key</label>
          <input type="password" id="setting-api-key" class="form-input" placeholder="Enter API Key" value="${savedApiKey}">
          <div style="font-size: 0.75rem; color: var(--text-muted);">API key is saved locally in your browser session storage.</div>
        </div>

        <!-- DATA MANAGEMENT -->
        <div class="settings-section">
          <button id="btn-clear-history" class="btn-secondary" style="color: #ef4444; border-color: rgba(239, 68, 68, 0.3);" data-i18n="settings.clearHistory">Clear Chat History</button>
        </div>

        <!-- ABOUT MSAI BRANDING -->
        <div class="settings-section" style="padding-top: 10px; border-top: 1px solid var(--border-subtle); font-size: 0.82rem; color: var(--text-muted); text-align: center;">
          <div><strong>MSAI Assistant</strong> by <strong>Nvisov</strong></div>
          <div style="margin-top: 4px;">Version 1.0.0 Commercial Edition</div>
        </div>

      </div>
      <div class="modal-footer">
        <button id="btn-save-settings" class="btn-primary" data-i18n="settings.saveSettings">Save Settings</button>
      </div>
    `;

    window.MSAI.Modals.show(modalContent, (modalEl) => {
      // Swatch selection
      modalEl.querySelectorAll('.color-swatch-card').forEach(card => {
        card.addEventListener('click', () => {
          modalEl.querySelectorAll('.color-swatch-card').forEach(c => c.classList.remove('active'));
          card.classList.add('active');
          const color = card.getAttribute('data-color');
          window.MSAI.Themes.setAccent(color);
        });
      });

      // Theme toggle buttons
      modalEl.querySelectorAll('.theme-btn').forEach(btn => {
        btn.addEventListener('click', () => {
          const theme = btn.getAttribute('data-theme');
          window.MSAI.Themes.setTheme(theme);
          modalEl.querySelectorAll('.theme-btn').forEach(b => b.classList.remove('btn-primary'));
          btn.classList.add('btn-primary');
        });
      });

      // Language selector
      const langSelect = modalEl.querySelector('#setting-language-select');
      if (langSelect) {
        langSelect.addEventListener('change', (e) => {
          window.MSAI.Language.setLanguage(e.target.value);
        });
      }

      // Clear history
      const clearBtn = modalEl.querySelector('#btn-clear-history');
      if (clearBtn) {
        clearBtn.addEventListener('click', () => {
          if (confirm('Are you sure you want to clear all chat history?')) {
            window.MSAI.History.clearAll();
            window.MSAI.Modals.close();
          }
        });
      }

      // Save settings
      const saveBtn = modalEl.querySelector('#btn-save-settings');
      if (saveBtn) {
        saveBtn.addEventListener('click', () => {
          const apiKeyInput = modalEl.querySelector('#setting-api-key');
          if (apiKeyInput) {
            window.MSAI.Storage.set('msai_api_key_v1', apiKeyInput.value.trim());
          }
          window.MSAI.Notifications.show(window.MSAI.Language.get('messages.settingsSaved', 'Settings saved.'));
          window.MSAI.Modals.close();
        });
      }
    });
  }
};
