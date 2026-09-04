/**
 * Conversation State Manager
 * Handles local persistence of conversations and messages in LocalStorage
 */
import { storage } from './storage.js';
import { generateId } from './utils.js';
import { events } from './events.js';

class ConversationManager {
  constructor() {
    this.STORAGE_KEY = 'msai_conversations';
    this.ACTIVE_CHAT_KEY = 'msai_active_chat';
    this.conversations = [];
    this.activeId = null;
  }

  init() {
    this.conversations = storage.get(this.STORAGE_KEY, []);
    this.activeId = storage.get(this.ACTIVE_CHAT_KEY, null);

    // Verify activeId is still valid
    if (this.activeId && !this.conversations.find(c => c.id === this.activeId)) {
      this.activeId = null;
    }
    return this.conversations;
  }

  save() {
    storage.set(this.STORAGE_KEY, this.conversations);
    storage.set(this.ACTIVE_CHAT_KEY, this.activeId);
    events.emit('conversations:updated', this.conversations);
  }

  getAll() {
    return this.conversations;
  }

  getActive() {
    return this.conversations.find(c => c.id === this.activeId) || null;
  }

  setActive(id) {
    this.activeId = id;
    storage.set(this.ACTIVE_CHAT_KEY, id);
    events.emit('conversation:active-changed', this.getActive());
  }

  create(firstMessageTitle = 'New Chat') {
    const newChat = {
      id: generateId(),
      title: firstMessageTitle,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      pinned: false,
      messages: []
    };

    this.conversations.unshift(newChat);
    this.activeId = newChat.id;
    this.save();
    events.emit('conversation:created', newChat);
    return newChat;
  }

  rename(id, newTitle) {
    const chat = this.conversations.find(c => c.id === id);
    if (chat && newTitle.trim()) {
      chat.title = newTitle.trim();
      chat.updatedAt = Date.now();
      this.save();
      events.emit('conversation:renamed', chat);
    }
  }

  delete(id) {
    const index = this.conversations.findIndex(c => c.id === id);
    if (index !== -1) {
      this.conversations.splice(index, 1);
      if (this.activeId === id) {
        this.activeId = this.conversations[0]?.id || null;
      }
      this.save();
      events.emit('conversation:deleted', id);
    }
  }

  togglePin(id) {
    const chat = this.conversations.find(c => c.id === id);
    if (chat) {
      chat.pinned = !chat.pinned;
      this.save();
      events.emit('conversation:pinned', chat);
    }
  }

  addMessage(chatId, role, content) {
    let chat = this.conversations.find(c => c.id === chatId);
    if (!chat) {
      chat = this.create(content.slice(0, 32));
    }

    const message = {
      id: generateId(),
      role, // 'user' or 'assistant'
      content,
      timestamp: Date.now()
    };

    chat.messages.push(message);
    chat.updatedAt = Date.now();

    // Auto-update title if it was first user message
    if (chat.messages.length === 1 && role === 'user') {
      chat.title = content.slice(0, 36) + (content.length > 36 ? '...' : '');
    }

    this.save();
    events.emit('message:added', { chatId, message });
    return message;
  }

  updateMessage(chatId, messageId, newContent) {
    const chat = this.conversations.find(c => c.id === chatId);
    if (!chat) return null;
    const msg = chat.messages.find(m => m.id === messageId);
    if (msg) {
      msg.content = newContent;
      msg.editedAt = Date.now();
      chat.updatedAt = Date.now();
      this.save();
      events.emit('message:updated', { chatId, message: msg });
      return msg;
    }
    return null;
  }

  deleteMessage(chatId, messageId) {
    const chat = this.conversations.find(c => c.id === chatId);
    if (!chat) return;
    chat.messages = chat.messages.filter(m => m.id !== messageId);
    chat.updatedAt = Date.now();
    this.save();
    events.emit('message:deleted', { chatId, messageId });
  }

  clearAll() {
    this.conversations = [];
    this.activeId = null;
    this.save();
    events.emit('conversations:cleared');
  }
}

export const conversations = new ConversationManager();
