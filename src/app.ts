import { marked } from 'marked';
import hljs from 'highlight.js';
import modesData from '../modes.json';
import { ModeConfig, geminiService } from './gemini-service';
import { firebaseService, ChatSession, ChatMessage, UserProfile } from './firebase-service';
import { saveFirebaseConfig } from './firebase-config';

// Configure marked with highlight.js syntax highlighting
marked.setOptions({
  renderer: new marked.Renderer(),
  gfm: true,
  breaks: true,
});

class MSAIApp {
  private modes: ModeConfig[] = [];
  private activeMode: ModeConfig;
  private currentSession: ChatSession | null = null;
  private isGenerating: boolean = false;

  // DOM Elements
  private modeDropdown = document.getElementById('modeDropdown') as HTMLSelectElement;
  private sidebarModePills = document.getElementById('sidebarModePills') as HTMLDivElement;
  private modeBadge = document.getElementById('modeBadge') as HTMLDivElement;
  private modeDescription = document.getElementById('modeDescription') as HTMLParagraphElement;
  private historyList = document.getElementById('historyList') as HTMLDivElement;
  private chatMessages = document.getElementById('chatMessages') as HTMLDivElement;
  private chatForm = document.getElementById('chatForm') as HTMLFormElement;
  private messageInput = document.getElementById('messageInput') as HTMLTextAreaElement;
  private sendBtn = document.getElementById('sendBtn') as HTMLButtonElement;
  private newChatBtn = document.getElementById('newChatBtn') as HTMLButtonElement;
  private sidebar = document.getElementById('sidebar') as HTMLElement;
  private menuToggleBtn = document.getElementById('menuToggleBtn') as HTMLButtonElement;

  // Settings & Auth Modal Elements
  private settingsBtn = document.getElementById('settingsBtn') as HTMLButtonElement;
  private settingsModal = document.getElementById('settingsModal') as HTMLDivElement;
  private closeSettingsModal = document.getElementById('closeSettingsModal') as HTMLButtonElement;
  private cancelSettingsBtn = document.getElementById('cancelSettingsBtn') as HTMLButtonElement;
  private saveSettingsBtn = document.getElementById('saveSettingsBtn') as HTMLButtonElement;
  private geminiApiKeyInput = document.getElementById('geminiApiKey') as HTMLInputElement;
  private firebaseConfigJsonInput = document.getElementById('firebaseConfigJson') as HTMLTextAreaElement;

  private authBtn = document.getElementById('authBtn') as HTMLButtonElement;
  private authModal = document.getElementById('authModal') as HTMLDivElement;
  private closeAuthModal = document.getElementById('closeAuthModal') as HTMLButtonElement;
  private googleAuthBtn = document.getElementById('googleAuthBtn') as HTMLButtonElement;
  private guestAuthBtn = document.getElementById('guestAuthBtn') as HTMLButtonElement;
  private userAvatar = document.getElementById('userAvatar') as HTMLDivElement;
  private userName = document.getElementById('userName') as HTMLSpanElement;
  private userStatus = document.getElementById('userStatus') as HTMLSpanElement;

  constructor() {
    this.modes = modesData.modes;
    const defaultModeId = modesData.defaultMode || 'general';
    this.activeMode = this.modes.find(m => m.id === defaultModeId) || this.modes[0];

    this.init();
  }

  private async init() {
    this.renderModeSelectors();
    this.setupEventListeners();
    this.setupAuthListener();

    // Auto-adjust textarea height
    this.messageInput.addEventListener('input', () => {
      this.messageInput.style.height = 'auto';
      this.messageInput.style.height = `${Math.min(this.messageInput.scrollHeight, 160)}px`;
    });

    // Start a fresh session
    await this.createNewSession();
  }

  private setupAuthListener() {
    firebaseService.onAuthChange(async (user: UserProfile | null) => {
      this.updateUserUI(user);
      await this.loadChatHistory();
    });
  }

  private updateUserUI(user: UserProfile | null) {
    if (user) {
      this.userName.textContent = user.displayName || 'User';
      this.userAvatar.textContent = (user.displayName || 'U').charAt(0).toUpperCase();
      this.userStatus.textContent = user.isAnonymous ? 'Guest Account' : user.email || 'Authenticated';
      this.authBtn.textContent = user.isAnonymous ? 'Sign In / Account' : 'Sign Out';
    } else {
      this.userName.textContent = 'Guest User';
      this.userAvatar.textContent = 'G';
      this.userStatus.textContent = 'Local Mode';
      this.authBtn.textContent = 'Sign In / Account';
    }
  }

  private renderModeSelectors() {
    // Populate Top Header Dropdown
    this.modeDropdown.innerHTML = '';
    this.modes.forEach(mode => {
      const option = document.createElement('option');
      option.value = mode.id;
      option.textContent = mode.name;
      if (mode.id === this.activeMode.id) {
        option.selected = true;
      }
      this.modeDropdown.appendChild(option);
    });

    // Populate Sidebar Mode Quick Switcher Pills
    this.sidebarModePills.innerHTML = '';
    this.modes.forEach(mode => {
      const pill = document.createElement('button');
      pill.className = `mode-pill ${mode.id === this.activeMode.id ? 'active' : ''}`;
      pill.innerHTML = `<span>${this.getModeSymbol(mode.icon)}</span> <span>${mode.name}</span>`;
      pill.addEventListener('click', () => this.switchMode(mode.id));
      this.sidebarModePills.appendChild(pill);
    });

    this.updateModeBanner();
  }

  private getModeSymbol(iconName: string): string {
    switch (iconName) {
      case 'code': return '💻';
      case 'pen-tool': return '✍️';
      case 'calculator': return '📐';
      case 'bar-chart-2': return '📊';
      default: return '🤖';
    }
  }

  private updateModeBanner() {
    this.modeBadge.textContent = `${this.getModeSymbol(this.activeMode.icon)} ${this.activeMode.name}`;
    this.modeDescription.textContent = this.activeMode.description;
  }

  private switchMode(modeId: string) {
    const targetMode = this.modes.find(m => m.id === modeId);
    if (!targetMode) return;

    this.activeMode = targetMode;
    this.modeDropdown.value = modeId;

    // Update active pill UI
    const pills = this.sidebarModePills.querySelectorAll('.mode-pill');
    pills.forEach((pill, idx) => {
      if (this.modes[idx].id === modeId) {
        pill.classList.add('active');
      } else {
        pill.classList.remove('active');
      }
    });

    this.updateModeBanner();

    // If current session is empty or new, set modeId
    if (this.currentSession && this.currentSession.messages.length <= 1) {
      this.currentSession.modeId = modeId;
      if (this.currentSession.messages[0]?.role === 'model') {
        this.currentSession.messages[0].content = this.activeMode.welcomeMessage;
        this.renderMessages();
      }
    }
  }

  private setupEventListeners() {
    // Mode Select Dropdown Change
    this.modeDropdown.addEventListener('change', (e) => {
      this.switchMode((e.target as HTMLSelectElement).value);
    });

    // New Chat Button
    this.newChatBtn.addEventListener('click', () => this.createNewSession());

    // Toggle Sidebar Mobile
    this.menuToggleBtn.addEventListener('click', () => {
      this.sidebar.classList.toggle('open');
    });

    // Chat Form Submission
    this.chatForm.addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleSendMessage();
    });

    // Enter Key in Textarea (Shift + Enter for new line)
    this.messageInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this.handleSendMessage();
      }
    });

    // Settings Modal Listeners
    this.settingsBtn.addEventListener('click', () => {
      this.geminiApiKeyInput.value = geminiService.getApiKey();
      this.settingsModal.classList.add('open');
    });

    this.closeSettingsModal.addEventListener('click', () => this.settingsModal.classList.remove('open'));
    this.cancelSettingsBtn.addEventListener('click', () => this.settingsModal.classList.remove('open'));

    this.saveSettingsBtn.addEventListener('click', () => {
      const apiKey = this.geminiApiKeyInput.value.trim();
      geminiService.setApiKey(apiKey);

      const firebaseJson = this.firebaseConfigJsonInput.value.trim();
      if (firebaseJson) {
        try {
          const parsed = JSON.parse(firebaseJson);
          saveFirebaseConfig(parsed);
          firebaseService.initFirebase();
        } catch {
          alert('Invalid Firebase Config JSON format.');
          return;
        }
      }

      this.settingsModal.classList.remove('open');
    });

    // Auth Modal Listeners
    this.authBtn.addEventListener('click', async () => {
      if (firebaseService.currentUser && !firebaseService.currentUser.isAnonymous) {
        await firebaseService.logout();
        await this.loadChatHistory();
      } else {
        this.authModal.classList.add('open');
      }
    });

    this.closeAuthModal.addEventListener('click', () => this.authModal.classList.remove('open'));

    this.googleAuthBtn.addEventListener('click', async () => {
      try {
        await firebaseService.loginWithGoogle();
        this.authModal.classList.remove('open');
      } catch (err: any) {
        alert(`Google Auth Error: ${err.message || err}`);
      }
    });

    this.guestAuthBtn.addEventListener('click', async () => {
      await firebaseService.loginAnonymously();
      this.authModal.classList.remove('open');
    });
  }

  private async createNewSession() {
    const newSession: ChatSession = {
      id: `session_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      title: 'New Conversation',
      modeId: this.activeMode.id,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      messages: [
        {
          id: `msg_${Date.now()}`,
          role: 'model',
          content: this.activeMode.welcomeMessage,
          timestamp: Date.now(),
          modeId: this.activeMode.id
        }
      ]
    };

    this.currentSession = newSession;
    this.renderMessages();
    await firebaseService.saveChatSession(newSession);
    await this.loadChatHistory();
  }

  private async loadChatHistory() {
    const sessions = await firebaseService.loadUserSessions();
    this.historyList.innerHTML = '';

    if (sessions.length === 0) {
      this.historyList.innerHTML = `<div class="mode-desc" style="padding: 8px;">No previous chats</div>`;
      return;
    }

    sessions.forEach(session => {
      const item = document.createElement('div');
      item.className = `history-item ${this.currentSession?.id === session.id ? 'active' : ''}`;

      const titleSpan = document.createElement('span');
      titleSpan.className = 'history-title';
      titleSpan.textContent = session.title || 'Conversation';

      const deleteBtn = document.createElement('button');
      deleteBtn.className = 'delete-session-btn';
      deleteBtn.title = 'Delete Chat';
      deleteBtn.innerHTML = '🗑️';
      deleteBtn.addEventListener('click', async (e) => {
        e.stopPropagation();
        if (confirm('Delete this chat session?')) {
          await firebaseService.deleteChatSession(session.id);
          if (this.currentSession?.id === session.id) {
            await this.createNewSession();
          } else {
            await this.loadChatHistory();
          }
        }
      });

      item.appendChild(titleSpan);
      item.appendChild(deleteBtn);

      item.addEventListener('click', () => {
        this.currentSession = session;
        this.switchMode(session.modeId || 'general');
        this.renderMessages();
        this.loadChatHistory();
        if (window.innerWidth <= 768) {
          this.sidebar.classList.remove('open');
        }
      });

      this.historyList.appendChild(item);
    });
  }

  private async handleSendMessage() {
    if (this.isGenerating || !this.currentSession) return;

    const userText = this.messageInput.value.trim();
    if (!userText) return;

    // Reset input
    this.messageInput.value = '';
    this.messageInput.style.height = 'auto';

    // Set title if it's the first user prompt
    if (this.currentSession.messages.filter(m => m.role === 'user').length === 0) {
      this.currentSession.title = userText.length > 28 ? userText.substring(0, 28) + '...' : userText;
    }

    // Add user message
    const userMsg: ChatMessage = {
      id: `msg_${Date.now()}`,
      role: 'user',
      content: userText,
      timestamp: Date.now()
    };
    this.currentSession.messages.push(userMsg);

    // Create placeholder response message for streaming
    const aiMsgId = `msg_${Date.now() + 1}`;
    const aiMsg: ChatMessage = {
      id: aiMsgId,
      role: 'model',
      content: '...',
      timestamp: Date.now(),
      modeId: this.activeMode.id
    };
    this.currentSession.messages.push(aiMsg);

    this.isGenerating = true;
    this.sendBtn.disabled = true;
    this.renderMessages();

    // Call Gemini API with live streaming updates
    try {
      const fullResponse = await geminiService.generateResponse(
        this.currentSession.messages.slice(0, -1), // exclude loading placeholder
        this.activeMode,
        (partialText) => {
          aiMsg.content = partialText;
          this.updateMessageBubble(aiMsgId, partialText);
        }
      );
      aiMsg.content = fullResponse;
    } catch (err: any) {
      aiMsg.content = `Error: ${err?.message || err}`;
    } finally {
      this.isGenerating = false;
      this.sendBtn.disabled = false;
      this.currentSession.updatedAt = Date.now();
      await firebaseService.saveChatSession(this.currentSession);
      await this.loadChatHistory();
    }
  }

  private renderMessages() {
    this.chatMessages.innerHTML = '';
    if (!this.currentSession) return;

    this.currentSession.messages.forEach(msg => {
      const msgRow = document.createElement('div');
      msgRow.className = `message-row ${msg.role === 'user' ? 'user-row' : 'model-row'}`;
      msgRow.id = `row_${msg.id}`;

      const avatar = document.createElement('div');
      avatar.className = 'message-avatar';
      avatar.textContent = msg.role === 'user' ? 'U' : this.getModeSymbol(this.activeMode.icon);

      const bubble = document.createElement('div');
      bubble.className = 'message-bubble';
      bubble.id = `bubble_${msg.id}`;

      if (msg.role === 'model' && msg.content === '...') {
        bubble.innerHTML = `<div class="typing-indicator"><div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div></div>`;
      } else {
        bubble.innerHTML = this.renderMarkdown(msg.content);
      }

      msgRow.appendChild(avatar);
      msgRow.appendChild(bubble);
      this.chatMessages.appendChild(msgRow);
    });

    this.scrollToBottom();
    this.applySyntaxHighlighting();
  }

  private updateMessageBubble(msgId: string, content: string) {
    const bubble = document.getElementById(`bubble_${msgId}`);
    if (bubble) {
      bubble.innerHTML = this.renderMarkdown(content);
      this.applySyntaxHighlighting();
      this.scrollToBottom();
    }
  }

  private renderMarkdown(content: string): string {
    try {
      return marked.parse(content) as string;
    } catch {
      return content;
    }
  }

  private applySyntaxHighlighting() {
    document.querySelectorAll('pre code').forEach((block) => {
      hljs.highlightElement(block as HTMLElement);
    });
  }

  private scrollToBottom() {
    this.chatMessages.scrollTop = this.chatMessages.scrollHeight;
  }
}

// Initialize App on DOM Content Loaded
document.addEventListener('DOMContentLoaded', () => {
  new MSAIApp();
});
