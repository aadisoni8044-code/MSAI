/**
 * MSAI Message Formatting & Rendering Component
 */
window.MSAI = window.MSAI || {};

window.MSAI.Messages = {
  createMessageNode(msg) {
    const row = document.createElement('div');
    row.className = `message-row ${msg.sender}`;

    const isUser = msg.sender === 'user';
    const avatarContent = isUser ? 'U' : 'M';

    row.innerHTML = `
      <div class="message-avatar">${avatarContent}</div>
      <div class="message-body">
        <div class="message-header">
          <span>${isUser ? 'You' : 'MSAI'}</span>
        </div>
        <div class="message-content">${window.MSAI.Markdown ? window.MSAI.Markdown.parse(msg.content) : window.MSAI.Security.sanitizeHTML(msg.content)}</div>
      </div>
    `;

    return row;
  },

  createTypingNode() {
    const row = document.createElement('div');
    row.className = 'message-row ai';
    row.innerHTML = `
      <div class="message-avatar">M</div>
      <div class="message-body">
        <div class="message-header"><span>MSAI</span></div>
        <div class="message-content" style="color: var(--text-muted); font-style: italic;">MSAI is thinking...</div>
      </div>
    `;
    return row;
  }
};
