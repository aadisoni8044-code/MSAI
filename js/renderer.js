import { renderMarkdown } from './markdown.js';
import { formatTimestamp, escapeHTML } from './utils.js';

/**
 * Chat Message Component Renderer
 */
export class ChatRenderer {
    constructor() {
        this.chatContainer = null;
        this.welcomeScreen = null;
    }

    init() {
        this.chatContainer = document.getElementById('chat-container');
        this.welcomeScreen = document.getElementById('welcome-screen');
    }

    /**
     * Show welcome screen or chat viewport depending on conversation state
     */
    toggleViewMode(hasMessages) {
        if (!hasMessages) {
            this.welcomeScreen.style.display = 'flex';
            this.chatContainer.style.display = 'none';
        } else {
            this.welcomeScreen.style.display = 'none';
            this.chatContainer.style.display = 'flex';
        }
    }

    /**
     * Render complete conversation message stream
     */
    renderConversation(conversation, callbacks = {}) {
        if (!conversation || !conversation.messages || conversation.messages.length === 0) {
            this.toggleViewMode(false);
            return;
        }

        this.toggleViewMode(true);
        this.chatContainer.innerHTML = '';

        conversation.messages.forEach(msg => {
            const msgEl = this.createMessageElement(msg, callbacks);
            this.chatContainer.appendChild(msgEl);
        });

        this.scrollToBottom();
    }

    /**
     * Build single DOM element for user or assistant message
     */
    createMessageElement(message, callbacks = {}) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${message.role}`;
        messageDiv.setAttribute('data-id', message.id);

        const isUser = message.role === 'user';
        const avatarText = isUser ? 'U' : 'M';
        const senderName = isUser ? 'You' : 'MSAI';

        // Process attachments HTML if present
        let attachmentsHTML = '';
        if (message.attachments && message.attachments.length > 0) {
            attachmentsHTML = `
                <div class="message-attachments">
                    ${message.attachments.map(att => `
                        <div class="attachment-preview-item">
                            ${att.mimeType.startsWith('image/') ? `<img src="${att.dataUrl || ('data:' + att.mimeType + ';base64,' + att.data)}" alt="attachment">` : `<span>📄 ${escapeHTML(att.name)}</span>`}
                        </div>
                    `).join('')}
                </div>
            `;
        }

        // Render message content
        const bodyContent = isUser ? `<p>${escapeHTML(message.content).replace(/\n/g, '<br>')}</p>` : renderMarkdown(message.content);

        // Action buttons
        let actionsHTML = '';
        if (isUser) {
            actionsHTML = `
                <button class="action-btn edit-btn" title="Edit message">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    <span>Edit</span>
                </button>
                <button class="action-btn copy-btn" title="Copy text">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                    <span>Copy</span>
                </button>
            `;
        } else {
            actionsHTML = `
                <button class="action-btn copy-btn" title="Copy response">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                    <span>Copy</span>
                </button>
                <button class="action-btn regenerate-btn" title="Regenerate response">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
                    <span>Regenerate</span>
                </button>
            `;
        }

        messageDiv.innerHTML = `
            <div class="message-avatar">${avatarText}</div>
            <div class="message-content-wrapper">
                <div class="message-header">
                    <span class="message-sender">${senderName}</span>
                    <span class="message-time">${formatTimestamp(message.timestamp || Date.now())}</span>
                </div>
                ${attachmentsHTML}
                <div class="message-body">${bodyContent}</div>
                <div class="message-actions">${actionsHTML}</div>
            </div>
        `;

        // Bind copy buttons
        const copyBtn = messageDiv.querySelector('.copy-btn');
        if (copyBtn && callbacks.onCopy) {
            copyBtn.addEventListener('click', () => callbacks.onCopy(message.content, copyBtn));
        }

        // Bind edit button
        const editBtn = messageDiv.querySelector('.edit-btn');
        if (editBtn && callbacks.onEdit) {
            editBtn.addEventListener('click', () => callbacks.onEdit(message));
        }

        // Bind regenerate button
        const regenBtn = messageDiv.querySelector('.regenerate-btn');
        if (regenBtn && callbacks.onRegenerate) {
            regenBtn.addEventListener('click', () => callbacks.onRegenerate(message));
        }

        // Bind code copy buttons within code blocks
        messageDiv.querySelectorAll('.code-copy-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const rawCode = decodeURIComponent(btn.getAttribute('data-code'));
                if (callbacks.onCopy) callbacks.onCopy(rawCode, btn);
            });
        });

        return messageDiv;
    }

    /**
     * Create streaming message placeholder
     */
    createStreamingMessagePlaceholder(messageId) {
        this.toggleViewMode(true);

        const messageDiv = document.createElement('div');
        messageDiv.className = 'message assistant streaming';
        messageDiv.setAttribute('data-id', messageId);

        messageDiv.innerHTML = `
            <div class="message-avatar">M</div>
            <div class="message-content-wrapper">
                <div class="message-header">
                    <span class="message-sender">MSAI</span>
                    <span class="message-time">Just now</span>
                </div>
                <div class="message-body">
                    <div class="thinking-dots">
                        <span></span><span></span><span></span>
                    </div>
                </div>
            </div>
        `;

        this.chatContainer.appendChild(messageDiv);
        this.scrollToBottom();
        return messageDiv;
    }

    /**
     * Update streaming message body continuously
     */
    updateStreamingMessageContent(messageEl, content, callbacks = {}) {
        const bodyEl = messageEl.querySelector('.message-body');
        if (bodyEl) {
            bodyEl.innerHTML = renderMarkdown(content);

            // Rebind code block copy buttons
            bodyEl.querySelectorAll('.code-copy-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    const rawCode = decodeURIComponent(btn.getAttribute('data-code'));
                    if (callbacks.onCopy) callbacks.onCopy(rawCode, btn);
                });
            });
        }
        this.scrollToBottom();
    }

    /**
     * Finalize streaming message element with complete action buttons
     */
    finalizeStreamingMessage(messageEl, finalMessage, callbacks = {}) {
        messageEl.classList.remove('streaming');
        const wrapper = messageEl.querySelector('.message-content-wrapper');

        const actionsDiv = document.createElement('div');
        actionsDiv.className = 'message-actions';
        actionsDiv.innerHTML = `
            <button class="action-btn copy-btn" title="Copy response">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                <span>Copy</span>
            </button>
            <button class="action-btn regenerate-btn" title="Regenerate response">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
                <span>Regenerate</span>
            </button>
        `;

        wrapper.appendChild(actionsDiv);

        const copyBtn = actionsDiv.querySelector('.copy-btn');
        if (copyBtn && callbacks.onCopy) {
            copyBtn.addEventListener('click', () => callbacks.onCopy(finalMessage.content, copyBtn));
        }

        const regenBtn = actionsDiv.querySelector('.regenerate-btn');
        if (regenBtn && callbacks.onRegenerate) {
            regenBtn.addEventListener('click', () => callbacks.onRegenerate(finalMessage));
        }
    }

    scrollToBottom() {
        const viewport = document.getElementById('chat-viewport');
        if (viewport) {
            viewport.scrollTop = viewport.scrollHeight;
        }
    }
}

export const chatRenderer = new ChatRenderer();
