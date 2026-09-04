/**
 * Global Keyboard Shortcuts
 */
import { modalManager } from './modal.js';
import { conversations } from './conversations.js';

export function setupKeyboardShortcuts() {
  window.addEventListener('keydown', (e) => {
    // Cmd+K or Ctrl+K -> Search modal
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      modalManager.open('searchModal');
      const searchInput = document.getElementById('conversationSearchInput');
      if (searchInput) searchInput.focus();
    }

    // Alt+N or Cmd+Shift+O -> New Chat
    if (e.altKey && e.key.toLowerCase() === 'n') {
      e.preventDefault();
      conversations.create('New Chat');
    }
  });

  // Top header shortcuts button opens shortcut guide modal
  const btnShortcuts = document.getElementById('btnKeyboardShortcuts');
  if (btnShortcuts) {
    btnShortcuts.addEventListener('click', () => {
      modalManager.open('shortcutsModal');
    });
  }
}
