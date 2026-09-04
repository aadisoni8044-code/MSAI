/**
 * Message DOM Renderer & Action Handlers
 */
import { renderMarkdown } from './markdown.js';
import { copyToClipboard, escapeHtml } from './utils.js';
import { notifications } from './notifications.js';
import { events } from './events.js';
import { i18n } from './language.js';

export function createMessageElement(message, onAction) {
  const row = document.createElement('div');
  row.className = `message-row ${message.role}`;
  row.dataset.messageId = message.id;

  const isUser = message.role === 'user';
  const avatarSrc = isUser ? '/assets/avatar-user.svg' : '/assets/avatar-msai.svg';
  const avatarClass = isUser ? 'user-avatar' : 'ai-avatar';

  row.innerHTML = `
    <div class="message-avatar ${avatarClass}">
      <img src="${avatarSrc}" alt="${isUser ? 'User' : 'MSAI'}" />
    </div>
    <div class="message-content-wrapper">
      <div class="message-bubble ${isUser ? '' : 'markdown-body'}">
        ${isUser ? escapeHtml(message.content) : renderMarkdown(message.content)}
      </div>
      <div class="message-actions">
        ${isUser ? renderUserActions() : renderAssistantActions()}
      </div>
    </div>
  `;

  // Attach event delegation for actions
  setupMessageActions(row, message, onAction);
  return row;
}

function renderUserActions() {
  return `
    <button class="msg-action-btn action-copy" title="${i18n.get('message.copy', 'Copy')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
        <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
      </svg>
    </button>
    <button class="msg-action-btn action-edit" title="${i18n.get('message.edit', 'Edit')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
      </svg>
    </button>
    <button class="msg-action-btn action-delete" title="${i18n.get('message.delete', 'Delete')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <polyline points="3 6 5 6 21 6"></polyline>
        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
      </svg>
    </button>
  `;
}

function renderAssistantActions() {
  return `
    <button class="msg-action-btn action-copy" title="${i18n.get('message.copy', 'Copy')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
        <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
      </svg>
    </button>
    <button class="msg-action-btn action-regenerate" title="${i18n.get('message.regenerate', 'Regenerate')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M23 4v6h-6"></path>
        <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path>
      </svg>
    </button>
    <button class="msg-action-btn action-like" title="${i18n.get('message.like', 'Good response')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path>
      </svg>
    </button>
    <button class="msg-action-btn action-dislike" title="${i18n.get('message.dislike', 'Bad response')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h3a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2h-3"></path>
      </svg>
    </button>
    <button class="msg-action-btn action-share" title="${i18n.get('message.share', 'Share')}">
      <svg class="icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="18" cy="5" r="3"></circle>
        <circle cx="6" cy="12" r="3"></circle>
        <circle cx="18" cy="19" r="3"></circle>
        <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
        <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
      </svg>
    </button>
  `;
}

function setupMessageActions(element, message, onAction) {
  // Copy
  const copyBtn = element.querySelector('.action-copy');
  if (copyBtn) {
    copyBtn.addEventListener('click', async () => {
      const ok = await copyToClipboard(message.content);
      if (ok) notifications.success(i18n.get('notifications.copied', 'Copied to clipboard'));
    });
  }

  // Code block copy buttons
  element.querySelectorAll('.code-block-copy-btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const code = btn.getAttribute('data-copy') || '';
      const ok = await copyToClipboard(code);
      if (ok) {
        btn.querySelector('span').textContent = i18n.get('message.copied', 'Copied!');
        setTimeout(() => {
          btn.querySelector('span').textContent = 'Copy';
        }, 2000);
      }
    });
  });

  // Regenerate
  const regenBtn = element.querySelector('.action-regenerate');
  if (regenBtn && onAction) {
    regenBtn.addEventListener('click', () => onAction('regenerate', message));
  }

  // Edit user message
  const editBtn = element.querySelector('.action-edit');
  if (editBtn && onAction) {
    editBtn.addEventListener('click', () => {
      enableInlineEdit(element, message, onAction);
    });
  }

  // Delete message
  const deleteBtn = element.querySelector('.action-delete');
  if (deleteBtn && onAction) {
    deleteBtn.addEventListener('click', () => onAction('delete', message));
  }

  // Like / Dislike
  const likeBtn = element.querySelector('.action-like');
  const dislikeBtn = element.querySelector('.action-dislike');
  if (likeBtn && dislikeBtn) {
    likeBtn.addEventListener('click', () => {
      likeBtn.classList.toggle('active');
      dislikeBtn.classList.remove('active');
    });
    dislikeBtn.addEventListener('click', () => {
      dislikeBtn.classList.toggle('active');
      likeBtn.classList.remove('active');
    });
  }

  // Share
  const shareBtn = element.querySelector('.action-share');
  if (shareBtn) {
    shareBtn.addEventListener('click', async () => {
      const ok = await copyToClipboard(message.content);
      if (ok) notifications.info(i18n.get('notifications.copied', 'Response link/text copied'));
    });
  }
}

function enableInlineEdit(rowElement, message, onAction) {
  const bubble = rowElement.querySelector('.message-bubble');
  const originalText = message.content;

  bubble.innerHTML = `
    <div class="edit-message-box">
      <textarea class="edit-message-textarea">${escapeHtml(originalText)}</textarea>
      <div class="edit-message-buttons">
        <button class="btn btn-secondary btn-cancel-edit">${i18n.get('message.cancel', 'Cancel')}</button>
        <button class="btn btn-primary btn-save-edit">${i18n.get('message.save', 'Save & Submit')}</button>
      </div>
    </div>
  `;

  const textarea = bubble.querySelector('.edit-message-textarea');
  textarea.focus();

  bubble.querySelector('.btn-cancel-edit').addEventListener('click', () => {
    bubble.innerHTML = escapeHtml(originalText);
  });

  bubble.querySelector('.btn-save-edit').addEventListener('click', () => {
    const newText = textarea.value.trim();
    if (newText && onAction) {
      onAction('edit', message, newText);
    }
  });
}

export function createTypingIndicator() {
  const row = document.createElement('div');
  row.className = 'message-row assistant typing-row';
  row.id = 'typingIndicatorRow';
  row.innerHTML = `
    <div class="message-avatar ai-avatar">
      <img src="/assets/avatar-msai.svg" alt="MSAI" />
    </div>
    <div class="message-content-wrapper">
      <div class="typing-indicator">
        <div class="typing-dot"></div>
        <div class="typing-dot"></div>
        <div class="typing-dot"></div>
      </div>
    </div>
  `;
  return row;
}
