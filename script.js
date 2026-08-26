/**
 * MS AI — Main Frontend Application Logic
 */

(function () {
  'use strict';

  // --- State Storage Keys ---
  const STORAGE_KEY_CONVERSATIONS = 'ms_ai_conversations_v2';
  const STORAGE_KEY_SETTINGS = 'ms_ai_settings_v2';

  // --- Default Application State ---
  let state = {
    conversations: [],
    activeChatId: null,
    settings: {
      userApiKey: '',
      systemInstructions: 'You are MSAI, an intelligent, helpful, and concise AI development assistant.',
      theme: 'dark',
      model: 'gemini-2.5-flash'
    },
    isGenerating: false,
    abortController: null,
    pendingDeleteTarget: null, // { type: 'single', id: string } or { type: 'all' }
    mode: 'chat',
    serverOnline: false
  };

  // --- DOM Element References ---
  const DOM = {};

  function initDOM() {
    DOM.body = document.body;
    DOM.sidebar = document.getElementById('sidebar');
    DOM.sidebarOverlay = document.getElementById('sidebar-overlay');
    DOM.mobileMenuBtn = document.getElementById('mobile-menu-btn');
    DOM.collapseSidebarBtn = document.getElementById('collapse-sidebar-btn');
    DOM.newChatBtn = document.getElementById('new-chat-btn');
    DOM.chatHistoryList = document.getElementById('chat-history-list');
    DOM.emptyHistoryState = document.getElementById('empty-history-state');
    DOM.chatCountBadge = document.getElementById('chat-count-badge');

    DOM.searchBtn = document.getElementById('search-btn');
    DOM.chatSearchContainer = document.getElementById('chat-search-container');
    DOM.chatSearchInput = document.getElementById('chat-search-input');

    DOM.modelSelect = document.getElementById('model-select');
    DOM.apiStatusBadge = document.getElementById('api-status-badge');
    DOM.apiStatusText = document.getElementById('api-status-text');
    DOM.themeToggleBtn = document.getElementById('theme-toggle-btn');
    DOM.headerSettingsBtn = document.getElementById('header-settings-btn');
    DOM.sidebarSettingsBtn = document.getElementById('sidebar-settings-btn');
    DOM.designBtn = document.getElementById('design-btn');
    DOM.keyboardShortcutsBtn = document.getElementById('keyboard-shortcuts-btn');

    DOM.chatViewport = document.getElementById('chat-viewport');
    DOM.welcomeView = document.getElementById('welcome-view');
    DOM.conversationContainer = document.getElementById('conversation-container');

    DOM.promptInput = document.getElementById('prompt-input');
    DOM.sendBtn = document.getElementById('send-btn');
    DOM.stopBtn = document.getElementById('stop-btn');
    DOM.micBtn = document.getElementById('mic-btn');
    DOM.attachBtn = document.getElementById('attach-btn');
    DOM.modePills = document.querySelectorAll('.pill-btn');

    // Modals
    DOM.settingsModal = document.getElementById('settings-modal');
    DOM.closeSettingsBtn = document.getElementById('close-settings-btn');
    DOM.saveSettingsBtn = document.getElementById('save-settings-btn');
    DOM.userApiKeyInput = document.getElementById('user-api-key');
    DOM.systemInstructionsInput = document.getElementById('system-instructions');
    DOM.settingThemeSelect = document.getElementById('setting-theme');
    DOM.exportHistoryBtn = document.getElementById('export-history-btn');
    DOM.importHistoryBtn = document.getElementById('import-history-btn');
    DOM.importFileInput = document.getElementById('import-file-input');
    DOM.clearAllChatsBtn = document.getElementById('clear-all-chats-btn');

    DOM.shortcutsModal = document.getElementById('shortcuts-modal');
    DOM.closeShortcutsBtn = document.getElementById('close-shortcuts-btn');

    DOM.confirmModal = document.getElementById('confirm-modal');
    DOM.closeConfirmBtn = document.getElementById('close-confirm-btn');
    DOM.confirmCancelBtn = document.getElementById('confirm-cancel-btn');
    DOM.confirmActionBtn = document.getElementById('confirm-action-btn');
    DOM.confirmModalTitle = document.getElementById('confirm-modal-title');
    DOM.confirmModalMsg = document.getElementById('confirm-modal-msg');

    DOM.toastContainer = document.getElementById('toast-container');
  }

  // --- Initializer ---
  function init() {
    initDOM();
    loadSettings();
    loadConversations();
    applyTheme(state.settings.theme);
    checkServerHealth();
    bindEvents();
    renderSidebarHistory();
    updateInputState();

    // Auto-scroll or sync view
    if (state.activeChatId) {
      selectChat(state.activeChatId);
    } else {
      showWelcomeScreen();
    }
  }

  // --- LocalStorage & Settings Management ---
  function loadSettings() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY_SETTINGS);
      if (saved) {
        state.settings = { ...state.settings, ...JSON.parse(saved) };
      }
    } catch (e) {
      console.warn('Failed to load settings from storage:', e);
    }

    if (DOM.modelSelect && state.settings.model) {
      DOM.modelSelect.value = state.settings.model;
    }
  }

  function saveSettings() {
    try {
      localStorage.setItem(STORAGE_KEY_SETTINGS, JSON.stringify(state.settings));
    } catch (e) {
      showToast('Failed to save settings to localStorage', 'error');
    }
  }

  function loadConversations() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY_CONVERSATIONS);
      if (saved) {
        state.conversations = JSON.parse(saved);
      }
    } catch (e) {
      console.warn('Failed to load conversations:', e);
      state.conversations = [];
    }
  }

  function saveConversations() {
    try {
      localStorage.setItem(STORAGE_KEY_CONVERSATIONS, JSON.stringify(state.conversations));
      renderSidebarHistory();
    } catch (e) {
      showToast('Failed to save chat history', 'error');
    }
  }

  // --- Theme Management ---
  function applyTheme(theme) {
    state.settings.theme = theme;
    if (theme === 'light') {
      DOM.body.classList.remove('dark-theme');
      DOM.body.classList.add('light-theme');
      if (DOM.themeToggleBtn) {
        DOM.themeToggleBtn.innerHTML = '<i class="fa-regular fa-sun"></i>';
      }
    } else {
      DOM.body.classList.remove('light-theme');
      DOM.body.classList.add('dark-theme');
      if (DOM.themeToggleBtn) {
        DOM.themeToggleBtn.innerHTML = '<i class="fa-regular fa-moon"></i>';
      }
    }
    saveSettings();
  }

  function toggleTheme() {
    const nextTheme = state.settings.theme === 'dark' ? 'light' : 'dark';
    applyTheme(nextTheme);
    showToast(`Switched to ${nextTheme} theme`, 'info');
  }

  // --- Server & API Health Checker ---
  async function checkServerHealth() {
    try {
      const res = await fetch('/api/health', { cache: 'no-store' });
      if (res.ok) {
        const data = await res.json();
        state.serverOnline = true;
        updateApiStatus(true, data.serverApiKeyConfigured ? 'MSAI Server Ready' : 'Server Online (Key Required)');
      } else {
        state.serverOnline = false;
        updateApiStatus(false, 'Server Error');
      }
    } catch (e) {
      state.serverOnline = false;
      // If server is offline, fallback check if user provided direct API key
      if (state.settings.userApiKey) {
        updateApiStatus(true, 'Direct API Key Active');
      } else {
        updateApiStatus(false, 'Server Offline');
      }
    }
  }

  function updateApiStatus(isOnline, message) {
    if (!DOM.apiStatusBadge || !DOM.apiStatusText) return;
    if (isOnline) {
      DOM.apiStatusBadge.classList.remove('offline');
      DOM.apiStatusBadge.classList.add('online');
      DOM.apiStatusText.textContent = message || 'Online';
      DOM.apiStatusBadge.title = `API Status: ${message}`;
    } else {
      DOM.apiStatusBadge.classList.remove('online');
      DOM.apiStatusBadge.classList.add('offline');
      DOM.apiStatusText.textContent = message || 'Offline';
      DOM.apiStatusBadge.title = 'API Status: Offline or Key Missing';
    }
  }

  // --- UI Event Binding ---
  function bindEvents() {
    // Sidebar Toggle
    if (DOM.mobileMenuBtn) {
      DOM.mobileMenuBtn.addEventListener('click', () => {
        DOM.sidebar.classList.add('open');
        DOM.sidebarOverlay.classList.add('open');
      });
    }

    if (DOM.sidebarOverlay) {
      DOM.sidebarOverlay.addEventListener('click', closeSidebarMobile);
    }

    if (DOM.collapseSidebarBtn) {
      DOM.collapseSidebarBtn.addEventListener('click', () => {
        if (window.innerWidth <= 768) {
          closeSidebarMobile();
        } else {
          DOM.sidebar.classList.toggle('collapsed');
        }
      });
    }

    // New Chat
    if (DOM.newChatBtn) {
      DOM.newChatBtn.addEventListener('click', startNewChat);
    }

    // Search Toggle
    if (DOM.searchBtn) {
      DOM.searchBtn.addEventListener('click', () => {
        DOM.chatSearchContainer.classList.toggle('hidden');
        if (!DOM.chatSearchContainer.classList.contains('hidden')) {
          DOM.chatSearchInput.focus();
        }
      });
    }

    if (DOM.chatSearchInput) {
      DOM.chatSearchInput.addEventListener('input', (e) => {
        filterSidebarHistory(e.target.value);
      });
    }

    // Model Selector
    if (DOM.modelSelect) {
      DOM.modelSelect.addEventListener('change', (e) => {
        state.settings.model = e.target.value;
        saveSettings();
        showToast(`Model set to ${e.target.options[e.target.selectedIndex].text}`, 'info');
      });
    }

    // Theme Toggle
    if (DOM.themeToggleBtn) {
      DOM.themeToggleBtn.addEventListener('click', toggleTheme);
    }

    // Modal Triggers
    if (DOM.headerSettingsBtn) DOM.headerSettingsBtn.addEventListener('click', openSettingsModal);
    if (DOM.sidebarSettingsBtn) DOM.sidebarSettingsBtn.addEventListener('click', openSettingsModal);
    if (DOM.designBtn) DOM.designBtn.addEventListener('click', openSettingsModal);
    if (DOM.closeSettingsBtn) DOM.closeSettingsBtn.addEventListener('click', closeSettingsModal);
    if (DOM.saveSettingsBtn) DOM.saveSettingsBtn.addEventListener('click', saveSettingsFromModal);

    if (DOM.keyboardShortcutsBtn) {
      DOM.keyboardShortcutsBtn.addEventListener('click', () => {
        DOM.shortcutsModal.classList.remove('hidden');
      });
    }
    if (DOM.closeShortcutsBtn) {
      DOM.closeShortcutsBtn.addEventListener('click', () => {
        DOM.shortcutsModal.classList.add('hidden');
      });
    }

    // Confirm Modal
    if (DOM.closeConfirmBtn) DOM.closeConfirmBtn.addEventListener('click', closeConfirmModal);
    if (DOM.confirmCancelBtn) DOM.confirmCancelBtn.addEventListener('click', closeConfirmModal);
    if (DOM.confirmActionBtn) DOM.confirmActionBtn.addEventListener('click', executeConfirmAction);

    // Data Export/Import/Clear
    if (DOM.exportHistoryBtn) DOM.exportHistoryBtn.addEventListener('click', exportHistoryJSON);
    if (DOM.importHistoryBtn) DOM.importHistoryBtn.addEventListener('click', () => DOM.importFileInput.click());
    if (DOM.importFileInput) DOM.importFileInput.addEventListener('change', importHistoryJSON);
    if (DOM.clearAllChatsBtn) DOM.clearAllChatsBtn.addEventListener('click', promptClearAllHistory);

    // Prompt Input Events
    if (DOM.promptInput) {
      DOM.promptInput.addEventListener('input', handleInputAutoResize);
      DOM.promptInput.addEventListener('keydown', handleInputKeyDown);
    }

    if (DOM.sendBtn) {
      DOM.sendBtn.addEventListener('click', handleSendMessage);
    }

    if (DOM.stopBtn) {
      DOM.stopBtn.addEventListener('click', stopGeneration);
    }

    if (DOM.micBtn) {
      DOM.micBtn.addEventListener('click', handleSpeechRecognition);
    }

    if (DOM.attachBtn) {
      DOM.attachBtn.addEventListener('click', () => {
        showToast('Attachment feature: Text prompt file upload supported.', 'info');
      });
    }

    // Quick suggestion prompt chips
    document.querySelectorAll('.chip-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const promptText = btn.getAttribute('data-prompt');
        if (promptText) {
          DOM.promptInput.value = promptText;
          handleInputAutoResize();
          handleSendMessage();
        }
      });
    });

    // Mode pills
    DOM.modePills.forEach(pill => {
      pill.addEventListener('click', () => {
        DOM.modePills.forEach(p => p.classList.remove('active'));
        pill.classList.add('active');
        state.mode = pill.getAttribute('data-mode') || 'chat';
        showToast(`Mode switched to ${state.mode.toUpperCase()}`, 'info');
      });
    });

    // Global Keyboard Shortcuts
    document.addEventListener('keydown', (e) => {
      if (e.ctrlKey && e.shiftKey && e.key.toLowerCase() === 'o') {
        e.preventDefault();
        startNewChat();
      } else if (e.ctrlKey && e.shiftKey && e.key.toLowerCase() === 'd') {
        e.preventDefault();
        toggleTheme();
      } else if (e.ctrlKey && e.key === ',') {
        e.preventDefault();
        openSettingsModal();
      } else if (e.key === 'Escape') {
        closeSettingsModal();
        DOM.shortcutsModal.classList.add('hidden');
        closeConfirmModal();
      }
    });
  }

  function closeSidebarMobile() {
    DOM.sidebar.classList.remove('open');
    DOM.sidebarOverlay.classList.remove('open');
  }

  // --- Input Auto-Resize & Key Handling ---
  function handleInputAutoResize() {
    const input = DOM.promptInput;
    input.style.height = 'auto';
    input.style.height = `${Math.min(input.scrollHeight, 200)}px`;
    updateInputState();
  }

  function updateInputState() {
    const val = DOM.promptInput.value.trim();
    DOM.sendBtn.disabled = val.length === 0 || state.isGenerating;
  }

  function handleInputKeyDown(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      if (!DOM.sendBtn.disabled) {
        handleSendMessage();
      }
    }
  }

  // --- Chat Lifecycle Management ---
  function startNewChat() {
    state.activeChatId = null;
    showWelcomeScreen();
    renderSidebarHistory();
    closeSidebarMobile();
    DOM.promptInput.focus();
  }

  function createNewChatObject(firstPrompt) {
    const title = firstPrompt.length > 28 ? firstPrompt.substring(0, 28) + '...' : firstPrompt;
    const newChat = {
      id: 'chat_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7),
      title: title || 'New Conversation',
      messages: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    state.conversations.unshift(newChat);
    state.activeChatId = newChat.id;
    saveConversations();
    return newChat;
  }

  function selectChat(chatId) {
    const chat = state.conversations.find(c => c.id === chatId);
    if (!chat) return;

    state.activeChatId = chatId;
    renderSidebarHistory();
    renderConversationView(chat);
    closeSidebarMobile();
  }

  function renderSidebarHistory() {
    if (!DOM.chatHistoryList) return;

    const listContainer = DOM.chatHistoryList;
    listContainer.innerHTML = '';

    if (DOM.chatCountBadge) {
      DOM.chatCountBadge.textContent = state.conversations.length;
    }

    if (state.conversations.length === 0) {
      listContainer.appendChild(DOM.emptyHistoryState);
      DOM.emptyHistoryState.classList.remove('hidden');
      return;
    }

    DOM.emptyHistoryState.classList.add('hidden');

    state.conversations.forEach(chat => {
      const item = document.createElement('div');
      item.className = `chat-item ${chat.id === state.activeChatId ? 'active' : ''}`;
      item.dataset.id = chat.id;

      const titleSpan = document.createElement('span');
      titleSpan.className = 'chat-item-title';
      titleSpan.textContent = chat.title || 'Untitled Chat';

      const actionsDiv = document.createElement('div');
      actionsDiv.className = 'chat-item-actions';

      // Rename button
      const renameBtn = document.createElement('button');
      renameBtn.className = 'chat-action-btn';
      renameBtn.title = 'Rename Chat';
      renameBtn.innerHTML = '<i class="fa-solid fa-pen"></i>';
      renameBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        promptRenameChat(chat.id);
      });

      // Delete button
      const deleteBtn = document.createElement('button');
      deleteBtn.className = 'chat-action-btn delete-btn';
      deleteBtn.title = 'Delete Chat';
      deleteBtn.innerHTML = '<i class="fa-solid fa-trash-can"></i>';
      deleteBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        promptDeleteChat(chat.id);
      });

      actionsDiv.appendChild(renameBtn);
      actionsDiv.appendChild(deleteBtn);

      item.appendChild(titleSpan);
      item.appendChild(actionsDiv);

      item.addEventListener('click', () => selectChat(chat.id));

      listContainer.appendChild(item);
    });
  }

  function filterSidebarHistory(query) {
    const q = query.toLowerCase().trim();
    const items = DOM.chatHistoryList.querySelectorAll('.chat-item');
    items.forEach(item => {
      const title = item.querySelector('.chat-item-title').textContent.toLowerCase();
      if (title.includes(q)) {
        item.classList.remove('hidden');
      } else {
        item.classList.add('hidden');
      }
    });
  }

  function promptRenameChat(chatId) {
    const chat = state.conversations.find(c => c.id === chatId);
    if (!chat) return;

    const newTitle = prompt('Enter new conversation title:', chat.title);
    if (newTitle && newTitle.trim() !== '') {
      chat.title = newTitle.trim();
      chat.updatedAt = new Date().toISOString();
      saveConversations();
      showToast('Chat renamed', 'success');
    }
  }

  function promptDeleteChat(chatId) {
    const chat = state.conversations.find(c => c.id === chatId);
    if (!chat) return;

    state.pendingDeleteTarget = { type: 'single', id: chatId };
    DOM.confirmModalTitle.textContent = 'Delete Conversation';
    DOM.confirmModalMsg.textContent = `Are you sure you want to delete "${chat.title}"? This cannot be undone.`;
    DOM.confirmModal.classList.remove('hidden');
  }

  function promptClearAllHistory() {
    if (state.conversations.length === 0) {
      showToast('No history to clear', 'info');
      return;
    }
    state.pendingDeleteTarget = { type: 'all' };
    DOM.confirmModalTitle.textContent = 'Clear All History';
    DOM.confirmModalMsg.textContent = 'Are you sure you want to delete ALL chat history? This action cannot be undone.';
    DOM.confirmModal.classList.remove('hidden');
  }

  function closeConfirmModal() {
    DOM.confirmModal.classList.add('hidden');
    state.pendingDeleteTarget = null;
  }

  function executeConfirmAction() {
    if (!state.pendingDeleteTarget) return;

    if (state.pendingDeleteTarget.type === 'single') {
      const chatId = state.pendingDeleteTarget.id;
      state.conversations = state.conversations.filter(c => c.id !== chatId);
      if (state.activeChatId === chatId) {
        state.activeChatId = null;
        showWelcomeScreen();
      }
      saveConversations();
      showToast('Chat deleted', 'success');
    } else if (state.pendingDeleteTarget.type === 'all') {
      state.conversations = [];
      state.activeChatId = null;
      saveConversations();
      showWelcomeScreen();
      closeSettingsModal();
      showToast('All chat history cleared', 'success');
    }

    closeConfirmModal();
  }

  // --- View Rendering ---
  function showWelcomeScreen() {
    DOM.welcomeView.classList.remove('hidden');
    DOM.conversationContainer.classList.add('hidden');
    DOM.conversationContainer.innerHTML = '';
  }

  function renderConversationView(chat) {
    DOM.welcomeView.classList.add('hidden');
    DOM.conversationContainer.classList.remove('hidden');
    DOM.conversationContainer.innerHTML = '';

    chat.messages.forEach((msg, idx) => {
      appendMessageToUI(msg.role, msg.content, idx);
    });

    scrollToBottom();
  }

  function appendMessageToUI(role, content, index = null) {
    const row = document.createElement('div');
    row.className = `message-row ${role === 'user' ? 'user' : 'ai'}`;

    const avatar = document.createElement('div');
    avatar.className = 'avatar';
    avatar.textContent = role === 'user' ? 'U' : 'M';

    const wrapper = document.createElement('div');
    wrapper.className = 'message-content-wrapper';

    const bubble = document.createElement('div');
    bubble.className = 'message-bubble';
    bubble.innerHTML = formatMarkdown(content);

    wrapper.appendChild(bubble);

    // AI message Toolbar Actions
    if (role === 'model' || role === 'assistant') {
      const actions = document.createElement('div');
      actions.className = 'message-actions';

      const copyBtn = document.createElement('button');
      copyBtn.className = 'action-icon-btn';
      copyBtn.title = 'Copy Response';
      copyBtn.innerHTML = '<i class="fa-regular fa-copy"></i> Copy';
      copyBtn.addEventListener('click', () => {
        navigator.clipboard.writeText(content).then(() => {
          showToast('Response copied to clipboard', 'success');
        });
      });

      const regenBtn = document.createElement('button');
      regenBtn.className = 'action-icon-btn';
      regenBtn.title = 'Regenerate Response';
      regenBtn.innerHTML = '<i class="fa-solid fa-arrows-rotate"></i> Regenerate';
      regenBtn.addEventListener('click', () => {
        handleRegenerate();
      });

      actions.appendChild(copyBtn);
      actions.appendChild(regenBtn);
      wrapper.appendChild(actions);
    }

    if (role === 'user') {
      row.appendChild(wrapper);
      row.appendChild(avatar);
    } else {
      row.appendChild(avatar);
      row.appendChild(wrapper);
    }

    DOM.conversationContainer.appendChild(row);
    scrollToBottom();
  }

  function showTypingIndicator() {
    const row = document.createElement('div');
    row.id = 'active-typing-row';
    row.className = 'message-row ai';

    const avatar = document.createElement('div');
    avatar.className = 'avatar';
    avatar.textContent = 'M';

    const wrapper = document.createElement('div');
    wrapper.className = 'message-content-wrapper';

    const bubble = document.createElement('div');
    bubble.className = 'message-bubble';
    bubble.innerHTML = `
      <div class="typing-indicator">
        <span class="typing-dot"></span>
        <span class="typing-dot"></span>
        <span class="typing-dot"></span>
      </div>
    `;

    wrapper.appendChild(bubble);
    row.appendChild(avatar);
    row.appendChild(wrapper);

    DOM.conversationContainer.appendChild(row);
    scrollToBottom();
  }

  function removeTypingIndicator() {
    const indicator = document.getElementById('active-typing-row');
    if (indicator) {
      indicator.remove();
    }
  }

  function scrollToBottom() {
    DOM.chatViewport.scrollTop = DOM.chatViewport.scrollHeight;
  }

  // --- Lightweight Custom Markdown Formatter ---
  function formatMarkdown(text) {
    if (!text) return '';

    // Escape basic HTML to prevent XSS
    let html = text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');

    // Code Blocks: ```lang \n content \n ```
    html = html.replace(/```(\w*)\n([\s\S]*?)```/g, (match, lang, code) => {
      const language = lang || 'code';
      const codeId = 'code_' + Math.random().toString(36).substring(2, 7);
      return `
        <div class="code-block-wrapper">
          <div class="code-header">
            <span>${language}</span>
            <button class="copy-code-btn" onclick="window.__msaiCopyCode('${codeId}')">
              <i class="fa-regular fa-copy"></i> Copy Code
            </button>
          </div>
          <pre><code id="${codeId}">${code.trim()}</code></pre>
        </div>
      `;
    });

    // Inline Code: `code`
    html = html.replace(/`([^`]+)`/g, '<code>$1</code>');

    // Bold: **text**
    html = html.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');

    // Italic: *text*
    html = html.replace(/\*([^*]+)\*/g, '<em>$1</em>');

    // Process Paragraphs & Bullet Lists line by line
    const lines = html.split('\n');
    let formatted = '';
    let inList = false;

    lines.forEach(line => {
      const trimmed = line.trim();

      // Bullet list items (* or -)
      if (trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        if (!inList) {
          formatted += '<ul>';
          inList = true;
        }
        formatted += `<li>${trimmed.substring(2)}</li>`;
      } else if (/^\d+\.\s/.test(trimmed)) {
        // Numbered list items
        if (!inList) {
          formatted += '<ol>';
          inList = true;
        }
        formatted += `<li>${trimmed.replace(/^\d+\.\s/, '')}</li>`;
      } else {
        if (inList) {
          formatted += inList === 'ul' ? '</ul>' : '</ol>';
          inList = false;
        }

        if (trimmed.length > 0) {
          // Avoid wrapping code block wrappers in paragraphs
          if (!trimmed.startsWith('<div class="code-block-wrapper">') && !trimmed.endsWith('</div>')) {
            formatted += `<p>${line}</p>`;
          } else {
            formatted += line;
          }
        }
      }
    });

    if (inList) {
      formatted += '</ul>';
    }

    return formatted;
  }

  // Expose global helper for code copy button
  window.__msaiCopyCode = function (elementId) {
    const el = document.getElementById(elementId);
    if (!el) return;
    const codeText = el.innerText || el.textContent;
    navigator.clipboard.writeText(codeText).then(() => {
      showToast('Code copied to clipboard!', 'success');
    }).catch(() => {
      showToast('Failed to copy code', 'error');
    });
  };

  // --- Message Sending & API Integration ---
  async function handleSendMessage() {
    const promptText = DOM.promptInput.value.trim();
    if (!promptText || state.isGenerating) return;

    // Reset input box
    DOM.promptInput.value = '';
    handleInputAutoResize();

    // Ensure active conversation
    let chat;
    if (!state.activeChatId) {
      chat = createNewChatObject(promptText);
    } else {
      chat = state.conversations.find(c => c.id === state.activeChatId);
      if (!chat) chat = createNewChatObject(promptText);
    }

    // Switch to conversation view if needed
    if (DOM.welcomeView.classList.contains('hidden') === false) {
      DOM.welcomeView.classList.add('hidden');
      DOM.conversationContainer.classList.remove('hidden');
    }

    // Append User Message
    const userMsg = { role: 'user', content: promptText, timestamp: Date.now() };
    chat.messages.push(userMsg);
    saveConversations();
    appendMessageToUI('user', promptText);

    // Generate AI Response
    await generateAIResponse(chat);
  }

  async function handleRegenerate() {
    if (!state.activeChatId || state.isGenerating) return;
    const chat = state.conversations.find(c => c.id === state.activeChatId);
    if (!chat || chat.messages.length === 0) return;

    // If last message was AI, remove it before regenerating
    const lastMsg = chat.messages[chat.messages.length - 1];
    if (lastMsg.role === 'model' || lastMsg.role === 'assistant') {
      chat.messages.pop();
      saveConversations();
      renderConversationView(chat);
    }

    await generateAIResponse(chat);
  }

  async function generateAIResponse(chat) {
    setGeneratingState(true);
    showTypingIndicator();

    state.abortController = new AbortController();
    const signal = state.abortController.signal;

    // Format request payload for Gemini REST API
    const formattedContents = chat.messages.map(msg => ({
      role: msg.role === 'user' ? 'user' : 'model',
      parts: [{ text: msg.content }]
    }));

    const payload = {
      contents: formattedContents,
      systemInstruction: state.settings.systemInstructions,
      model: state.settings.model,
      userApiKey: state.settings.userApiKey
    };

    try {
      let aiText = '';

      if (state.serverOnline) {
        // Call Express proxy endpoint
        const res = await fetch('/api/chat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
          signal
        });

        const data = await res.json();

        if (!res.ok) {
          throw new Error(data.error?.message || `API Error (${res.status})`);
        }

        aiText = extractGeminiResponseText(data);
      } else if (state.settings.userApiKey) {
        // Direct Client-Side Fallback Call to Google Gemini API
        const directUrl = `https://generativelanguage.googleapis.com/v1beta/models/${state.settings.model}:generateContent?key=${state.settings.userApiKey}`;
        const directRes = await fetch(directUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ contents: formattedContents }),
          signal
        });
        const directData = await directRes.json();
        if (!directRes.ok) {
          throw new Error(directData.error?.message || `Google API Error (${directRes.status})`);
        }
        aiText = extractGeminiResponseText(directData);
      } else {
        throw new Error('Server is offline and no User API Key is configured. Please add an API key in Settings.');
      }

      removeTypingIndicator();

      // Save AI Response
      const aiMsg = { role: 'model', content: aiText, timestamp: Date.now() };
      chat.messages.push(aiMsg);
      chat.updatedAt = new Date().toISOString();
      saveConversations();

      appendMessageToUI('model', aiText);

    } catch (err) {
      removeTypingIndicator();
      if (err.name === 'AbortError') {
        showToast('Generation cancelled by user', 'info');
      } else {
        console.error('AI Generation Error:', err);
        const errorMsgText = `**Error:** ${err.message || 'Unable to complete request.'}`;
        appendMessageToUI('model', errorMsgText);
        showToast(err.message || 'Failed to generate response', 'error');
      }
    } finally {
      setGeneratingState(false);
      state.abortController = null;
    }
  }

  function extractGeminiResponseText(data) {
    if (data.candidates && data.candidates[0] && data.candidates[0].content) {
      const parts = data.candidates[0].content.parts || [];
      return parts.map(p => p.text).join('\n');
    }
    return 'No response text received from model.';
  }

  function stopGeneration() {
    if (state.abortController) {
      state.abortController.abort();
    }
  }

  function setGeneratingState(isGenerating) {
    state.isGenerating = isGenerating;
    if (isGenerating) {
      DOM.sendBtn.classList.add('hidden');
      DOM.stopBtn.classList.remove('hidden');
    } else {
      DOM.stopBtn.classList.add('hidden');
      DOM.sendBtn.classList.remove('hidden');
      updateInputState();
    }
  }

  // --- Voice Input (Speech Recognition) ---
  function handleSpeechRecognition() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      showToast('Speech recognition is not supported in this browser.', 'error');
      return;
    }

    const recognition = new SpeechRecognition();
    recognition.lang = 'en-US';
    recognition.interimResults = false;

    DOM.micBtn.classList.add('active');
    showToast('Listening... Speak now.', 'info');

    recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript;
      DOM.promptInput.value += (DOM.promptInput.value ? ' ' : '') + transcript;
      handleInputAutoResize();
    };

    recognition.onerror = (err) => {
      showToast(`Speech recognition error: ${err.error}`, 'error');
    };

    recognition.onend = () => {
      DOM.micBtn.classList.remove('active');
    };

    recognition.start();
  }

  // --- Settings Modal Handler ---
  function openSettingsModal() {
    DOM.userApiKeyInput.value = state.settings.userApiKey || '';
    DOM.systemInstructionsInput.value = state.settings.systemInstructions || '';
    DOM.settingThemeSelect.value = state.settings.theme || 'dark';
    DOM.settingsModal.classList.remove('hidden');
  }

  function closeSettingsModal() {
    DOM.settingsModal.classList.add('hidden');
  }

  function saveSettingsFromModal() {
    state.settings.userApiKey = DOM.userApiKeyInput.value.trim();
    state.settings.systemInstructions = DOM.systemInstructionsInput.value.trim();
    const newTheme = DOM.settingThemeSelect.value;

    applyTheme(newTheme);
    saveSettings();
    checkServerHealth();
    closeSettingsModal();
    showToast('Settings saved successfully', 'success');
  }

  // --- Data Export & Import ---
  function exportHistoryJSON() {
    const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(state.conversations, null, 2));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute("href", dataStr);
    downloadAnchor.setAttribute("download", `ms_ai_history_${new Date().toISOString().slice(0, 10)}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
    showToast('Chat history exported to JSON', 'success');
  }

  function importHistoryJSON(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const imported = JSON.parse(event.target.result);
        if (Array.isArray(imported)) {
          state.conversations = imported;
          saveConversations();
          showToast(`Successfully imported ${imported.length} conversations`, 'success');
          closeSettingsModal();
        } else {
          showToast('Invalid JSON structure for chat history', 'error');
        }
      } catch (err) {
        showToast('Error parsing imported JSON file', 'error');
      }
    };
    reader.readAsText(file);
    e.target.value = '';
  }

  // --- Toast Notification System ---
  function showToast(message, type = 'info') {
    if (!DOM.toastContainer) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;

    let icon = 'fa-info-circle';
    if (type === 'success') icon = 'fa-check-circle';
    if (type === 'error') icon = 'fa-exclamation-triangle';

    toast.innerHTML = `<i class="fa-solid ${icon}"></i> <span>${message}</span>`;
    DOM.toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transition = 'opacity 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 3500);
  }

  // Initialize App on DOM Load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
