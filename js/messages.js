import { renderMarkdown } from './markdown.js';

export function createMessageElement(msg) {
  const row = document.createElement('div');
  row.className = `message-row ${msg.role}`;
  row.setAttribute('data-msg-id', msg.id);

  const avatarSrc = msg.role === 'user' ? 'assets/avatar-user.svg' : 'assets/avatar-ai.svg';

  const avatarImg = document.createElement('img');
  avatarImg.src = avatarSrc;
  avatarImg.className = 'message-avatar';
  avatarImg.alt = msg.role;

  const bubble = document.createElement('div');
  bubble.className = 'message-bubble';

  const content = document.createElement('div');
  content.className = 'message-content';
  content.innerHTML = renderMarkdown(msg.content);

  const actions = document.createElement('div');
  actions.className = 'message-actions';

  if (msg.role === 'user') {
    actions.innerHTML = `
      <button class="btn-msg-copy" title="Copy">📋</button>
      <button class="btn-msg-edit" title="Edit">✏️</button>
      <button class="btn-msg-delete" title="Delete">🗑️</button>
    `;
  } else {
    actions.innerHTML = `
      <button class="btn-msg-copy" title="Copy">📋</button>
      <button class="btn-msg-retry" title="Regenerate">🔄</button>
      <button class="btn-msg-like" title="Like">👍</button>
      <button class="btn-msg-dislike" title="Dislike">👎</button>
      <button class="btn-msg-share" title="Share">🔗</button>
    `;
  }

  bubble.appendChild(content);
  bubble.appendChild(actions);

  row.appendChild(avatarImg);
  row.appendChild(bubble);

  return row;
}