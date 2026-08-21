/**
 * MSAI - Main Application Bootstrapper
 */

import { themeManager } from "./theme.js";
import { storage } from "./storage.js";
import { conversationManager } from "./conversations.js";
import { sidebar } from "./sidebar.js";
import { renderer } from "./renderer.js";
import { composer } from "./composer.js";
import { settingsModal } from "./settings.js";
import { ui } from "./ui.js";
import { chatController } from "./chat.js";
import { shortcutsManager } from "./shortcuts.js";
import { api } from "./api.js";
import { toast } from "./toast.js";

class App {
  async init() {
    console.log("Initializing MSAI Intelligent Web App...");

    // 1. Initialize Theme
    themeManager.init();

    // 2. Initialize Core DOM Elements
    const chatContainer = document.getElementById("main-chat-scroll-container");
    const messagesListEl = document.getElementById("chat-messages-list");
    const welcomeScreenEl = document.getElementById("msai-welcome-screen");

    renderer.init({
      chatContainer,
      messagesListEl,
      welcomeScreenEl,
    });

    // 3. Initialize Sidebar
    sidebar.init({
      sidebarEl: document.getElementById("msai-sidebar"),
      historyListEl: document.getElementById("sidebar-history-list"),
      chatCountBadgeEl: document.getElementById("sidebar-chat-count-badge"),
      onSelectChat: async (chatId) => {
        await conversationManager.loadConversation(chatId);
      },
      onNewChat: () => {
        conversationManager.createNewConversation();
      },
    });

    // 4. Initialize Composer
    composer.init({
      textarea: document.getElementById("composer-textarea"),
      sendBtn: document.getElementById("composer-send-btn"),
      stopBtn: document.getElementById("composer-stop-btn"),
      fileInput: document.getElementById("composer-file-input"),
      attachBtn: document.getElementById("composer-attach-btn"),
      micBtn: document.getElementById("composer-mic-btn"),
      tokenCounter: document.getElementById("composer-token-counter"),
      onSend: (prompt, attachments) => {
        chatController.handleSendMessage(prompt, attachments);
      },
      onStop: () => {
        chatController.handleStop();
      },
    });

    // 5. Initialize Settings & UI Modals
    settingsModal.init({
      modalEl: document.getElementById("settings-modal"),
    });

    ui.init({
      searchModalEl: document.getElementById("search-modal"),
      shortcutsModalEl: document.getElementById("shortcuts-modal"),
      artifactsDrawerEl: document.getElementById("artifacts-drawer"),
    });

    // 6. Initialize Chat Controller
    chatController.init();

    // 7. Bind Suggestions Cards on Welcome Screen
    this.bindWelcomeSuggestions();

    // 8. Bind Keyboard Shortcuts
    shortcutsManager.init({
      onSearch: () => ui.openSearch(),
      onNewChat: () => conversationManager.createNewConversation(),
      onToggleSidebar: () => sidebar.toggleCollapse(),
      onOpenSettings: () => settingsModal.open(),
      onOpenShortcuts: () => ui.openShortcuts(),
      onEscape: () => {
        ui.closeAllModals();
        settingsModal.close();
        sidebar.closeMobile();
      },
    });

    // 9. Mobile menu toggle button in header
    document.getElementById("mobile-menu-toggle-btn")?.addEventListener("click", () => {
      sidebar.openMobile();
    });

    // 10. Load active conversation or create new
    const activeChatId = storage.getActiveChatId();
    await conversationManager.loadConversation(activeChatId);
    await sidebar.renderConversationList();

    // 11. Health check & status
    this.verifyBackendHealth();

    // 12. Bind theme toggle buttons
    document.querySelectorAll(".theme-toggle-btn").forEach((btn) => {
      btn.addEventListener("click", () => themeManager.toggleTheme());
    });
  }

  bindWelcomeSuggestions() {
    const suggestions = [
      {
        selector: "#suggestion-code",
        prompt: "Write a clean, responsive TypeScript component for a modern dashboard widget with interactive chart and filtering.",
      },
      {
        selector: "#suggestion-write",
        prompt: "Draft a compelling product launch email announcement highlighting key AI features, speed, and benefits.",
      },
      {
        selector: "#suggestion-learn",
        prompt: "Explain how large language models (LLMs) handle multimodal vision and audio tokens in simple terms.",
      },
      {
        selector: "#suggestion-life",
        prompt: "Help me design a productive weekly routine balancing deep focus work, health, and learning new skills.",
      },
      {
        selector: "#suggestion-choice",
        prompt: "Analyze the latest trends in autonomous AI agents and explain what makes them powerful.",
      },
    ];

    suggestions.forEach(({ selector, prompt }) => {
      const el = document.querySelector(selector);
      el?.addEventListener("click", () => {
        composer.setPrompt(prompt, true);
      });
    });
  }

  async verifyBackendHealth() {
    const health = await api.checkHealth();
    console.log("MSAI Health Status:", health);

    const statusBadge = document.getElementById("header-status-badge");
    if (statusBadge) {
      if (health.hasServerKey) {
        statusBadge.textContent = "AI Connected";
        statusBadge.className = "status-pill status-online";
      } else {
        statusBadge.textContent = "Custom Key Ready";
        statusBadge.className = "status-pill status-ready";
      }
    }
  }
}

// Start app when DOM ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    new App().init();
  });
} else {
  new App().init();
}
