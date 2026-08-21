/**
 * Settings Manager Module
 * Synchronizes user preference inputs with localStorage/CONFIG.
 */

import { getAppConfig, updateAppConfig } from './config.js';

export class SettingsManager {
    constructor() {
        this.config = getAppConfig();
    }

    loadIntoForm() {
        this.config = getAppConfig();
        const apiKeyInput = document.getElementById("setting-api-key");
        const modelSelect = document.getElementById("setting-model");
        const tempInput = document.getElementById("setting-temperature");
        const tempDisplay = document.getElementById("temp-val-display");
        const enterSendCheckbox = document.getElementById("setting-enter-send");

        if (apiKeyInput) {
            apiKeyInput.value = this.config.GEMINI_API_KEY === "YOUR_GOOGLE_GEMINI_API_KEY" ? "" : this.config.GEMINI_API_KEY;
        }
        if (modelSelect) {
            modelSelect.value = this.config.MODEL;
        }
        if (tempInput) {
            tempInput.value = this.config.TEMPERATURE;
        }
        if (tempDisplay) {
            tempDisplay.textContent = this.config.TEMPERATURE;
        }
        if (enterSendCheckbox) {
            enterSendCheckbox.checked = this.config.ENTER_TO_SEND;
        }
    }

    saveFromForm() {
        const apiKeyInput = document.getElementById("setting-api-key");
        const modelSelect = document.getElementById("setting-model");
        const tempInput = document.getElementById("setting-temperature");
        const enterSendCheckbox = document.getElementById("setting-enter-send");

        const newConfig = {
            GEMINI_API_KEY: apiKeyInput ? apiKeyInput.value.trim() : "",
            MODEL: modelSelect ? modelSelect.value : "gemini-2.5-flash",
            TEMPERATURE: tempInput ? parseFloat(tempInput.value) : 0.7,
            ENTER_TO_SEND: enterSendCheckbox ? enterSendCheckbox.checked : true
        };

        updateAppConfig(newConfig);

        // Update top model badge display
        const badgeText = document.getElementById("current-model-name");
        if (badgeText) {
            badgeText.textContent = newConfig.MODEL;
        }

        return newConfig;
    }
}

export const settings = new SettingsManager();
