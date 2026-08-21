import { storage } from './storage.js';
import { themeManager } from './theme.js';
import { conversationManager } from './conversations.js';
import { toast } from './toast.js';
import { CONFIG } from './config.js';

/**
 * Settings Modal and Configuration Manager
 */
export class SettingsManager {
    constructor() {
        this.modalBackdrop = null;
        this.themeSelect = null;
        this.enterSendCheckbox = null;
        this.autoScrollCheckbox = null;
        this.modelSelect = null;
        this.apiKeyInput = null;
        this.saveBtn = null;
        this.exportBtn = null;
        this.clearAllBtn = null;
        this.activeModelLabel = null;
        this.onSettingsSavedCallback = null;
    }

    init({ onSettingsSaved }) {
        this.onSettingsSavedCallback = onSettingsSaved;

        this.modalBackdrop = document.getElementById('settings-modal');
        this.themeSelect = document.getElementById('setting-theme-select');
        this.enterSendCheckbox = document.getElementById('setting-enter-send');
        this.autoScrollCheckbox = document.getElementById('setting-auto-scroll');
        this.modelSelect = document.getElementById('setting-model-select');
        this.apiKeyInput = document.getElementById('setting-api-key-input');
        this.saveBtn = document.getElementById('save-settings-btn');
        this.exportBtn = document.getElementById('export-chats-btn');
        this.clearAllBtn = document.getElementById('clear-all-chats-btn');
        this.activeModelLabel = document.getElementById('active-model-name');

        const openBtn = document.getElementById('open-settings-btn');
        const headerApiKeyBtn = document.getElementById('header-api-key-btn');
        const closeBtns = this.modalBackdrop?.querySelectorAll('.close-modal-btn');

        if (openBtn) {
            openBtn.addEventListener('click', () => this.openModal());
        }

        if (headerApiKeyBtn) {
            headerApiKeyBtn.addEventListener('click', () => this.openModal());
        }

        if (closeBtns) {
            closeBtns.forEach(btn => btn.addEventListener('click', () => this.closeModal()));
        }

        if (this.modalBackdrop) {
            this.modalBackdrop.addEventListener('click', (e) => {
                if (e.target === this.modalBackdrop) this.closeModal();
            });
        }

        if (this.saveBtn) {
            this.saveBtn.addEventListener('click', () => this.saveSettings());
        }

        if (this.exportBtn) {
            this.exportBtn.addEventListener('click', () => this.exportData());
        }

        if (this.clearAllBtn) {
            this.clearAllBtn.addEventListener('click', () => this.clearAllData());
        }

        this.loadSettingsIntoUI();
    }

    openModal() {
        this.loadSettingsIntoUI();
        this.modalBackdrop.classList.add('active');
    }

    closeModal() {
        this.modalBackdrop.classList.remove('active');
    }

    loadSettingsIntoUI() {
        if (this.themeSelect) this.themeSelect.value = storage.getSetting('theme', 'dark');
        if (this.enterSendCheckbox) this.enterSendCheckbox.checked = storage.getSetting('enter_send', true);
        if (this.autoScrollCheckbox) this.autoScrollCheckbox.checked = storage.getSetting('auto_scroll', true);

        const currentModel = storage.getSetting('model', CONFIG.DEFAULT_MODEL);
        if (this.modelSelect) this.modelSelect.value = currentModel;
        if (this.activeModelLabel) {
            this.activeModelLabel.textContent = currentModel === 'gemini-2.5-pro' ? 'Gemini 2.5 Pro' : 'Gemini 2.5 Flash';
        }

        if (this.apiKeyInput) this.apiKeyInput.value = storage.getSetting('api_key', '');
    }

    saveSettings() {
        if (this.themeSelect) themeManager.setTheme(this.themeSelect.value);
        if (this.enterSendCheckbox) storage.setSetting('enter_send', this.enterSendCheckbox.checked);
        if (this.autoScrollCheckbox) storage.setSetting('auto_scroll', this.autoScrollCheckbox.checked);

        if (this.modelSelect) {
            const selectedModel = this.modelSelect.value;
            storage.setSetting('model', selectedModel);
            if (this.activeModelLabel) {
                this.activeModelLabel.textContent = selectedModel === 'gemini-2.5-pro' ? 'Gemini 2.5 Pro' : 'Gemini 2.5 Flash';
            }
        }

        if (this.apiKeyInput) {
            storage.setSetting('api_key', this.apiKeyInput.value.trim());
        }

        toast.show('Settings saved successfully', 'success');
        this.closeModal();

        if (this.onSettingsSavedCallback) {
            this.onSettingsSavedCallback();
        }
    }

    async exportData() {
        const conversations = await conversationManager.getConversations();
        const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(conversations, null, 2));
        const downloadAnchor = document.createElement('a');
        downloadAnchor.setAttribute("href", dataStr);
        downloadAnchor.setAttribute("download", `MSAI_Export_${new Date().toISOString().slice(0, 10)}.json`);
        document.body.appendChild(downloadAnchor);
        downloadAnchor.click();
        downloadAnchor.remove();
        toast.show('Conversations exported successfully', 'success');
    }

    async clearAllData() {
        if (confirm('Are you sure you want to permanently delete ALL conversations? This action cannot be undone.')) {
            await conversationManager.clearAllConversations();
            toast.show('All conversations deleted', 'info');
            this.closeModal();
            if (this.onSettingsSavedCallback) {
                this.onSettingsSavedCallback();
            }
        }
    }
}

export const settingsManager = new SettingsManager();
