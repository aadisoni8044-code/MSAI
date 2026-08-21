/**
 * MSAI - UI Interactivity & Modal Dialogs
 */

import { searchEngine } from "./search.js";
import { storage } from "./storage.js";
import { conversationManager } from "./conversations.js";
import { sidebar } from "./sidebar.js";
import { renderer } from "./renderer.js";
import { toast } from "./toast.js";
import { CONFIG } from "./config.js";

export class UIManager {
  constructor() {
    this.searchModalEl = null;
    this.shortcutsModalEl = null;
    this.artifactsDrawerEl = null;
    this.activeMode = "chat"; // 'chat' | 'cowork'
  }

  init({ searchModalEl, shortcutsModalEl, artifactsDrawerEl }) {
    this.searchModalEl = searchModalEl;
    this.shortcutsModalEl = shortcutsModalEl;
    this.artifactsDrawerEl = artifactsDrawerEl;

    this.bindSearchModal();
    this.bindShortcutsModal();
    this.bindModelSelectDropdown();
    this.bindModePills();
    this.bindSidebarNavPills();
  }

  bindSearchModal() {
    if (!this.searchModalEl) return;

    // Search trigger buttons
    document.querySelectorAll(".search-trigger-btn").forEach((btn) => {
      btn.addEventListener("click", () => this.openSearch());
    });

    // Close button
    this.searchModalEl.querySelector(".modal-close-btn")?.addEventListener("click", () => {
      this.closeSearch();
    });

    // Backdrop click
    this.searchModalEl.addEventListener("click", (e) => {
      if (e.target === this.searchModalEl) this.closeSearch();
    });

    // Search input
    const input = this.searchModalEl.querySelector("#search-conversations-input");
    const resultsContainer = this.searchModalEl.querySelector("#search-results-list");

    input?.addEventListener("input", async () => {
      const query = input.value.trim();
      if (!query) {
        resultsContainer.innerHTML = '<div class="search-empty-prompt">Type to search conversation titles and messages...</div>';
        return;
      }

      const results = await searchEngine.search(query);
      if (results.length === 0) {
        resultsContainer.innerHTML = `<div class="search-no-results">No conversations found matching "<strong>${escapeHtml(query)}</strong>"</div>`;
        return;
      }

      resultsContainer.innerHTML = results
        .map((r) => {
          const title = searchEngine.highlightMatch(r.conversation.title || "Untitled Chat", r.query);
          const snippet = r.matchedSnippet ? `<div class="search-result-snippet">${searchEngine.highlightMatch(r.matchedSnippet, r.query)}</div>` : "";
          const dateStr = new Date(r.conversation.updatedAt).toLocaleDateString();

          return `
            <div class="search-result-card" data-chat-id="${r.conversation.id}">
              <div class="search-result-header">
                <span class="search-result-title">${title}</span>
                <span class="search-result-date">${dateStr}</span>
              </div>
              ${snippet}
            </div>
          `;
        })
        .join("");

      // Bind result click
      resultsContainer.querySelectorAll(".search-result-card").forEach((card) => {
        card.addEventListener("click", async () => {
          const chatId = card.getAttribute("data-chat-id");
          if (chatId) {
            await conversationManager.loadConversation(chatId);
            sidebar.renderConversationList();
            this.closeSearch();
          }
        });
      });
    });
  }

  openSearch() {
    if (!this.searchModalEl) return;
    this.searchModalEl.classList.add("show");
    const input = this.searchModalEl.querySelector("#search-conversations-input");
    if (input) {
      input.value = "";
      input.focus();
      const resultsContainer = this.searchModalEl.querySelector("#search-results-list");
      if (resultsContainer) {
        resultsContainer.innerHTML = '<div class="search-empty-prompt">Type to search conversation titles and messages...</div>';
      }
    }
  }

  closeSearch() {
    this.searchModalEl?.classList.remove("show");
  }

  bindShortcutsModal() {
    if (!this.shortcutsModalEl) return;
    document.querySelectorAll(".shortcuts-trigger-btn").forEach((btn) => {
      btn.addEventListener("click", () => this.openShortcuts());
    });

    this.shortcutsModalEl.querySelector(".modal-close-btn")?.addEventListener("click", () => {
      this.closeShortcuts();
    });

    this.shortcutsModalEl.addEventListener("click", (e) => {
      if (e.target === this.shortcutsModalEl) this.closeShortcuts();
    });
  }

  openShortcuts() {
    this.shortcutsModalEl?.classList.add("show");
  }

  closeShortcuts() {
    this.shortcutsModalEl?.classList.remove("show");
  }

  bindModelSelectDropdown() {
    const selectorButtons = document.querySelectorAll(".model-badge-selector-btn");
    const dropdown = document.getElementById("header-model-dropdown");

    selectorButtons.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        dropdown?.classList.toggle("show");
      });
    });

    document.querySelectorAll(".model-select-option").forEach((opt) => {
      opt.addEventListener("click", () => {
        const modelId = opt.getAttribute("data-model-id");
        if (modelId) {
          const settings = storage.getSettings();
          settings.model = modelId;
          storage.saveSettings(settings);
          this.updateModelDisplay();
          dropdown?.classList.remove("show");
          toast.success(`Model switched to ${opt.querySelector(".model-opt-name")?.textContent || modelId}`);
        }
      });
    });

    document.addEventListener("click", () => {
      dropdown?.classList.remove("show");
    });

    this.updateModelDisplay();
  }

  updateModelDisplay() {
    const settings = storage.getSettings();
    const currentModelId = settings.model || CONFIG.DEFAULT_MODEL;
    const modelObj = CONFIG.MODELS.find((m) => m.id === currentModelId) || CONFIG.MODELS[0];

    document.querySelectorAll(".current-model-name-label").forEach((el) => {
      el.textContent = modelObj.name;
    });

    document.querySelectorAll(".current-model-badge-label").forEach((el) => {
      el.textContent = modelObj.badge || "AI";
    });
  }

  bindModePills() {
    const pills = document.querySelectorAll(".mode-toggle-pill");
    pills.forEach((pill) => {
      pill.addEventListener("click", () => {
        pills.forEach((p) => p.classList.remove("active"));
        pill.classList.add("active");
        this.activeMode = pill.getAttribute("data-mode") || "chat";
        toast.info(`Switched mode to ${this.activeMode.toUpperCase()}`);
      });
    });
  }

  bindSidebarNavPills() {
    // Nav links like Projects, Artifacts, Code, Customize
    document.querySelectorAll(".sidebar-nav-item").forEach((item) => {
      item.addEventListener("click", (e) => {
        const action = item.getAttribute("data-action");
        if (action === "projects") {
          toast.info("Projects workspace feature active. Chats are organized automatically.", 2500);
        } else if (action === "artifacts") {
          this.showArtifactsDrawer();
        } else if (action === "code") {
          toast.info("Code mode active. MSAI will prioritize formatting executable code.", 2000);
        } else if (action === "customize") {
          const btn = document.querySelector(".open-settings-trigger");
          btn?.click();
        }
      });
    });

    // Close artifacts drawer
    document.getElementById("close-artifacts-drawer-btn")?.addEventListener("click", () => {
      this.closeArtifactsDrawer();
    });
  }

  showArtifactsDrawer() {
    const conv = conversationManager.getCurrentConversation();
    const drawer = document.getElementById("artifacts-drawer");
    const container = document.getElementById("artifacts-content-list");
    if (!drawer || !container) return;

    // Collect code snippets and tables from current conversation
    let codeBlocksCount = 0;
    let artifactsHtml = "";

    if (conv && conv.messages) {
      conv.messages.forEach((msg) => {
        const matches = [...msg.content.matchAll(/```([a-zA-Z0-9_-]*)\n([\s\S]*?)```/g)];
        matches.forEach((m) => {
          codeBlocksCount++;
          const lang = m[1] || "text";
          const snippet = m[2].trim();
          artifactsHtml += `
            <div class="artifact-card">
              <div class="artifact-card-header">
                <span class="artifact-badge">${lang.toUpperCase()}</span>
                <span class="artifact-title">Snippet #${codeBlocksCount}</span>
              </div>
              <pre class="artifact-preview"><code>${escapeHtml(snippet.slice(0, 200))}${snippet.length > 200 ? "..." : ""}</code></pre>
            </div>
          `;
        });
      });
    }

    if (codeBlocksCount === 0) {
      container.innerHTML = `
        <div class="empty-artifacts-state">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <polygon points="12 2 2 7 12 12 22 7 12 2"/>
            <polyline points="2 17 12 22 22 17"/>
            <polyline points="2 12 12 17 22 12"/>
          </svg>
          <p>No generated artifacts or code snippets in this conversation yet.</p>
        </div>
      `;
    } else {
      container.innerHTML = artifactsHtml;
    }

    drawer.classList.add("open");
  }

  closeArtifactsDrawer() {
    document.getElementById("artifacts-drawer")?.classList.remove("open");
  }

  closeAllModals() {
    this.closeSearch();
    this.closeShortcuts();
    this.closeArtifactsDrawer();
  }
}

function escapeHtml(str) {
  if (!str) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

export const ui = new UIManager();
