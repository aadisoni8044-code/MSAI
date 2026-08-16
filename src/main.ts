import { authService, UserProfile } from './auth';
import { chatService, ChatSession } from './chat';
import { geminiApi } from './api';
import config from './config';

class AppUI {
  private currentScreen: 'onboarding' | 'auth' | 'chat' = 'onboarding';
  private authMode: 'signin' | 'signup' = 'signin';
  private currentSlideIndex: number = 0;
  private isWebSearchEnabled: boolean = false;
  private isGenerating: boolean = false;

  constructor() {
    this.initEventListeners();
    this.initAuthObserver();
  }

  private initAuthObserver() {
    authService.onAuthStateChanged((user) => {
      if (user) {
        this.updateUserUI(user);
        this.switchScreen('chat');
        this.loadChatHistory(user.uid);
      } else {
        // Unauthenticated -> default to onboarding or auth
      }
    });
  }

  private switchScreen(screen: 'onboarding' | 'auth' | 'chat') {
    this.currentScreen = screen;
    document.querySelectorAll('.screen').forEach(s => s.classList.add('hidden'));

    const target = document.getElementById(`${screen}-screen`);
    if (target) {
      target.classList.remove('hidden');
      target.classList.add('active');
    }
  }

  private initEventListeners() {
    // 1. Onboarding Screen
    const btnGetStartedOnboarding = document.getElementById('btn-get-started-onboarding');
    btnGetStartedOnboarding?.addEventListener('click', () => {
      this.switchScreen('auth');
    });

    const dots = document.querySelectorAll('#carousel-dots .dot');
    dots.forEach((dot) => {
      dot.addEventListener('click', (e) => {
        const idx = parseInt((e.currentTarget as HTMLElement).getAttribute('data-index') || '0', 10);
        this.setSlide(idx);
      });
    });

    // 2. Auth Screen
    const authSwitchBtn = document.getElementById('auth-switch-btn');
    authSwitchBtn?.addEventListener('click', (e) => {
      e.preventDefault();
      this.toggleAuthMode();
    });

    const btnTogglePassword = document.getElementById('btn-toggle-password');
    btnTogglePassword?.addEventListener('click', () => {
      const passInput = document.getElementById('auth-password') as HTMLInputElement;
      const eyeShow = document.getElementById('eye-icon-show');
      const eyeHide = document.getElementById('eye-icon-hide');

      if (passInput.type === 'password') {
        passInput.type = 'text';
        eyeShow?.classList.add('hidden');
        eyeHide?.classList.remove('hidden');
      } else {
        passInput.type = 'password';
        eyeHide?.classList.add('hidden');
        eyeShow?.classList.remove('hidden');
      }
    });

    const authForm = document.getElementById('auth-form');
    authForm?.addEventListener('submit', async (e) => {
      e.preventDefault();
      await this.handleAuthSubmit();
    });

    const btnGoogleAuth = document.getElementById('btn-google-auth');
    btnGoogleAuth?.addEventListener('click', async () => {
      try {
        await authService.signInWithGoogle();
      } catch (err: any) {
        this.showAuthError(err.message || 'Google sign-in failed');
      }
    });

    const btnAppleAuth = document.getElementById('btn-apple-auth');
    btnAppleAuth?.addEventListener('click', async () => {
      try {
        await authService.signInWithApple();
      } catch (err: any) {
        this.showAuthError(err.message || 'Apple sign-in failed');
      }
    });

    // Topbar guest login/signup triggers
    document.getElementById('btn-topbar-signin')?.addEventListener('click', () => {
      this.authMode = 'signin';
      this.renderAuthMode();
      this.switchScreen('auth');
    });
    document.getElementById('btn-topbar-signup')?.addEventListener('click', () => {
      this.authMode = 'signup';
      this.renderAuthMode();
      this.switchScreen('auth');
    });

    // 3. Main Chat Interface
    // Sidebar toggle
    const btnToggleSidebar = document.getElementById('btn-toggle-sidebar');
    const sidebar = document.getElementById('chat-sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    const btnCloseSidebar = document.getElementById('btn-close-sidebar');

    const toggleSidebar = () => {
      sidebar?.classList.toggle('open');
      overlay?.classList.toggle('hidden');
    };

    btnToggleSidebar?.addEventListener('click', toggleSidebar);
    btnCloseSidebar?.addEventListener('click', toggleSidebar);
    overlay?.addEventListener('click', toggleSidebar);

    // Logout
    document.getElementById('btn-logout')?.addEventListener('click', async () => {
      await authService.signOut();
      this.switchScreen('auth');
    });

    // New Chat button
    document.getElementById('btn-new-chat')?.addEventListener('click', () => {
      const user = authService.getCurrentUser();
      const userId = user ? user.uid : 'guest';
      chatService.createNewChat(userId);
      this.renderCurrentChat();
      this.renderSidebarChats();
    });

    // Search Toggle Buttons
    const btnSearchEmpty = document.getElementById('btn-search-toggle-empty');
    const btnSearchThread = document.getElementById('btn-search-toggle-thread');

    const toggleSearch = () => {
      this.isWebSearchEnabled = !this.isWebSearchEnabled;
      [btnSearchEmpty, btnSearchThread].forEach(btn => {
        if (this.isWebSearchEnabled) {
          btn?.classList.add('active');
        } else {
          btn?.classList.remove('active');
        }
      });
    };

    btnSearchEmpty?.addEventListener('click', toggleSearch);
    btnSearchThread?.addEventListener('click', toggleSearch);

    // Quick Action Starters
    document.querySelectorAll('.quick-action-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const action = (e.currentTarget as HTMLElement).getAttribute('data-action');
        const item = config.quickActions.find(q => q.id === action);
        if (item) {
          const textarea = document.getElementById('empty-chat-input') as HTMLTextAreaElement;
          if (textarea) {
            textarea.value = item.prompt;
            textarea.focus();
          }
        }
      });
    });

    // Send Buttons & Keyboard enter
    const btnSendEmpty = document.getElementById('btn-send-empty');
    const btnSendThread = document.getElementById('btn-send-thread');
    const emptyInput = document.getElementById('empty-chat-input') as HTMLTextAreaElement;
    const threadInput = document.getElementById('thread-chat-input') as HTMLTextAreaElement;

    btnSendEmpty?.addEventListener('click', () => this.handleSendMessage(emptyInput));
    btnSendThread?.addEventListener('click', () => this.handleSendMessage(threadInput));

    emptyInput?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this.handleSendMessage(emptyInput);
      }
    });

    threadInput?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this.handleSendMessage(threadInput);
      }
    });
  }

  private setSlide(index: number) {
    this.currentSlideIndex = index;
    const slides = config.onboarding.slides;
    if (slides[index]) {
      const headline = document.getElementById('onboarding-headline');
      const subtext = document.getElementById('onboarding-subtext');
      if (headline) headline.textContent = slides[index].headline;
      if (subtext) subtext.textContent = slides[index].subtext;
    }

    const dots = document.querySelectorAll('#carousel-dots .dot');
    dots.forEach((dot, idx) => {
      if (idx === index) {
        dot.classList.add('active');
      } else {
        dot.classList.remove('active');
      }
    });
  }

  private toggleAuthMode() {
    this.authMode = this.authMode === 'signin' ? 'signup' : 'signin';
    this.renderAuthMode();
  }

  private renderAuthMode() {
    const authTitle = document.getElementById('auth-title');
    const btnSubmit = document.getElementById('btn-auth-submit');
    const switchText = document.getElementById('auth-switch-text');
    const switchBtn = document.getElementById('auth-switch-btn');
    const errorBox = document.getElementById('auth-error-box');

    errorBox?.classList.add('hidden');

    if (this.authMode === 'signin') {
      if (authTitle) authTitle.textContent = 'Sign In To Your Account.';
      if (btnSubmit) btnSubmit.textContent = 'Get Started';
      if (switchText) switchText.textContent = "Don't have an account?";
      if (switchBtn) switchBtn.textContent = 'Sign Up';
    } else {
      if (authTitle) authTitle.textContent = 'Sign up To Your Account.';
      if (btnSubmit) btnSubmit.textContent = 'Create Account';
      if (switchText) switchText.textContent = 'Already have an account?';
      if (switchBtn) switchBtn.textContent = 'Sign In';
    }
  }

  private showAuthError(msg: string) {
    const errorBox = document.getElementById('auth-error-box');
    if (errorBox) {
      errorBox.textContent = msg;
      errorBox.classList.remove('hidden');
    }
  }

  private async handleAuthSubmit() {
    const emailInput = document.getElementById('auth-email') as HTMLInputElement;
    const passwordInput = document.getElementById('auth-password') as HTMLInputElement;
    const email = emailInput.value.trim();
    const pass = passwordInput.value.trim();

    try {
      if (this.authMode === 'signin') {
        await authService.signInWithEmail(email, pass);
      } else {
        await authService.signUpWithEmail(email, pass);
      }
    } catch (err: any) {
      this.showAuthError(err.message || 'Authentication failed');
    }
  }

  private updateUserUI(user: UserProfile) {
    const userDisplayName = document.getElementById('user-display-name');
    const userEmailText = document.getElementById('user-email-text');
    const userAvatar = document.getElementById('user-avatar');
    const topbarUserAvatar = document.getElementById('topbar-user-avatar');

    const initial = (user.displayName || user.email || 'U').charAt(0).toUpperCase();

    if (userDisplayName) userDisplayName.textContent = user.displayName || 'User';
    if (userEmailText) userEmailText.textContent = user.email || '';
    if (userAvatar) userAvatar.textContent = initial;
    if (topbarUserAvatar) topbarUserAvatar.textContent = initial;
  }

  private async loadChatHistory(userId: string) {
    await chatService.loadUserChats(userId);
    this.renderSidebarChats();
    this.renderCurrentChat();
  }

  private renderSidebarChats() {
    const listContainer = document.getElementById('sidebar-chat-list');
    if (!listContainer) return;

    listContainer.innerHTML = '';
    const chats = chatService.getChats();
    const activeChat = chatService.getActiveChat();

    chats.forEach(chat => {
      const item = document.createElement('div');
      item.className = `chat-history-item ${activeChat && activeChat.id === chat.id ? 'active' : ''}`;

      const titleSpan = document.createElement('span');
      titleSpan.className = 'history-item-title';
      titleSpan.textContent = chat.title || 'Conversation';

      const delBtn = document.createElement('button');
      delBtn.className = 'btn-delete-chat';
      delBtn.title = 'Delete chat';
      delBtn.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>`;

      delBtn.addEventListener('click', async (e) => {
        e.stopPropagation();
        const user = authService.getCurrentUser();
        await chatService.deleteChat(user ? user.uid : 'guest', chat.id);
        this.renderSidebarChats();
        this.renderCurrentChat();
      });

      item.appendChild(titleSpan);
      item.appendChild(delBtn);

      item.addEventListener('click', () => {
        chatService.setActiveChatId(chat.id);
        this.renderSidebarChats();
        this.renderCurrentChat();
      });

      listContainer.appendChild(item);
    });
  }

  private renderCurrentChat() {
    const activeChat = chatService.getActiveChat();
    const emptyStateView = document.getElementById('empty-state-view');
    const activeThreadView = document.getElementById('active-thread-view');
    const stickyInputContainer = document.getElementById('sticky-input-container');
    const emptyStateMicrocopy = document.getElementById('empty-state-microcopy');
    const messagesScrollArea = document.getElementById('messages-scroll-area');

    if (!activeChat || activeChat.messages.length === 0) {
      // Empty state mode
      emptyStateView?.classList.remove('hidden');
      activeThreadView?.classList.add('hidden');
      stickyInputContainer?.classList.add('hidden');
      emptyStateMicrocopy?.classList.remove('hidden');
    } else {
      // Active conversation thread mode
      emptyStateView?.classList.add('hidden');
      activeThreadView?.classList.remove('hidden');
      stickyInputContainer?.classList.remove('hidden');
      emptyStateMicrocopy?.classList.add('hidden');

      if (messagesScrollArea) {
        messagesScrollArea.innerHTML = '';
        activeChat.messages.forEach(msg => {
          this.appendMessageBubble(messagesScrollArea, msg.role, msg.content);
        });
        messagesScrollArea.scrollTop = messagesScrollArea.scrollHeight;
      }
    }
  }

  private appendMessageBubble(container: HTMLElement, role: 'user' | 'model', content: string): HTMLElement {
    const row = document.createElement('div');
    row.className = `message-row ${role}`;

    if (role === 'model') {
      const avatar = document.createElement('div');
      avatar.className = 'message-avatar';
      avatar.innerHTML = `<img src="/logo.svg" alt="MS AI" />`;
      row.appendChild(avatar);
    }

    const bubble = document.createElement('div');
    bubble.className = 'message-bubble';
    bubble.innerHTML = this.formatMarkdown(content);
    row.appendChild(bubble);

    container.appendChild(row);
    container.scrollTop = container.scrollHeight;
    return bubble;
  }

  private formatMarkdown(text: string): string {
    // Simple markdown codeblock & bold text formatter
    let formatted = text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');

    // Code blocks ```code```
    formatted = formatted.replace(/```([\s\S]*?)```/g, (_match, code) => {
      return `<pre><code>${code.trim()}</code></pre>`;
    });

    // Inline code `code`
    formatted = formatted.replace(/`([^`]+)`/g, '<code>$1</code>');

    // Bold **text**
    formatted = formatted.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');

    // Paragraph breaks
    formatted = formatted.split('\n\n').map(p => `<p>${p.replace(/\n/g, '<br/>')}</p>`).join('');

    return formatted;
  }

  private async handleSendMessage(inputElement: HTMLTextAreaElement) {
    const text = inputElement.value.trim();
    if (!text || this.isGenerating) return;

    inputElement.value = '';
    this.isGenerating = true;

    const user = authService.getCurrentUser();
    const userId = user ? user.uid : 'guest';

    let activeChat = chatService.getActiveChat();
    if (!activeChat) {
      // Auto generate title from prompt
      const title = text.length > 28 ? text.slice(0, 28) + '...' : text;
      activeChat = chatService.createNewChat(userId, title);
    }

    // Append user message
    const userMsg = {
      id: 'msg_' + Date.now(),
      role: 'user' as const,
      content: text,
      timestamp: Date.now(),
      webSearchUsed: this.isWebSearchEnabled
    };
    activeChat.messages.push(userMsg);
    await chatService.saveChat(userId, activeChat);

    this.renderCurrentChat();
    this.renderSidebarChats();

    const messagesScrollArea = document.getElementById('messages-scroll-area');
    if (!messagesScrollArea) return;

    // Append empty AI response bubble for streaming
    const aiBubble = this.appendMessageBubble(messagesScrollArea, 'model', '');
    let fullResponse = '';

    try {
      const stream = geminiApi.streamChatResponse(
        activeChat.messages.slice(0, -1),
        text,
        this.isWebSearchEnabled
      );

      for await (const chunk of stream) {
        fullResponse += chunk;
        aiBubble.innerHTML = this.formatMarkdown(fullResponse);
        messagesScrollArea.scrollTop = messagesScrollArea.scrollHeight;
      }

      // Save complete AI response
      const aiMsg = {
        id: 'msg_' + Date.now(),
        role: 'model' as const,
        content: fullResponse,
        timestamp: Date.now()
      };
      activeChat.messages.push(aiMsg);
      await chatService.saveChat(userId, activeChat);
      this.renderSidebarChats();

    } catch (err: any) {
      aiBubble.innerHTML = `<p class="error-text">⚠️ Error generating response: ${err.message || 'Unknown error'}.</p>`;
    } finally {
      this.isGenerating = false;
    }
  }
}

// Initialize application
document.addEventListener('DOMContentLoaded', () => {
  new AppUI();
});
