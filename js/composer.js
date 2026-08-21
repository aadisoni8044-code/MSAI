/**
 * MSAI - Composer Input Controller
 */

import { attachmentManager } from "./attachments.js";
import { voiceService } from "./voice.js";
import { estimateTokens } from "./utils.js";
import { storage } from "./storage.js";
import { CONFIG } from "./config.js";

export class Composer {
  constructor() {
    this.textarea = null;
    this.sendBtn = null;
    this.stopBtn = null;
    this.fileInput = null;
    this.attachBtn = null;
    this.micBtn = null;
    this.tokenCounter = null;
    this.modePills = null;
    this.onSendCallback = null;
    this.onStopCallback = null;
  }

  init({
    textarea,
    sendBtn,
    stopBtn,
    fileInput,
    attachBtn,
    micBtn,
    tokenCounter,
    onSend,
    onStop,
  }) {
    this.textarea = textarea;
    this.sendBtn = sendBtn;
    this.stopBtn = stopBtn;
    this.fileInput = fileInput;
    this.attachBtn = attachBtn;
    this.micBtn = micBtn;
    this.tokenCounter = tokenCounter;
    this.onSendCallback = onSend;
    this.onStopCallback = onStop;

    this.bindEvents();
    this.updateSendButtonState();
  }

  bindEvents() {
    if (!this.textarea) return;

    // Auto resize textarea
    this.textarea.addEventListener("input", () => {
      this.autoResize();
      this.updateSendButtonState();
      this.updateTokenCounter();
    });

    // Keydown handlers (Enter vs Shift+Enter)
    this.textarea.addEventListener("keydown", (e) => {
      const settings = storage.getSettings();
      if (e.key === "Enter" && !e.shiftKey) {
        if (settings.enterToSend !== false) {
          e.preventDefault();
          this.handleSend();
        }
      }
    });

    // Send button click
    this.sendBtn?.addEventListener("click", () => this.handleSend());

    // Stop button click
    this.stopBtn?.addEventListener("click", () => {
      if (this.onStopCallback) this.onStopCallback();
    });

    // Attachment file input trigger
    this.attachBtn?.addEventListener("click", () => {
      this.fileInput?.click();
    });

    this.fileInput?.addEventListener("change", (e) => {
      if (e.target.files && e.target.files.length > 0) {
        attachmentManager.handleFiles(e.target.files);
        this.fileInput.value = "";
      }
    });

    // Voice recognition toggle
    this.micBtn?.addEventListener("click", () => {
      voiceService.toggleListening((transcript, isFinal) => {
        if (this.textarea) {
          const current = this.textarea.value;
          this.textarea.value = current ? `${current} ${transcript}` : transcript;
          this.autoResize();
          this.updateSendButtonState();
          this.updateTokenCounter();
          this.textarea.focus();
        }
      });
    });

    // Drag and drop support directly on textarea and container
    const composerBox = this.textarea.closest(".composer-container") || this.textarea;
    composerBox.addEventListener("dragover", (e) => {
      e.preventDefault();
      composerBox.classList.add("drag-active");
    });
    composerBox.addEventListener("dragleave", (e) => {
      e.preventDefault();
      composerBox.classList.remove("drag-active");
    });
    composerBox.addEventListener("drop", (e) => {
      e.preventDefault();
      composerBox.classList.remove("drag-active");
      if (e.dataTransfer && e.dataTransfer.files) {
        attachmentManager.handleFiles(e.dataTransfer.files);
      }
    });

    // Clipboard paste support for images
    this.textarea.addEventListener("paste", (e) => {
      const items = e.clipboardData?.items;
      if (!items) return;

      const imageFiles = [];
      for (const item of items) {
        if (item.type.startsWith("image/")) {
          const file = item.getAsFile();
          if (file) imageFiles.push(file);
        }
      }

      if (imageFiles.length > 0) {
        attachmentManager.handleFiles(imageFiles);
      }
    });
  }

  autoResize() {
    if (!this.textarea) return;
    this.textarea.style.height = "auto";
    const newHeight = Math.min(this.textarea.scrollHeight, 220);
    this.textarea.style.height = `${Math.max(48, newHeight)}px`;
  }

  updateSendButtonState() {
    const text = this.textarea?.value?.trim() || "";
    const attachments = attachmentManager.getAttachments();
    const canSend = text.length > 0 || attachments.length > 0;

    if (this.sendBtn) {
      this.sendBtn.disabled = !canSend;
      if (canSend) {
        this.sendBtn.classList.add("active");
      } else {
        this.sendBtn.classList.remove("active");
      }
    }
  }

  updateTokenCounter() {
    if (!this.tokenCounter) return;
    const text = this.textarea?.value || "";
    const tokens = estimateTokens(text);
    this.tokenCounter.textContent = tokens > 0 ? `~${tokens} tokens` : "";
  }

  handleSend() {
    const text = this.textarea?.value?.trim() || "";
    const attachments = attachmentManager.getAttachments();

    if (!text && attachments.length === 0) return;

    if (this.onSendCallback) {
      this.onSendCallback(text, attachments);
    }

    this.clear();
  }

  clear() {
    if (this.textarea) {
      this.textarea.value = "";
      this.autoResize();
    }
    attachmentManager.clear();
    this.updateSendButtonState();
    this.updateTokenCounter();
  }

  setPrompt(promptText, autoSend = false) {
    if (this.textarea) {
      this.textarea.value = promptText;
      this.autoResize();
      this.updateSendButtonState();
      this.updateTokenCounter();
      this.textarea.focus();
      if (autoSend) {
        this.handleSend();
      }
    }
  }

  setGenerating(isGenerating) {
    if (isGenerating) {
      if (this.sendBtn) this.sendBtn.style.display = "none";
      if (this.stopBtn) this.stopBtn.style.display = "flex";
    } else {
      if (this.sendBtn) this.sendBtn.style.display = "flex";
      if (this.stopBtn) this.stopBtn.style.display = "none";
      this.updateSendButtonState();
    }
  }
}

export const composer = new Composer();
