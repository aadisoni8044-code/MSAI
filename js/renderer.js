/**
 * MSAI - DOM Message & Welcome Screen Renderer
 */

import { renderMarkdown } from "./markdown.js";
import { escapeHtml } from "./sanitizer.js";
import { copyToClipboard } from "./utils.js";
import { toast } from "./toast.js";
import { voiceService } from "./voice.js";

export class Renderer {
  constructor() {
    this.chatContainer = null;
    this.messagesListEl = null;
    this.welcomeScreenEl = null;
    this.retryCallback = null;
  }

  init({ chatContainer, messagesListEl, welcomeScreenEl }) {
    this.chatContainer = chatContainer;
    this.messagesListEl = messagesListEl;
    this.welcomeScreenEl = welcomeScreenEl;
  }

  showWelcomeScreen(show = true) {
    if (this.welcomeScreenEl) {
      this.welcomeScreenEl.style.display = show ? "flex" : "none";
    }
    if (this.messagesListEl) {
      this.messagesListEl.style.display = show ? "none" : "block";
    }
  }

  renderConversation(conversation, options = {}) {
    if (!this.messagesListEl) return;

    if (!conversation || !conversation.messages || conversation.messages.length === 0) {
      this.showWelcomeScreen(true);
      this.messagesListEl.innerHTML = "";
      return;
    }

    this.showWelcomeScreen(false);
    this.messagesListEl.innerHTML = "";

    conversation.messages.forEach((msg) => {
      this.appendMessageElement(msg, false);
    });

    if (options.autoScroll) {
      this.scrollToBottom();
    }
  }

  appendMessageElement(msg, autoScroll = true) {
    if (!this.messagesListEl) return;
    this.showWelcomeScreen(false);

    // If message is flagged as error, render error element
    if (msg.isError || msg.role === "error") {
      return this.appendErrorElement(msg.content || msg.errorMessage, null, autoScroll);
    }

    const isUser = msg.role === "user";
    const msgEl = document.createElement("div");
    msgEl.className = `message-row ${isUser ? "user-row" : "assistant-row"} animate-fade-in`;
    msgEl.id = `msg-${msg.id}`;

    const timeStr = new Date(msg.timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });

    if (isUser) {
      // User Message Template
      let attachmentsHtml = "";
      if (msg.attachments && msg.attachments.length > 0) {
        attachmentsHtml = `
          <div class="msg-attachments-container">
            ${msg.attachments
              .map((att) => {
                if (att.isImage) {
                  return `<div class="msg-attachment-img-wrap"><img src="${att.data}" alt="${att.name}" class="msg-attachment-img" /></div>`;
                }
                return `
                  <div class="msg-attachment-file">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
                      <polyline points="14 2 14 8 20 8"/>
                    </svg>
                    <span>${att.name}</span>
                  </div>
                `;
              })
              .join("")}
          </div>
        `;
      }

      msgEl.innerHTML = `
        <div class="message-bubble user-bubble">
          ${attachmentsHtml}
          <div class="message-text">${renderMarkdown(msg.content)}</div>
          <div class="message-meta-bar">
            <span class="message-time">${timeStr}</span>
            <div class="user-action-buttons">
              <button class="msg-action-btn edit-msg-btn" data-msg-id="${msg.id}" title="Edit prompt" aria-label="Edit prompt">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/>
                </svg>
              </button>
              <button class="msg-action-btn copy-msg-btn" data-msg-id="${msg.id}" title="Copy message" aria-label="Copy message">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <rect width="14" height="14" x="8" y="8" rx="2" ry="2"/>
                  <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
      `;
    } else {
      // Assistant Message Template
      // Sanitize legacy HTML if previously present
      let cleanContent = msg.content || "";
      if (cleanContent.includes("retry-msg-btn") || cleanContent.includes("<button")) {
        cleanContent = cleanContent.replace(/<button[\s\S]*?<\/button>/gi, "").replace(/<[^>]+>/g, "").trim();
      }

      const renderedHtml = renderMarkdown(cleanContent);
      msgEl.innerHTML = `
        <div class="assistant-avatar">
          <div class="avatar-badge">M</div>
        </div>
        <div class="message-content-wrapper">
          <div class="assistant-header">
            <span class="assistant-name">MSAI</span>
            <span class="message-time">${timeStr}</span>
          </div>
          <div class="message-bubble assistant-bubble">
            <div class="message-text markdown-body">${renderedHtml}</div>
          </div>
          <div class="assistant-actions-bar">
            <button class="msg-action-btn copy-ai-btn" data-msg-id="${msg.id}" title="Copy response">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect width="14" height="14" x="8" y="8" rx="2" ry="2"/>
                <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/>
              </svg>
              <span>Copy</span>
            </button>
            <button class="msg-action-btn regenerate-btn" data-msg-id="${msg.id}" title="Regenerate response">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 12a9 9 0 0 0-9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
                <path d="M3 3v5h5"/>
                <path d="M3 12a9 9 0 0 0 9 9 9.75 9.75 0 0 0 6.74-2.74L21 16"/>
                <path d="M16 21h5v-5"/>
              </svg>
              <span>Regenerate</span>
            </button>
            <button class="msg-action-btn tts-btn" data-speak-btn="${msg.id}" data-msg-id="${msg.id}" title="Read Aloud">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/>
                <path d="M15.54 8.46a5 5 0 0 1 0 7.07"/>
                <path d="M19.07 4.93a10 10 0 0 1 0 14.14"/>
              </svg>
              <span>Speak</span>
            </button>
            <button class="msg-action-btn feedback-btn" data-type="like" title="Good response">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M7 10v12"/>
                <path d="M15 5.88 14 10h5.83a2 2 0 0 1 1.92 2.56l-2.33 8A2 2 0 0 1 17.5 22H4a2 2 0 0 1-2-2v-8a2 2 0 0 1 2-2h2.76a2 2 0 0 0 1.79-1.11L12 2h0a3.13 3.13 0 0 1 3 3.88Z"/>
              </svg>
            </button>
            <button class="msg-action-btn feedback-btn" data-type="dislike" title="Poor response">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M17 14V2"/>
                <path d="M9 18.12 10 14H4.17a2 2 0 0 1-1.92-2.56l2.33-8A2 2 0 0 1 6.5 2H20a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-2.76a2 2 0 0 0-1.79 1.11L12 22h0a3.13 3.13 0 0 1-3-3.88Z"/>
              </svg>
            </button>
          </div>
        </div>
      `;
    }

    this.messagesListEl.appendChild(msgEl);
    this.bindMessageEvents(msgEl, msg);

    if (autoScroll) {
      this.scrollToBottom();
    }
  }

  appendErrorElement(errorMessage, onRetry = null, autoScroll = true) {
    this.removeThinkingIndicator();
    this.removeErrorElements();
    if (!this.messagesListEl) return;
    this.showWelcomeScreen(false);

    if (onRetry) {
      this.retryCallback = onRetry;
    }

    const errorId = "err-" + Date.now();
    const errorRow = document.createElement("div");
    errorRow.className = "message-row assistant-row error-message-row animate-fade-in";
    errorRow.id = errorId;

    const timeStr = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    const safeErrorText = escapeHtml(errorMessage || "An unexpected error occurred. Please try again.");

    errorRow.innerHTML = `
      <div class="assistant-avatar">
        <div class="avatar-badge avatar-badge-error">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
            <line x1="12" y1="9" x2="12" y2="13"/>
            <line x1="12" y1="17" x2="12.01" y2="17"/>
          </svg>
        </div>
      </div>
      <div class="message-content-wrapper">
        <div class="assistant-header">
          <span class="assistant-name">MSAI</span>
          <span class="message-time">${timeStr}</span>
        </div>
        <div class="message-bubble error-bubble">
          <div class="error-card">
            <div class="error-card-header">
              <svg class="error-card-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/>
                <line x1="12" y1="9" x2="12" y2="13"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
              <span>Error generating response</span>
            </div>
            <p class="error-card-message">${safeErrorText}</p>
            <div class="error-card-actions">
              <button type="button" class="retry-msg-btn" id="btn-${errorId}">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21 12a9 9 0 0 0-9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
                  <path d="M3 3v5h5"/>
                  <path d="M3 12a9 9 0 0 0 9 9 9.75 9.75 0 0 0 6.74-2.74L21 16"/>
                  <path d="M16 21h5v-5"/>
                </svg>
                <span>Retry</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    `;

    this.messagesListEl.appendChild(errorRow);

    const retryBtn = errorRow.querySelector(".retry-msg-btn");
    if (retryBtn) {
      retryBtn.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (this.retryCallback) {
          this.retryCallback();
        }
      });
    }

    if (autoScroll) {
      this.scrollToBottom();
    }

    return errorRow;
  }

  removeErrorElements() {
    if (!this.messagesListEl) return;
    const errors = this.messagesListEl.querySelectorAll(".error-message-row");
    errors.forEach((el) => el.remove());
  }

  updateStreamingMessage(msgId, content) {
    const msgEl = document.getElementById(`msg-${msgId}`);
    if (!msgEl) return;

    const textContainer = msgEl.querySelector(".message-text");
    if (textContainer) {
      textContainer.innerHTML = renderMarkdown(content);
      this.bindCodeBlockCopies(textContainer);
    }

    this.scrollToBottom();
  }

  finalizeStreamingMessage(tempMsgId, finalMsg) {
    const msgEl = document.getElementById(`msg-${tempMsgId}`);
    if (!msgEl || !finalMsg) return;

    msgEl.id = `msg-${finalMsg.id}`;

    // Update action buttons with final ID and content
    const btns = msgEl.querySelectorAll("[data-msg-id]");
    btns.forEach((btn) => btn.setAttribute("data-msg-id", finalMsg.id));

    const speakBtn = msgEl.querySelector(".speak-btn");
    if (speakBtn) {
      speakBtn.setAttribute("data-speak-btn", finalMsg.id);
    }

    this.bindMessageEvents(msgEl, finalMsg);
  }

  showThinkingIndicator() {
    this.removeThinkingIndicator();
    if (!this.messagesListEl) return;

    const indicator = document.createElement("div");
    indicator.className = "message-row assistant-row thinking-indicator-row animate-fade-in";
    indicator.id = "msai-thinking-indicator";

    indicator.innerHTML = `
      <div class="assistant-avatar">
        <div class="avatar-badge pulsing-badge">M</div>
      </div>
      <div class="message-content-wrapper">
        <div class="assistant-header">
          <span class="assistant-name">MSAI</span>
          <span class="thinking-text">is thinking...</span>
        </div>
        <div class="message-bubble assistant-bubble thinking-bubble">
          <div class="typing-dots">
            <span class="dot"></span>
            <span class="dot"></span>
            <span class="dot"></span>
          </div>
        </div>
      </div>
    `;

    this.messagesListEl.appendChild(indicator);
    this.scrollToBottom();
  }

  removeThinkingIndicator() {
    const indicator = document.getElementById("msai-thinking-indicator");
    if (indicator && indicator.parentNode) {
      indicator.parentNode.removeChild(indicator);
    }
  }

  bindMessageEvents(msgEl, msg) {
    // Copy button
    const copyBtns = msgEl.querySelectorAll(".copy-msg-btn, .copy-ai-btn");
    copyBtns.forEach((btn) => {
      btn.addEventListener("click", async () => {
        const ok = await copyToClipboard(msg.content);
        if (ok) {
          toast.success("Copied to clipboard!");
          const textSpan = btn.querySelector("span");
          if (textSpan) {
            const orig = textSpan.textContent;
            textSpan.textContent = "Copied!";
            setTimeout(() => (textSpan.textContent = orig), 1500);
          }
        }
      });
    });

    // Code copy buttons
    this.bindCodeBlockCopies(msgEl);

    // TTS button
    const speakBtn = msgEl.querySelector(`[data-speak-btn="${msg.id}"]`);
    if (speakBtn) {
      speakBtn.addEventListener("click", () => {
        voiceService.speak(msg.content, msg.id);
      });
    }

    // Feedback thumbs
    const feedbackBtns = msgEl.querySelectorAll(".feedback-btn");
    feedbackBtns.forEach((btn) => {
      btn.addEventListener("click", () => {
        const isLike = btn.dataset.type === "like";
        feedbackBtns.forEach((b) => b.classList.remove("active-feedback"));
        btn.classList.add("active-feedback");
        toast.info(isLike ? "Thanks for your feedback!" : "Feedback recorded.", 1500);
      });
    });
  }

  bindCodeBlockCopies(container) {
    const copyButtons = container.querySelectorAll(".code-copy-btn");
    copyButtons.forEach((btn) => {
      btn.onclick = async (e) => {
        e.stopPropagation();
        const rawCode = decodeURIComponent(btn.getAttribute("data-code") || "");
        const ok = await copyToClipboard(rawCode);
        if (ok) {
          const textSpan = btn.querySelector(".copy-text");
          if (textSpan) {
            textSpan.textContent = "Copied!";
            btn.classList.add("copied-success");
            setTimeout(() => {
              textSpan.textContent = "Copy";
              btn.classList.remove("copied-success");
            }, 1800);
          }
        }
      };
    });
  }

  scrollToBottom(smooth = true) {
    if (!this.chatContainer) return;
    requestAnimationFrame(() => {
      this.chatContainer.scrollTo({
        top: this.chatContainer.scrollHeight,
        behavior: smooth ? "smooth" : "auto",
      });
    });
  }
}

export const renderer = new Renderer();
