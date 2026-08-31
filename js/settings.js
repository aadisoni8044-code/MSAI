/**
 * MSAI - Settings Modal & Configuration Controller
 */

import { storage } from "./storage.js";
import { conversationManager } from "./conversations.js";
import { sidebar } from "./sidebar.js";
import { CONFIG } from "./config.js";
import { toast } from "./toast.js";
import { downloadFile } from "./utils.js";
import { themeManager } from "./theme.js";

export class SettingsModal {
  constructor() {
    this.modalEl = null;
    this.isOpen = false;
  }

  init({ modalEl }) {
    this.modalEl = modalEl;
    this.bindEvents();
  }

  bindEvents() {
    if (!this.modalEl) return;

    // Open settings triggers
    document.querySelectorAll(".open-settings-trigger").forEach((btn) => {
      btn.addEventListener("click", () => this.open());
    });

    // Close buttons
    this.modalEl.querySelectorAll(".modal-close-btn").forEach((btn) => {
      btn.addEventListener("click", () => this.close());
    });

    // Backdrop click
    this.modalEl.addEventListener("click", (e) => {
      if (e.target === this.modalEl) {
        this.close();
      }
    });

    // Settings tabs
    const tabBtns = this.modalEl.querySelectorAll(".settings-tab-btn");
    const tabPanes = this.modalEl.querySelectorAll(".settings-tab-pane");

    tabBtns.forEach((btn) => {
      btn.addEventListener("click", () => {
        const targetTab = btn.getAttribute("data-tab");
        tabBtns.forEach((b) => b.classList.remove("active"));
        tabPanes.forEach((p) => p.classList.remove("active"));

        btn.classList.add("active");
        const targetPane = this.modalEl.querySelector(`#tab-pane-${targetTab}`);
        if (targetPane) targetPane.classList.add("active");
      });
    });

    // Temperature slider display
    const tempSlider = this.modalEl.querySelector("#setting-temperature");
    const tempVal = this.modalEl.querySelector("#setting-temperature-val");
    tempSlider?.addEventListener("input", () => {
      if (tempVal) tempVal.textContent = tempSlider.value;
    });

    // Speech speed slider
    const speedSlider = this.modalEl.querySelector("#setting-speech-speed");
    const speedVal = this.modalEl.querySelector("#setting-speech-speed-val");
    speedSlider?.addEventListener("input", () => {
      if (speedVal) speedVal.textContent = `${speedSlider.value}x`;
    });

    // Save settings form & button
    const form = this.modalEl.querySelector("#settings-form");
    form?.addEventListener("submit", (e) => {
      e.preventDefault();
      this.saveFormValues();
    });

    const saveBtn = this.modalEl.querySelector("#settings-save-btn");
    saveBtn?.addEventListener("click", (e) => {
      e.preventDefault();
      this.saveFormValues();
    });

    // Export data
    const exportBtn = this.modalEl.querySelector("#btn-export-all-data");
    exportBtn?.addEventListener("click", async () => {
      const data = await storage.exportAllData();
      const jsonStr = JSON.stringify(data, null, 2);
      downloadFile(jsonStr, `msai_export_${new Date().toISOString().slice(0, 10)}.json`, "application/json");
      toast.success("All conversations and settings exported as JSON!");
    });

    // Import data
    const importInput = this.modalEl.querySelector("#import-file-input");
    const importBtn = this.modalEl.querySelector("#btn-import-data");
    importBtn?.addEventListener("click", () => importInput?.click());

    importInput?.addEventListener("change", async (e) => {
      const file = e.target.files?.[0];
      if (!file) return;

      try {
        const text = await file.text();
        const data = JSON.parse(text);
        await storage.importData(data);
        toast.success("Data imported successfully! Refreshing...");
        setTimeout(() => window.location.reload(), 1000);
      } catch (err) {
        toast.error("Failed to import JSON file. Please verify file format.");
      }
      importInput.value = "";
    });

    // Clear all data
    const clearBtn = this.modalEl.querySelector("#btn-clear-all-data");
    clearBtn?.addEventListener("click", async () => {
      if (confirm("WARNING: This will permanently delete all conversations and messages. Continue?")) {
        await storage.deleteAllConversations();
        conversationManager.createNewConversation();
        await sidebar.renderConversationList();
        toast.success("All chat history wiped.");
        this.close();
      }
    });
  }

  populateForm() {
    if (!this.modalEl) return;
    const settings = storage.getSettings();

    // Model
    const modelSelect = this.modalEl.querySelector("#setting-model");
    if (modelSelect) modelSelect.value = settings.model || CONFIG.DEFAULT_MODEL;

    // System prompt
    const sysPrompt = this.modalEl.querySelector("#setting-system-prompt");
    if (sysPrompt) sysPrompt.value = settings.systemPrompt || CONFIG.DEFAULT_SYSTEM_PROMPT;

    // Temperature
    const tempSlider = this.modalEl.querySelector("#setting-temperature");
    const tempVal = this.modalEl.querySelector("#setting-temperature-val");
    if (tempSlider) {
      tempSlider.value = settings.temperature ?? CONFIG.DEFAULT_TEMPERATURE;
      if (tempVal) tempVal.textContent = tempSlider.value;
    }

    // Enter to send
    const enterSend = this.modalEl.querySelector("#setting-enter-to-send");
    if (enterSend) enterSend.checked = settings.enterToSend !== false;

    // Auto scroll
    const autoScroll = this.modalEl.querySelector("#setting-auto-scroll");
    if (autoScroll) autoScroll.checked = settings.autoScroll !== false;

    // Speech speed
    const speedSlider = this.modalEl.querySelector("#setting-speech-speed");
    const speedVal = this.modalEl.querySelector("#setting-speech-speed-val");
    if (speedSlider) {
      speedSlider.value = settings.speechSpeed || 1.0;
      if (speedVal) speedVal.textContent = `${speedSlider.value}x`;
    }

    // Optional API key override
    const apiKeyInput = this.modalEl.querySelector("#setting-api-key");
    if (apiKeyInput) apiKeyInput.value = settings.apiKey || "";

    // Theme selector
    const themeSelect = this.modalEl.querySelector("#setting-theme");
    if (themeSelect) themeSelect.value = settings.theme || "dark";
  }

  saveFormValues() {
    if (!this.modalEl) return;

    const current = storage.getSettings();
    const modelSelect = this.modalEl.querySelector("#setting-model");
    const sysPrompt = this.modalEl.querySelector("#setting-system-prompt");
    const tempSlider = this.modalEl.querySelector("#setting-temperature");
    const enterSend = this.modalEl.querySelector("#setting-enter-to-send");
    const autoScroll = this.modalEl.querySelector("#setting-auto-scroll");
    const speedSlider = this.modalEl.querySelector("#setting-speech-speed");
    const apiKeyInput = this.modalEl.querySelector("#setting-api-key");
    const themeSelect = this.modalEl.querySelector("#setting-theme");

    const updatedSettings = {
      ...current,
      model: modelSelect ? modelSelect.value : current.model,
      systemPrompt: sysPrompt ? sysPrompt.value : current.systemPrompt,
      temperature: tempSlider ? parseFloat(tempSlider.value) : current.temperature,
      enterToSend: enterSend ? enterSend.checked : current.enterToSend,
      autoScroll: autoScroll ? autoScroll.checked : current.autoScroll,
      speechSpeed: speedSlider ? parseFloat(speedSlider.value) : current.speechSpeed,
      apiKey: apiKeyInput ? apiKeyInput.value.trim() : current.apiKey,
      theme: themeSelect ? themeSelect.value : current.theme,
    };

    storage.saveSettings(updatedSettings);

    if (updatedSettings.theme !== current.theme) {
      themeManager.applyTheme(updatedSettings.theme, false);
    }

    toast.success("Settings saved successfully!");
    this.close();
  }

  open() {
    this.populateForm();
    this.isOpen = true;
    this.modalEl?.classList.add("show");
  }

  close() {
    this.isOpen = false;
    this.modalEl?.classList.remove("show");
  }
}

export const settingsModal = new SettingsModal();
