import { conversationManager } from './conversations.js';
import { searchConversations } from './search.js';
import { showNotification } from './notifications.js';
import { openModal, closeModal } from './modal.js';

export function setupGlobalEvents(chatEngine, refreshUI) {
  // Delegate message action buttons inside chat container
  const chatMessages = document.getElementById('chat-messages');
  if (chatMessages) {
    chatMessages.addEventListener('click', (e) => {
      const copyBtn = e.target.closest('.btn-msg-copy');
      const editBtn = e.target.closest('.btn-msg-edit');
      const deleteBtn = e.target.closest('.btn-msg-delete');
      const retryBtn = e.target.closest('.btn-msg-retry');
      const likeBtn = e.target.closest('.btn-msg-like');
      const dislikeBtn = e.target.closest('.btn-msg-dislike');
      const shareBtn = e.target.closest('.btn-msg-share');

      const msgRow = e.target.closest('.message-row');
      const msgId = msgRow ? msgRow.getAttribute('data-msg-id') : null;
      const activeConv = conversationManager.getActiveConversation();

      if (copyBtn) {
        const text = msgRow.querySelector('.message-content').innerText;
        navigator.clipboard.writeText(text);
        showNotification('Message copied to clipboard', 'success');
      }

      if (editBtn && activeConv && msgId) {
        const msg = activeConv.messages.find(m => m.id === msgId);
        if (msg) {
          const textarea = document.getElementById('composer-textarea');
          textarea.value = msg.content;
          textarea.focus();
          const index = activeConv.messages.findIndex(m => m.id === msgId);
          activeConv.messages = activeConv.messages.slice(0, index);
          conversationManager.save();
          refreshUI();
        }
      }

      if (deleteBtn && activeConv && msgId) {
        activeConv.messages = activeConv.messages.filter(m => m.id !== msgId);
        conversationManager.save();
        refreshUI();
        showNotification('Message deleted', 'info');
      }

      if (retryBtn && activeConv) {
        const lastUserMsg = [...activeConv.messages].reverse().find(m => m.role === 'user');
        if (lastUserMsg) {
          if (activeConv.messages[activeConv.messages.length - 1].role === 'model') {
            activeConv.messages.pop();
          }
          conversationManager.save();
          refreshUI();
          chatEngine.sendUserMessage(lastUserMsg.content);
        }
      }

      if (likeBtn) showNotification('Response liked', 'success');
      if (dislikeBtn) showNotification('Feedback recorded', 'info');
      if (shareBtn) {
        const text = msgRow.querySelector('.message-content').innerText;
        navigator.clipboard.writeText(text);
        showNotification('Response link copied', 'success');
      }
    });
  }

  // Sidebar Collapse Toggle
  const toggleSidebarBtn = document.getElementById('btn-toggle-sidebar');
  const sidebar = document.getElementById('sidebar');
  if (toggleSidebarBtn && sidebar) {
    toggleSidebarBtn.addEventListener('click', () => {
      sidebar.classList.toggle('collapsed');
    });
  }

  // Mobile Drawer Toggle
  const mobileMenuBtn = document.getElementById('btn-mobile-menu');
  const sidebarOverlay = document.getElementById('sidebar-overlay');
  if (mobileMenuBtn && sidebar) {
    mobileMenuBtn.addEventListener('click', () => {
      sidebar.classList.add('open');
      if (sidebarOverlay) sidebarOverlay.classList.add('active');
    });
  }
  if (sidebarOverlay && sidebar) {
    sidebarOverlay.addEventListener('click', () => {
      sidebar.classList.remove('open');
      sidebarOverlay.classList.remove('active');
    });
  }

  // Search Modal Wiring
  const searchTriggerBtn = document.getElementById('btn-search-trigger');
  const searchInput = document.getElementById('search-input');
  const searchResultsList = document.getElementById('search-results-list');

  if (searchTriggerBtn) {
    searchTriggerBtn.addEventListener('click', () => openModal('modal-search'));
  }

  if (searchInput && searchResultsList) {
    searchInput.addEventListener('input', (e) => {
      const query = e.target.value;
      const results = searchConversations(query);
      searchResultsList.innerHTML = '';

      if (results.length === 0) {
        searchResultsList.innerHTML = `<div style="padding:1rem; text-align:center; color:var(--text-muted);">No matching conversations found</div>`;
        return;
      }

      results.forEach(conv => {
        const item = document.createElement('div');
        item.className = 'search-result-item';
        item.innerHTML = `
          <div class="search-result-title">${conv.title}</div>
          <div class="search-result-snippet">${conv.messages[0]?.content.slice(0, 80) || ''}...</div>
        `;
        item.addEventListener('click', () => {
          conversationManager.setActiveConversation(conv.id);
          refreshUI();
          closeModal('modal-search');
        });
        searchResultsList.appendChild(item);
      });
    });
  }
}