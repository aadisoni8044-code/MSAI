/**
 * Conversations Manager Module
 * Manages active conversation, chat creation, message insertion, editing, title auto-generation, and deletion.
 */

import { storage } from './storage.js';

export class ConversationManager {
    constructor() {
        this.conversations = [];
        this.activeConversationId = null;
        this.onStateChangeCallbacks = [];
    }

    async init() {
        await storage.init();
        this.conversations = await storage.getAllConversations();

        // Restore active conversation ID from session or default to null
        const savedActiveId = sessionStorage.getItem("msai_active_conv_id");
        if (savedActiveId && this.getConversation(savedActiveId)) {
            this.activeConversationId = savedActiveId;
        } else {
            this.activeConversationId = null;
        }
    }

    subscribe(callback) {
        this.onStateChangeCallbacks.push(callback);
    }

    notify() {
        this.onStateChangeCallbacks.forEach(cb => cb(this.conversations, this.getActiveConversation()));
    }

    getActiveConversation() {
        if (!this.activeConversationId) return null;
        return this.conversations.find(c => c.id === this.activeConversationId) || null;
    }

    getConversation(id) {
        return this.conversations.find(c => c.id === id) || null;
    }

    /**
     * Creates a new conversation
     */
    async createNewConversation(title = "New Conversation") {
        const newConv = {
            id: 'conv_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7),
            title: title,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            messages: []
        };

        this.conversations.unshift(newConv);
        this.activeConversationId = newConv.id;
        sessionStorage.setItem("msai_active_conv_id", newConv.id);

        await storage.saveConversation(newConv);
        this.notify();
        return newConv;
    }

    /**
     * Sets active conversation
     */
    setActiveConversation(id) {
        if (id === null || this.getConversation(id)) {
            this.activeConversationId = id;
            if (id) {
                sessionStorage.setItem("msai_active_conv_id", id);
            } else {
                sessionStorage.removeItem("msai_active_conv_id");
            }
            this.notify();
        }
    }

    /**
     * Adds a message to current active conversation
     */
    async addMessage(role, content, attachments = []) {
        let activeConv = this.getActiveConversation();

        if (!activeConv) {
            // Auto generate conversation title from first user message
            const title = role === 'user' ? this.generateTitleFromPrompt(content) : "New Conversation";
            activeConv = await this.createNewConversation(title);
        } else if (activeConv.messages.length === 0 && role === 'user') {
            // Update title if first message
            activeConv.title = this.generateTitleFromPrompt(content);
        }

        const message = {
            id: 'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7),
            role: role, // 'user' or 'assistant'
            content: content,
            attachments: attachments || [],
            timestamp: new Date().toISOString()
        };

        activeConv.messages.push(message);
        activeConv.updatedAt = new Date().toISOString();

        // Re-sort conversations by updatedAt
        this.conversations.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));

        await storage.saveConversation(activeConv);
        this.notify();
        return message;
    }

    /**
     * Updates an existing assistant response during streaming
     */
    async updateLastAssistantMessage(content) {
        const activeConv = this.getActiveConversation();
        if (!activeConv || activeConv.messages.length === 0) return;

        const lastMsg = activeConv.messages[activeConv.messages.length - 1];
        if (lastMsg.role === 'assistant') {
            lastMsg.content = content;
            lastMsg.timestamp = new Date().toISOString();
            activeConv.updatedAt = new Date().toISOString();
            await storage.saveConversation(activeConv);
            this.notify();
        }
    }

    /**
     * Generates a clean short title from first prompt
     */
    generateTitleFromPrompt(prompt) {
        if (!prompt) return "New Conversation";
        let title = prompt.trim().replace(/^[^\w]+/, '');
        if (title.length > 36) {
            title = title.substring(0, 36) + '...';
        }
        return title.charAt(0).toUpperCase() + title.slice(1) || "New Conversation";
    }

    /**
     * Renames a conversation
     */
    async renameConversation(id, newTitle) {
        const conv = this.getConversation(id);
        if (conv && newTitle) {
            conv.title = newTitle.trim();
            conv.updatedAt = new Date().toISOString();
            await storage.saveConversation(conv);
            this.notify();
        }
    }

    /**
     * Deletes a conversation by ID
     */
    async deleteConversation(id) {
        await storage.deleteConversation(id);
        this.conversations = this.conversations.filter(c => c.id !== id);

        if (this.activeConversationId === id) {
            const nextConv = this.conversations[0];
            this.setActiveConversation(nextConv ? nextConv.id : null);
        } else {
            this.notify();
        }
    }

    /**
     * Deletes all conversations
     */
    async clearAllData() {
        await storage.clearAllConversations();
        this.conversations = [];
        this.setActiveConversation(null);
    }
}

export const conversations = new ConversationManager();
