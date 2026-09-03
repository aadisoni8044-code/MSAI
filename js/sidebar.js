import { conversationManager } from './conversations.js';

export function renderSidebar(onSelectChat) {
  const pinnedList = document.getElementById('pinned-chat-list');
  const recentList = document.getElementById('recent-chat-list');

  if (!pinnedList || !recentList) return;

  pinnedList.innerHTML = '';
  recentList.innerHTML = '';

  const conversations = conversationManager.getConversations();
  const activeConv = conversationManager.getActiveConversation();

  conversations.forEach(conv => {
    const item = document.createElement('div');
    item.className = `chat-item ${activeConv && activeConv.id === conv.id ? 'active' : ''}`;

    const titleSpan = document.createElement('span');
    titleSpan.className = 'chat-item-title';
    titleSpan.textContent = conv.title;

    const actionsDiv = document.createElement('div');
    actionsDiv.className = 'chat-item-actions';

    const pinBtn = document.createElement('button');
    pinBtn.className = 'btn-pin-chat';
    pinBtn.title = conv.pinned ? 'Unpin chat' : 'Pin chat';
    pinBtn.textContent = conv.pinned ? '📌' : '📍';
    pinBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      conversationManager.togglePin(conv.id);
      renderSidebar(onSelectChat);
    });

    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'btn-delete-chat';
    deleteBtn.title = 'Delete chat';
    deleteBtn.textContent = '🗑️';
    deleteBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      conversationManager.deleteConversation(conv.id);
      if (onSelectChat) onSelectChat();
    });

    actionsDiv.appendChild(pinBtn);
    actionsDiv.appendChild(deleteBtn);

    item.appendChild(titleSpan);
    item.appendChild(actionsDiv);

    item.addEventListener('click', () => {
      conversationManager.setActiveConversation(conv.id);
      if (onSelectChat) onSelectChat();
    });

    if (conv.pinned) {
      pinnedList.appendChild(item);
    } else {
      recentList.appendChild(item);
    }
  });
}