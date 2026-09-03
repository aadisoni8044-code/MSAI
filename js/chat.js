import { conversationManager } from './conversations.js';
import { apiService } from './api.js';
import { createMessageElement } from './messages.js';
import { showNotification } from './notifications.js';

export class ChatEngine {
  constructor(messagesContainer, composerInput, sendBtn) {
    this.messagesContainer = messagesContainer;
    this.composerInput = composerInput;
    this.sendBtn = sendBtn;
    this.isGenerating = false;
  }

  renderCurrentChat() {
    const activeConv = conversationManager.getActiveConversation();
    this.messagesContainer.innerHTML = '';

    if (!activeConv || activeConv.messages.length === 0) {
      this.messagesContainer.innerHTML = `
        <div class="welcome-screen" id="welcome-screen">
          <img src="assets/logo.svg" class="welcome-logo" alt="MSAI">
          <h1 class="welcome-title" data-i18n="welcome_title">How can I help you today?</h1>
          <p class="welcome-subtitle" data-i18n="welcome_subtitle">Select a suggestion below or type your prompt to start a conversation.</p>
          <div class="prompt-suggestions">
            <div class="suggestion-card" onclick="document.getElementById('composer-textarea').value='Write an engaging blog post about modern AI applications'; document.getElementById('composer-textarea').focus();">
              <div class="suggestion-header">✏️ Write something</div>
              <div class="suggestion-desc">Write an engaging blog post about modern AI applications</div>
            </div>
            <div class="suggestion-card" onclick="document.getElementById('composer-textarea').value='Explain quantum computing in simple terms'; document.getElementById('composer-textarea').focus();">
              <div class="suggestion-header">💡 Explain a topic</div>
              <div class="suggestion-desc">Explain quantum computing in simple terms</div>
            </div>
            <div class="suggestion-card" onclick="document.getElementById('composer-textarea').value='Write a JavaScript function to filter an array of objects'; document.getElementById('composer-textarea').focus();">
              <div class="suggestion-header">💻 Help me code</div>
              <div class="suggestion-desc">Write a JavaScript function to filter an array of objects</div>
            </div>
            <div class="suggestion-card" onclick="document.getElementById('composer-textarea').value='5 startup ideas combining AI and web development'; document.getElementById('composer-textarea').focus();">
              <div class="suggestion-header">🚀 Brainstorm ideas</div>
              <div class="suggestion-desc">5 startup ideas combining AI and web development</div>
            </div>
          </div>
        </div>
      `;
      return;
    }

    activeConv.messages.forEach(msg => {
      const msgEl = createMessageElement(msg);
      this.messagesContainer.appendChild(msgEl);
    });

    this.scrollToBottom();
  }

  async sendUserMessage(text) {
    if (this.isGenerating || !text.trim()) return;

    let activeConv = conversationManager.getActiveConversation();
    if (!activeConv) {
      activeConv = conversationManager.createConversation();
    }

    conversationManager.addMessage(activeConv.id, 'user', text);
    this.renderCurrentChat();
    this.composerInput.value = '';
    this.composerInput.style.height = 'auto';

    this.isGenerating = true;
    this.sendBtn.disabled = true;

    const typingIndicator = this.showTypingIndicator();

    try {
      const responseText = await apiService.generateResponse(text, activeConv.messages);
      this.removeTypingIndicator(typingIndicator);
      conversationManager.addMessage(activeConv.id, 'model', responseText);
      this.renderCurrentChat();
    } catch (err) {
      this.removeTypingIndicator(typingIndicator);
      showNotification(err.message || 'Failed to generate AI response', 'error');
    } finally {
      this.isGenerating = false;
      this.sendBtn.disabled = false;
    }
  }

  showTypingIndicator() {
    const indicator = document.createElement('div');
    indicator.className = 'message-row model typing-row';
    indicator.innerHTML = `
      <img src="assets/avatar-ai.svg" class="message-avatar" alt="AI">
      <div class="message-bubble">
        <div class="typing-indicator">
          <div class="typing-dot"></div>
          <div class="typing-dot"></div>
          <div class="typing-dot"></div>
        </div>
      </div>
    `;
    this.messagesContainer.appendChild(indicator);
    this.scrollToBottom();
    return indicator;
  }

  removeTypingIndicator(indicator) {
    if (indicator && indicator.parentNode) {
      indicator.parentNode.removeChild(indicator);
    }
  }

  scrollToBottom() {
    this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
  }
}