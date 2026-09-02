/**
 * MSAI Chat History Manager
 */
window.MSAI = window.MSAI || {};

window.MSAI.History = {
  render() {
    const listEl = document.getElementById('chat-history-list');
    const countEl = document.getElementById('chat-count-badge');
    if (!listEl) return;

    listEl.innerHTML = '';
    const conversations = window.MSAI.State.conversations;
    if (countEl) countEl.textContent = conversations.length;

    if (conversations.length === 0) {
      listEl.innerHTML = `
        <div style="padding: 16px 12px; font-size: 0.82rem; color: var(--text-muted); text-align: center;">
          No conversations yet.<br>Start a new chat to begin.
        </div>
      `;
      return;
    }

    conversations.forEach((conv) => {
      const item = document.createElement('div');
      item.className = `chat-item ${conv.id === window.MSAI.State.activeConversationId ? 'active' : ''}`;
      item.innerHTML = `
        <span class="chat-item-title">${window.MSAI.Security.sanitizeHTML(conv.title)}</span>
        <div class="chat-actions">
          <button class="btn-icon btn-delete-chat" style="width: 24px; height: 24px;" title="Delete">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
          </button>
        </div>
      `;

      item.addEventListener('click', (e) => {
        if (e.target.closest('.btn-delete-chat')) {
          e.stopPropagation();
          this.deleteChat(conv.id);
          return;
        }
        window.MSAI.Chat.loadConversation(conv.id);
      });

      listEl.appendChild(item);
    });
  },

  createNewChat() {
    const newConv = {
      id: 'conv_' + Date.now(),
      title: 'New Chat',
      messages: [],
      createdAt: new Date().toISOString()
    };

    window.MSAI.State.conversations.unshift(newConv);
    window.MSAI.State.saveConversations();
    window.MSAI.Chat.loadConversation(newConv.id);
    this.render();
  },

  deleteChat(id) {
    window.MSAI.State.conversations = window.MSAI.State.conversations.filter(c => c.id !== id);
    window.MSAI.State.saveConversations();

    if (window.MSAI.State.activeConversationId === id) {
      const remaining = window.MSAI.State.conversations;
      if (remaining.length > 0) {
        window.MSAI.Chat.loadConversation(remaining[0].id);
      } else {
        window.MSAI.State.setActiveConversation(null);
        window.MSAI.Chat.showHero();
      }
    }

    this.render();
    if (window.MSAI.Notifications) {
      window.MSAI.Notifications.show('Chat deleted');
    }
  },

  clearAll() {
    window.MSAI.State.conversations = [];
    window.MSAI.State.setActiveConversation(null);
    window.MSAI.State.saveConversations();
    this.render();
    window.MSAI.Chat.showHero();
  }
};
