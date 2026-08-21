/**
 * MSAI - Conversation Management Core
 */

import { generateId } from "./utils.js";
import { storage } from "./storage.js";
import { CONFIG } from "./config.js";

class ConversationManager {
  constructor() {
    this.currentConversation = null;
    this.listeners = [];
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter((l) => l !== listener);
    };
  }

  notify(event, data) {
    this.listeners.forEach((l) => l(event, data));
  }

  getCurrentConversation() {
    return this.currentConversation;
  }

  async createNewConversation(initialTitle = "New Conversation", model = null) {
    const settings = storage.getSettings();
    const newConv = {
      id: generateId(),
      title: initialTitle,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      model: model || settings.model || CONFIG.DEFAULT_MODEL,
      systemPrompt: settings.systemPrompt || CONFIG.DEFAULT_SYSTEM_PROMPT,
      pinned: false,
      messages: [],
    };

    this.currentConversation = newConv;
    storage.setActiveChatId(newConv.id);
    await storage.saveConversation(newConv);
    this.notify("conversation:created", newConv);
    return newConv;
  }

  async loadConversation(id) {
    if (!id) {
      return await this.createNewConversation();
    }

    const conv = await storage.getConversationById(id);
    if (conv) {
      this.currentConversation = conv;
      storage.setActiveChatId(conv.id);
      this.notify("conversation:loaded", conv);
      return conv;
    } else {
      return await this.createNewConversation();
    }
  }

  async addMessage(role, content, attachments = [], metadata = {}) {
    if (!this.currentConversation) {
      await this.createNewConversation();
    }

    const message = {
      id: generateId(),
      role, // 'user' | 'assistant' | 'system'
      content,
      attachments: attachments || [],
      timestamp: new Date().toISOString(),
      metadata: metadata || {},
    };

    this.currentConversation.messages.push(message);
    this.currentConversation.updatedAt = new Date().toISOString();

    await storage.saveConversation(this.currentConversation);
    this.notify("message:added", { message, conversation: this.currentConversation });
    return message;
  }

  async updateMessageContent(messageId, newContent, isStreaming = false) {
    if (!this.currentConversation) return;

    const msg = this.currentConversation.messages.find((m) => m.id === messageId);
    if (msg) {
      msg.content = newContent;
      if (!isStreaming) {
        this.currentConversation.updatedAt = new Date().toISOString();
        await storage.saveConversation(this.currentConversation);
      }
      this.notify("message:updated", { message: msg, isStreaming });
    }
  }

  async finishStreaming(messageId) {
    if (!this.currentConversation) return;
    const msg = this.currentConversation.messages.find((m) => m.id === messageId);
    if (msg) {
      this.currentConversation.updatedAt = new Date().toISOString();
      await storage.saveConversation(this.currentConversation);
      this.notify("message:stream_finished", { message: msg, conversation: this.currentConversation });
    }
  }

  async updateTitle(newTitle) {
    if (!this.currentConversation || !newTitle) return;
    this.currentConversation.title = newTitle.trim();
    this.currentConversation.updatedAt = new Date().toISOString();
    await storage.saveConversation(this.currentConversation);
    this.notify("conversation:updated", this.currentConversation);
  }

  async togglePin(id) {
    const conv = id === this.currentConversation?.id ? this.currentConversation : await storage.getConversationById(id);
    if (conv) {
      conv.pinned = !conv.pinned;
      await storage.saveConversation(conv);
      this.notify("conversation:updated", conv);
    }
  }

  async deleteConversation(id) {
    if (!id) return;
    const wasActive = this.currentConversation && this.currentConversation.id === id;

    await storage.deleteConversation(id);

    if (wasActive) {
      this.currentConversation = null;
      storage.setActiveChatId(null);

      const remaining = await storage.getAllConversations();
      if (remaining.length > 0) {
        await this.loadConversation(remaining[0].id);
      } else {
        await this.createNewConversation();
      }
    }

    this.notify("conversation:deleted", { id });
  }

  async deleteMessage(messageId) {
    if (!this.currentConversation) return;
    this.currentConversation.messages = this.currentConversation.messages.filter((m) => m.id !== messageId);
    this.currentConversation.updatedAt = new Date().toISOString();
    await storage.saveConversation(this.currentConversation);
    this.notify("conversation:loaded", this.currentConversation);
  }

  // Get messages formatted for Gemini API context
  getHistoryForAPI() {
    if (!this.currentConversation || !this.currentConversation.messages) return [];
    return this.currentConversation.messages
      .filter((msg) => (msg.role === "user" || msg.role === "assistant") && !msg.isError)
      .slice(-CONFIG.MAX_HISTORY_MESSAGES)
      .map((msg) => {
        let cleanText = msg.content || "";
        if (cleanText.includes("<button") || cleanText.includes("retry-msg-btn")) {
          cleanText = cleanText.replace(/<button[\s\S]*?<\/button>/gi, "").replace(/<[^>]+>/g, "").trim();
        }
        return {
          role: msg.role,
          content: cleanText,
          attachments: msg.attachments,
        };
      });
  }
}

export const conversationManager = new ConversationManager();
