import { conversationManager } from './conversations.js';
import { apiService } from './api.js';
import { chatRenderer } from './renderer.js';
import { composer } from './composer.js';
import { sidebar } from './sidebar.js';
import { toast } from './toast.js';
import { generateUUID } from './utils.js';

/**
 * Main Chat Application Orchestration Module
 */
export class ChatController {
    constructor() {
        this.isGenerating = false;
    }

    init() {
        chatRenderer.init();

        // Initialize Composer with Send & Stop handlers
        composer.init({
            onSend: (text, attachments) => this.handleSendMessage(text, attachments),
            onStop: () => this.handleStopGeneration()
        });

        // Initialize Suggestion Cards on Welcome View
        document.querySelectorAll('.suggestion-card').forEach(card => {
            card.addEventListener('click', () => {
                const promptText = card.getAttribute('data-prompt');
                if (promptText) {
                    this.handleSendMessage(promptText, []);
                }
            });
        });
    }

    /**
     * Handle user sending a prompt message
     */
    async handleSendMessage(text, attachments = []) {
        if (this.isGenerating) return;

        // Ensure active conversation exists
        if (!conversationManager.activeConversation) {
            conversationManager.createNewConversation();
        }

        const userMsg = {
            id: generateUUID(),
            role: 'user',
            content: text,
            attachments: attachments,
            timestamp: Date.now()
        };

        // Add user message to active state & store
        await conversationManager.addMessage(userMsg);

        // Update UI
        chatRenderer.renderConversation(conversationManager.activeConversation, this.getCallbacks());
        await sidebar.renderConversationsList();

        // Trigger AI response generation
        this.generateAIResponse();
    }

    /**
     * Call Gemini API and stream response into UI
     */
    async generateAIResponse() {
        this.isGenerating = true;
        composer.setGeneratingState(true);

        const activeConv = conversationManager.activeConversation;
        if (!activeConv || activeConv.messages.length === 0) {
            this.isGenerating = false;
            composer.setGeneratingState(false);
            return;
        }

        const assistantMsgId = generateUUID();
        const streamingEl = chatRenderer.createStreamingMessagePlaceholder(assistantMsgId);

        let fullResponseText = '';

        try {
            const streamIterator = await apiService.sendMessageStream(activeConv.messages);

            for await (const chunk of streamIterator) {
                fullResponseText += chunk;
                chatRenderer.updateStreamingMessageContent(streamingEl, fullResponseText, this.getCallbacks());
            }

            // Save assistant message to conversation storage
            const assistantMsg = {
                id: assistantMsgId,
                role: 'assistant',
                content: fullResponseText || 'No response generated.',
                timestamp: Date.now()
            };

            await conversationManager.addMessage(assistantMsg);
            chatRenderer.finalizeStreamingMessage(streamingEl, assistantMsg, this.getCallbacks());
            await sidebar.renderConversationsList();

        } catch (error) {
            console.error('API Stream error:', error);

            if (error.message.includes('cancelled')) {
                toast.show('Generation stopped', 'info');
                if (fullResponseText) {
                    const assistantMsg = {
                        id: assistantMsgId,
                        role: 'assistant',
                        content: fullResponseText,
                        timestamp: Date.now()
                    };
                    await conversationManager.addMessage(assistantMsg);
                    chatRenderer.finalizeStreamingMessage(streamingEl, assistantMsg, this.getCallbacks());
                } else {
                    streamingEl.remove();
                }
            } else {
                toast.show(error.message, 'error', 5000);
                streamingEl.remove();
            }
        } finally {
            this.isGenerating = false;
            composer.setGeneratingState(false);
        }
    }

    /**
     * Cancel active AI generation request
     */
    handleStopGeneration() {
        apiService.stopGeneration();
    }

    /**
     * Handle editing user message
     */
    async handleEditMessage(message) {
        if (this.isGenerating) return;

        composer.setPrompt(message.content);
        await conversationManager.truncateMessagesAfter(message.id);

        // Remove truncated user message so sending new prompt replaces it
        const msgIndex = conversationManager.activeConversation.messages.findIndex(m => m.id === message.id);
        if (msgIndex !== -1) {
            conversationManager.activeConversation.messages.splice(msgIndex, 1);
        }

        chatRenderer.renderConversation(conversationManager.activeConversation, this.getCallbacks());
    }

    /**
     * Handle regenerating AI response for last message
     */
    async handleRegenerateResponse(message) {
        if (this.isGenerating) return;

        const activeConv = conversationManager.activeConversation;
        if (!activeConv) return;

        // If clicking regenerate on assistant message, delete it first
        const msgIndex = activeConv.messages.findIndex(m => m.id === message.id);
        if (msgIndex !== -1) {
            activeConv.messages.splice(msgIndex, 1);
            chatRenderer.renderConversation(activeConv, this.getCallbacks());
            this.generateAIResponse();
        }
    }

    /**
     * Handle copying text content to clipboard
     */
    handleCopyText(text, btnElement) {
        navigator.clipboard.writeText(text).then(() => {
            toast.show('Copied to clipboard!', 'success');
            if (btnElement) {
                const label = btnElement.querySelector('span');
                if (label) {
                    const origText = label.textContent;
                    label.textContent = 'Copied!';
                    setTimeout(() => { label.textContent = origText; }, 1500);
                }
            }
        }).catch(() => {
            toast.show('Failed to copy text', 'error');
        });
    }

    /**
     * Callbacks object passed into message renderer
     */
    getCallbacks() {
        return {
            onCopy: (text, btn) => this.handleCopyText(text, btn),
            onEdit: (msg) => this.handleEditMessage(msg),
            onRegenerate: (msg) => this.handleRegenerateResponse(msg)
        };
    }

    /**
     * Switch to selected conversation ID
     */
    async loadConversation(id) {
        if (this.isGenerating) {
            this.handleStopGeneration();
        }

        const conv = await conversationManager.loadConversation(id);
        chatRenderer.renderConversation(conv, this.getCallbacks());
        await sidebar.renderConversationsList();
    }

    /**
     * Start a new blank conversation
     */
    startNewChat() {
        if (this.isGenerating) {
            this.handleStopGeneration();
        }

        conversationManager.createNewConversation();
        chatRenderer.renderConversation(null, this.getCallbacks());
        sidebar.renderConversationsList();
    }
}

export const chatController = new ChatController();
