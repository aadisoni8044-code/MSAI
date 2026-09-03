import { themeManager } from './theme.js';
import { languageManager } from './language.js';
import { conversationManager } from './conversations.js';
import { ChatEngine } from './chat.js';
import { renderSidebar } from './sidebar.js';
import { initSettings } from './settings.js';
import { openModal, closeModal, closeAllModals } from './modal.js';
import { setupKeyboardShortcuts } from './keyboard.js';
import { setupGlobalEvents } from './events.js';

document.addEventListener('DOMContentLoaded', async () => {
  themeManager.init();
  await languageManager.init();

  const messagesContainer = document.getElementById('chat-messages');
  const composerInput = document.getElementById('composer-textarea');
  const sendBtn = document.getElementById('btn-send');

  const chatEngine = new ChatEngine(messagesContainer, composerInput, sendBtn);

  const refreshUI = () => {
    const activeConv = conversationManager.getActiveConversation();
    const titleHeader = document.getElementById('current-chat-header-title');
    if (titleHeader) {
      titleHeader.textContent = activeConv ? activeConv.title : 'MSAI Chat';
    }

    renderSidebar(() => {
      chatEngine.renderCurrentChat();
      const current = conversationManager.getActiveConversation();
      if (titleHeader) titleHeader.textContent = current ? current.title : 'MSAI Chat';
    });

    chatEngine.renderCurrentChat();
  };

  initSettings(refreshUI);
  refreshUI();
  setupGlobalEvents(chatEngine, refreshUI);

  // Auto-resize composer textarea
  composerInput.addEventListener('input', () => {
    composerInput.style.height = 'auto';
    composerInput.style.height = composerInput.scrollHeight + 'px';
  });

  composerInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      const val = composerInput.value.trim();
      if (val) chatEngine.sendUserMessage(val);
    }
  });

  sendBtn.addEventListener('click', () => {
    const val = composerInput.value.trim();
    if (val) chatEngine.sendUserMessage(val);
  });

  // New Chat Button
  document.getElementById('btn-new-chat').addEventListener('click', () => {
    conversationManager.createConversation();
    refreshUI();
  });

  // Settings Modal Triggers
  document.getElementById('btn-settings').addEventListener('click', () => openModal('modal-settings'));
  document.querySelectorAll('.btn-close-modal').forEach(b => {
    b.addEventListener('click', closeAllModals);
  });

  // Keyboard Shortcuts
  setupKeyboardShortcuts({
    newChat: () => {
      conversationManager.createConversation();
      refreshUI();
    },
    openSearch: () => openModal('modal-search'),
    closeModals: closeAllModals
  });
});