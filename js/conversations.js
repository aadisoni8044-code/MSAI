import { storage } from './storage.js';
import { generateId } from './utils.js';

class ConversationManager {
  constructor() {
    this.conversations = storage.get('conversations', []);
    this.activeId = storage.get('active_conv_id', null);
  }

  getConversations() {
    return this.conversations;
  }

  getConversation(id) {
    return this.conversations.find(c => c.id === id);
  }

  getActiveConversation() {
    return this.getConversation(this.activeId);
  }

  setActiveConversation(id) {
    this.activeId = id;
    storage.set('active_conv_id', id);
  }

  createConversation(title = 'New Conversation') {
    const newConv = {
      id: generateId(),
      title,
      pinned: false,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      messages: []
    };
    this.conversations.unshift(newConv);
    this.save();
    this.setActiveConversation(newConv.id);
    return newConv;
  }

  addMessage(convId, role, content) {
    const conv = this.getConversation(convId);
    if (!conv) return null;

    const msg = {
      id: 'msg_' + Date.now().toString(36),
      role,
      content,
      timestamp: Date.now()
    };

    conv.messages.push(msg);
    conv.updatedAt = Date.now();

    if (conv.messages.length === 1 && role === 'user') {
      conv.title = content.slice(0, 30) + (content.length > 30 ? '...' : '');
    }

    this.save();
    return msg;
  }

  togglePin(id) {
    const conv = this.getConversation(id);
    if (conv) {
      conv.pinned = !conv.pinned;
      this.save();
    }
  }

  renameConversation(id, newTitle) {
    const conv = this.getConversation(id);
    if (conv && newTitle.trim()) {
      conv.title = newTitle.trim();
      this.save();
    }
  }

  deleteConversation(id) {
    this.conversations = this.conversations.filter(c => c.id !== id);
    if (this.activeId === id) {
      this.activeId = this.conversations[0]?.id || null;
      storage.set('active_conv_id', this.activeId);
    }
    this.save();
  }

  clearAll() {
    this.conversations = [];
    this.activeId = null;
    storage.set('active_conv_id', null);
    this.save();
  }

  save() {
    storage.set('conversations', this.conversations);
  }
}

export const conversationManager = new ConversationManager();