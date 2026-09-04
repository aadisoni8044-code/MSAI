/**
 * Chat Controller & Conversation Flow
 */
import { conversations } from './conversations.js';
import { generateResponse, stopGeneration } from './api.js';
import { createMessageElement, createTypingIndicator } from './messages.js';
import { validateMessage } from './validation.js';
import { notifications } from './notifications.js';
import { events } from './events.js';
import { storage } from './storage.js';
import { i18n } from './language.js';

class ChatController {
  constructor() {
    this.container = null;
    this.listElement = null;
    this.welcomeElement = null;
    this.composerTextarea = null;
    this.sendButton = null;
    this.stopButton = null;
    this.isGenerating = false;
  }

  init() {
    this.container = document.getElementById('chatContainer');
    this.listElement = document.getElementById('messagesList');
    this.welcomeElement = document.getElementById('chatWelcome');
    this.composerTextarea = document.getElementById('composerTextarea');
    this.sendButton = document.getElementById('btnComposerSend');
    this.stopButton = document.getElementById('btnComposerStop');

    this.setupComposerEvents();
    this.setupSuggestionEvents();

    events.on('conversation:active-changed', () => this.renderActiveChat());
    events.on('conversations:cleared', () => this.renderActiveChat());
    events.on('api:loading', loading => this.setGeneratingState(loading));

    this.renderActiveChat();
  }

  setupComposerEvents() {
    // Auto-grow textarea & toggle send button
    this.composerTextarea.addEventListener('input', () => {
      this.autoGrowTextarea();
      const hasText = this.composerTextarea.value.trim().length > 0;
      this.sendButton.classList.toggle('active', hasText && !this.isGenerating);
    });

    // Enter to send (Shift+Enter for newline)
    this.composerTextarea.addEventListener('keydown', (e) => {
      const settings = storage.get('msai_settings', { enterToSend: true });
      if (e.key === 'Enter' && !e.shiftKey && settings.enterToSend) {
        e.preventDefault();
        this.handleSend();
      }
    });

    this.sendButton.addEventListener('click', () => this.handleSend());
    if (this.stopButton) {
      this.stopButton.addEventListener('click', () => stopGeneration());
    }

    // Chat / Cowork mode toggle
    document.querySelectorAll('.mode-toggle-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.mode-toggle-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
      });
    });

    // Attachment placeholder
    const btnAttach = document.getElementById('btnComposerAttach');
    if (btnAttach) {
      btnAttach.addEventListener('click', () => {
        notifications.info('Attachment support is ready in UI (placeholder).');
      });
    }

    // Voice input placeholder
    const btnVoice = document.getElementById('btnComposerVoice');
    if (btnVoice) {
      btnVoice.addEventListener('click', () => {
        notifications.info('Voice dictation support is ready in UI (placeholder).');
      });
    }
  }

  setupSuggestionEvents() {
    document.querySelectorAll('.suggestion-pill').forEach(pill => {
      pill.addEventListener('click', () => {
        const prompt = pill.getAttribute('data-prompt') || pill.textContent.trim();
        this.composerTextarea.value = prompt;
        this.autoGrowTextarea();
        this.sendButton.classList.add('active');
        this.composerTextarea.focus();
      });
    });
  }

  autoGrowTextarea() {
    this.composerTextarea.style.height = 'auto';
    this.composerTextarea.style.height = Math.min(this.composerTextarea.scrollHeight, 180) + 'px';
  }

  renderActiveChat() {
    const chat = conversations.getActive();
    if (!chat || chat.messages.length === 0) {
      this.welcomeElement.classList.remove('hidden');
      this.listElement.innerHTML = '';
      return;
    }

    this.welcomeElement.classList.add('hidden');
    this.listElement.innerHTML = '';

    chat.messages.forEach(msg => {
      const el = createMessageElement(msg, (action, m, payload) => this.handleMessageAction(action, m, payload));
      this.listElement.appendChild(el);
    });

    this.scrollToBottom();
  }

  async handleSend() {
    if (this.isGenerating) return;

    const validation = validateMessage(this.composerTextarea.value);
    if (!validation.valid) return;

    const content = validation.text;
    this.composerTextarea.value = '';
    this.autoGrowTextarea();
    this.sendButton.classList.remove('active');

    let activeChat = conversations.getActive();
    if (!activeChat) {
      activeChat = conversations.create(content.slice(0, 32));
    }

    // Add user message
    conversations.addMessage(activeChat.id, 'user', content);
    this.renderActiveChat();

    // Trigger AI response
    await this.fetchAIResponse(activeChat.id);
  }

  async fetchAIResponse(chatId) {
    const chat = conversations.getAll().find(c => c.id === chatId);
    if (!chat) return;

    // Show typing indicator
    const typingIndicator = createTypingIndicator();
    this.listElement.appendChild(typingIndicator);
    this.scrollToBottom();

    // Format history for Gemini API
    const history = chat.messages.map(m => ({
      role: m.role === 'user' ? 'user' : 'model',
      parts: [{ text: m.content }]
    }));

    const settings = storage.get('msai_settings', {});
    const model = settings.model || 'gemini-3.8-flash';
    const temperature = settings.temperature ?? 0.7;

    const result = await generateResponse(history, { model, temperature });

    // Remove typing indicator
    if (typingIndicator.parentNode) {
      typingIndicator.parentNode.removeChild(typingIndicator);
    }

    if (result.success) {
      conversations.addMessage(chatId, 'assistant', result.text);
      this.renderActiveChat();
    } else if (!result.aborted) {
      notifications.error(result.error || i18n.get('notifications.apiError'));
    }
  }

  async handleMessageAction(action, message, payload) {
    const activeChat = conversations.getActive();
    if (!activeChat) return;

    if (action === 'delete') {
      conversations.deleteMessage(activeChat.id, message.id);
      this.renderActiveChat();
      notifications.info('Message deleted');
    } else if (action === 'edit') {
      conversations.updateMessage(activeChat.id, message.id, payload);
      this.renderActiveChat();
      // Resend from this point
      await this.fetchAIResponse(activeChat.id);
    } else if (action === 'regenerate') {
      // Find the user message before this assistant message
      await this.fetchAIResponse(activeChat.id);
    }
  }

  setGeneratingState(isGenerating) {
    this.isGenerating = isGenerating;
    if (this.stopButton) {
      this.stopButton.classList.toggle('hidden', !isGenerating);
    }
    this.sendButton.classList.toggle('hidden', isGenerating);
  }

  scrollToBottom() {
    const settings = storage.get('msai_settings', { autoScroll: true });
    if (settings.autoScroll && this.container) {
      this.container.scrollTop = this.container.scrollHeight;
    }
  }
}

export const chatController = new ChatController();
