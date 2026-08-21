/**
 * Message & Chat Viewport Renderer Module
 * Handles message bubbles, streaming animation, markdown rendering, copy-to-clipboard, and code blocks.
 */

import { renderMarkdown } from './markdown.js';
import { toast } from './toast.js';
import { escapeHtml } from './sanitizer.js';

export class MessageRenderer {
    constructor() {
        this.welcomeScreen = document.getElementById("welcome-screen");
        this.messagesList = document.getElementById("messages-list");
        this.chatContainer = document.getElementById("chat-container");
    }

    /**
     * Renders full conversation message list
     */
    renderConversation(activeConv, isStreaming = false) {
        if (!activeConv || !activeConv.messages || activeConv.messages.length === 0) {
            if (this.welcomeScreen) this.welcomeScreen.style.display = "flex";
            if (this.messagesList) {
                this.messagesList.style.display = "none";
                this.messagesList.innerHTML = "";
            }
            return;
        }

        if (this.welcomeScreen) this.welcomeScreen.style.display = "none";
        if (this.messagesList) this.messagesList.style.display = "flex";

        let html = "";
        activeConv.messages.forEach((msg, idx) => {
            const isLast = idx === activeConv.messages.length - 1;
            html += this._createMessageHTML(msg, isLast && isStreaming);
        });

        this.messagesList.innerHTML = html;
        this.attachMessageEventListeners();
        this.scrollToBottom();
    }

    _createMessageHTML(msg, isCurrentlyStreaming) {
        const isUser = msg.role === "user";
        const roleClass = isUser ? "user" : "ai";
        const avatarLabel = isUser ? "U" : "M";
        const formattedTime = new Date(msg.timestamp || Date.now()).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        let contentHTML = "";
        if (isUser) {
            contentHTML = escapeHtml(msg.content).replace(/\n/g, "<br>");
            if (msg.attachments && msg.attachments.length > 0) {
                contentHTML += `<div style="margin-top:0.5rem; display:flex; gap:0.5rem; flex-wrap:wrap;">`;
                msg.attachments.forEach(att => {
                    if (att.isImage && att.base64) {
                        contentHTML += `<img src="data:${att.mimeType};base64,${att.base64}" style="max-width:180px; max-height:140px; border-radius:8px;" alt="${escapeHtml(att.name)}">`;
                    } else {
                        contentHTML += `<div style="padding:0.3rem 0.6rem; background:rgba(255,255,255,0.1); border-radius:6px; font-size:0.8rem;">📎 ${escapeHtml(att.name)}</div>`;
                    }
                });
                contentHTML += `</div>`;
            }
        } else {
            contentHTML = renderMarkdown(msg.content);
            if (isCurrentlyStreaming) {
                contentHTML += `<div class="typing-indicator"><div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div></div>`;
            }
        }

        const actionsHTML = isUser ? `
            <div class="message-actions">
                <button class="action-btn btn-copy-msg" data-text="${encodeURIComponent(msg.content)}">Copy</button>
            </div>
        ` : `
            <div class="message-actions">
                <button class="action-btn btn-copy-msg" data-text="${encodeURIComponent(msg.content)}">Copy</button>
                <button class="action-btn btn-regenerate-msg" data-id="${msg.id}">Regenerate</button>
            </div>
        `;

        return `
            <div class="message-wrapper ${roleClass}" data-id="${msg.id}">
                <div class="message-avatar ${roleClass}">${avatarLabel}</div>
                <div class="message-content-box">
                    <div class="message-header">
                        <span style="font-weight:600;">${isUser ? 'You' : 'MSAI'}</span>
                        <span>${formattedTime}</span>
                    </div>
                    <div class="message-bubble markdown-body">${contentHTML}</div>
                    ${actionsHTML}
                </div>
            </div>
        `;
    }

    attachMessageEventListeners() {
        if (!this.messagesList) return;

        // Copy message text
        this.messagesList.querySelectorAll(".btn-copy-msg").forEach(btn => {
            btn.addEventListener("click", () => {
                const text = decodeURIComponent(btn.getAttribute("data-text") || "");
                navigator.clipboard.writeText(text).then(() => {
                    toast.show("Message copied to clipboard", "success");
                }).catch(() => {
                    toast.show("Failed to copy text", "error");
                });
            });
        });

        // Regenerate assistant response
        this.messagesList.querySelectorAll(".btn-regenerate-msg").forEach(btn => {
            btn.addEventListener("click", () => {
                const msgId = btn.getAttribute("data-id");
                if (window.msaiRegenerateHandler) {
                    window.msaiRegenerateHandler(msgId);
                }
            });
        });

        // Copy code blocks
        this.messagesList.querySelectorAll(".btn-copy-code").forEach(btn => {
            btn.addEventListener("click", () => {
                const code = decodeURIComponent(btn.getAttribute("data-code") || "");
                navigator.clipboard.writeText(code).then(() => {
                    const span = btn.querySelector("span");
                    if (span) span.textContent = "Copied!";
                    toast.show("Code block copied!", "success");
                    setTimeout(() => {
                        if (span) span.textContent = "Copy";
                    }, 2000);
                });
            });
        });
    }

    scrollToBottom() {
        if (this.chatContainer) {
            this.chatContainer.scrollTop = this.chatContainer.scrollHeight;
        }
    }
}

export const renderer = new MessageRenderer();
