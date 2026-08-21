import { storage } from './storage.js';
import { generateUUID } from './utils.js';

export class ConversationManager {
    constructor() {
        this.activeConversation = null;
    }

    /**
     * Create a new blank conversation object
     */
    createNewConversation(title = 'New Conversation') {
        const conversation = {
            id: generateUUID(),
            title: title,
            createdAt: Date.now(),
            updatedAt: Date.now(),
            messages: []
        };
        this.activeConversation = conversation;
        return conversation;
    }

    /**
     * Load all conversations sorted by updatedAt DESC
     */
    async getConversations() {
        return await storage.getAllConversations();
    }

    /**
     * Set active conversation by ID
     */
    async loadConversation(id) {
        const conv = await storage.getConversation(id);
        if (conv) {
            this.activeConversation = conv;
        }
        return conv;
    }

    /**
     * Add a message to the active conversation
     */
    async addMessage(message) {
        if (!this.activeConversation) {
            this.createNewConversation();
        }

        // Generate title from first user message if current title is default
        if (this.activeConversation.messages.length === 0 && message.role === 'user') {
            this.activeConversation.title = this.generateTitle(message.content);
        }

        this.activeConversation.messages.push(message);
        this.activeConversation.updatedAt = Date.now();

        await storage.saveConversation(this.activeConversation);
        return this.activeConversation;
    }

    /**
     * Update an existing message content
     */
    async updateMessageContent(messageId, newContent) {
        if (!this.activeConversation) return null;

        const msgIndex = this.activeConversation.messages.findIndex(m => m.id === messageId);
        if (msgIndex !== -1) {
            this.activeConversation.messages[msgIndex].content = newContent;
            this.activeConversation.updatedAt = Date.now();
            await storage.saveConversation(this.activeConversation);
        }
        return this.activeConversation;
    }

    /**
     * Truncate messages after a specific message ID (useful for edit/resend)
     */
    async truncateMessagesAfter(messageId) {
        if (!this.activeConversation) return;

        const msgIndex = this.activeConversation.messages.findIndex(m => m.id === messageId);
        if (msgIndex !== -1) {
            this.activeConversation.messages = this.activeConversation.messages.slice(0, msgIndex + 1);
            this.activeConversation.updatedAt = Date.now();
            await storage.saveConversation(this.activeConversation);
        }
    }

    /**
     * Rename active or target conversation
     */
    async renameConversation(id, newTitle) {
        const conv = await storage.getConversation(id);
        if (conv) {
            conv.title = newTitle;
            conv.updatedAt = Date.now();
            await storage.saveConversation(conv);
            if (this.activeConversation && this.activeConversation.id === id) {
                this.activeConversation.title = newTitle;
            }
        }
    }

    /**
     * Delete conversation by ID
     */
    async deleteConversation(id) {
        await storage.deleteConversation(id);
        if (this.activeConversation && this.activeConversation.id === id) {
            this.activeConversation = null;
        }
    }

    /**
     * Delete all conversations
     */
    async clearAllConversations() {
        await storage.clearAllConversations();
        this.activeConversation = null;
    }

    /**
     * Smart concise title generator from user message prompt
     */
    generateTitle(content) {
        if (!content || typeof content !== 'string') return 'New Conversation';

        let title = content.trim().split('\n')[0]; // Take first line
        title = title.replace(/[^\w\s-]/gi, ''); // Clean special characters

        if (title.length > 35) {
            title = title.substring(0, 32).trim() + '...';
        }

        return title || 'New Conversation';
    }
}

export const conversationManager = new ConversationManager();
