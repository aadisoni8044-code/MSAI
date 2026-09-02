/**
 * MSAI Core App Initialization
 */
window.MSAI = window.MSAI || {};

window.MSAI.App = {
  async init() {
    window.MSAI.State.init();
    await window.MSAI.Language.init();
    window.MSAI.Themes.init();
    window.MSAI.Splash.init();

    this.bindEvents();
  },

  preload() {
    window.MSAI.API.checkStatus();
  },

  onReady() {
    window.MSAI.History.render();
    if (window.MSAI.State.activeConversationId) {
      window.MSAI.Chat.loadConversation(window.MSAI.State.activeConversationId);
    } else {
      window.MSAI.Chat.showHero();
    }
  },

  bindEvents() {
    // Sidebar toggle
    const toggleBtn = document.getElementById('btn-sidebar-toggle');
    const sidebar = document.getElementById('sidebar');
    if (toggleBtn && sidebar) {
      toggleBtn.addEventListener('click', () => {
        sidebar.classList.toggle('open');
      });
    }

    // New chat button
    const newChatBtn = document.getElementById('btn-new-chat');
    if (newChatBtn) {
      newChatBtn.addEventListener('click', () => {
        window.MSAI.History.createNewChat();
      });
    }

    // Open settings buttons
    const openSettingsBtn = document.getElementById('btn-open-settings');
    const topSettingsBtn = document.getElementById('btn-top-settings');
    const designBtn = document.getElementById('btn-design');

    [openSettingsBtn, topSettingsBtn, designBtn].forEach(btn => {
      if (btn) {
        btn.addEventListener('click', () => {
          window.MSAI.Settings.openModal();
        });
      }
    });

    // Prompt Library & Prompt Builder navigation
    const promptLibNav = document.getElementById('nav-prompt-library');
    if (promptLibNav) {
      promptLibNav.addEventListener('click', () => {
        window.MSAI.Prompts.openLibraryModal();
      });
    }

    const promptBuilderNav = document.getElementById('nav-prompt-builder');
    if (promptBuilderNav) {
      promptBuilderNav.addEventListener('click', () => {
        window.MSAI.PromptBuilder.openModal();
      });
    }

    // Search trigger
    const searchBtn = document.getElementById('btn-toggle-search');
    if (searchBtn) {
      searchBtn.addEventListener('click', () => {
        window.MSAI.Search.openModal();
      });
    }
  }
};

document.addEventListener('DOMContentLoaded', () => {
  window.MSAI.App.init();
});
