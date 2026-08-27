/**
 * MSAI — Application Controller & State Manager
 */

// Global App State
window.MSAIState = {
  conversations: [],
  activeConversationId: null,
  settings: {
    theme: 'dark',
    userApiKey: '',
    useProxy: true,
    model: 'gemini-2.0-flash'
  },
  staticData: null,
  isGenerating: false,
  searchTerm: '',
  serverOnline: false
};

document.addEventListener('DOMContentLoaded', async () => {
  await loadStaticData();
  loadStateFromStorage();
  initTheme();
  initUIElements();
  initEventListeners();
  checkBackendStatus();

  // If no active conversation exists, prepare state
  if (!MSAIState.activeConversationId || !getConversationById(MSAIState.activeConversationId)) {
    renderWelcomeScreen();
  } else {
    renderActiveConversation();
  }
  renderConversationsList();
});

/**
 * Loads static JSON configuration
 */
async function loadStaticData() {
  try {
    const response = await fetch('data.json');
    if (response.ok) {
      MSAIState.staticData = await response.json();
    }
  } catch (err) {
    console.warn('Could not load data.json', err);
  }
}

/**
 * Load state from localStorage
 */
function loadStateFromStorage() {
  try {
    const savedConvs = localStorage.getItem(CONFIG.STORAGE_KEYS.CONVERSATIONS);
    if (savedConvs) {
      MSAIState.conversations = JSON.parse(savedConvs);
    }

    const savedActiveId = localStorage.getItem(CONFIG.STORAGE_KEYS.ACTIVE_CONV_ID);
    if (savedActiveId) {
      MSAIState.activeConversationId = savedActiveId;
    }

    const savedSettings = localStorage.getItem(CONFIG.STORAGE_KEYS.SETTINGS);
    if (savedSettings) {
      MSAIState.settings = { ...CONFIG.DEFAULT_SETTINGS, ...JSON.parse(savedSettings) };
    }
  } catch (err) {
    console.error('Error loading state from localStorage', err);
  }
}

/**
 * Save state to localStorage
 */
function saveStateToStorage() {
  try {
    localStorage.setItem(CONFIG.STORAGE_KEYS.CONVERSATIONS, JSON.stringify(MSAIState.conversations));
    if (MSAIState.activeConversationId) {
      localStorage.setItem(CONFIG.STORAGE_KEYS.ACTIVE_CONV_ID, MSAIState.activeConversationId);
    } else {
      localStorage.removeItem(CONFIG.STORAGE_KEYS.ACTIVE_CONV_ID);
    }
    localStorage.setItem(CONFIG.STORAGE_KEYS.SETTINGS, JSON.stringify(MSAIState.settings));
  } catch (err) {
    console.error('Error saving state to localStorage', err);
  }
}

/**
 * Initialize theme based on state
 */
function initTheme() {
  const theme = MSAIState.settings.theme || 'dark';
  document.body.className = `theme-${theme}`;
  const themeBtns = document.querySelectorAll('.theme-option-btn');
  themeBtns.forEach(btn => {
    btn.classList.toggle('active', btn.dataset.theme === theme);
  });
}

/**
 * Check backend status and update badge
 */
async function checkBackendStatus() {
  const badge = document.getElementById('serverStatusBadge');
  const text = document.getElementById('statusText');

  const status = await MSAIApi.checkApiStatus();
  MSAIState.serverOnline = status.online;

  if (status.online) {
    badge.classList.remove('offline');
    badge.classList.add('online');
    text.textContent = 'Server Online';
  } else {
    badge.classList.remove('online');
    badge.classList.add('offline');
    text.textContent = 'Server Offline';
  }
}

/**
 * Initialize UI elements with static data (e.g., suggestion pills)
 */
function initUIElements() {
  const modelSelect = document.getElementById('modelSelector');
  if (modelSelect) {
    modelSelect.value = MSAIState.settings.model || CONFIG.DEFAULT_MODEL;
  }

  const apiKeyInput = document.getElementById('apiKeyInput');
  if (apiKeyInput && MSAIState.settings.userApiKey) {
    apiKeyInput.value = MSAIState.settings.userApiKey;
  }

  // Render suggestion pills in welcome screen
  const pillsContainer = document.getElementById('suggestionPills');
  if (pillsContainer && MSAIState.staticData && MSAIState.staticData.quickPills) {
    pillsContainer.innerHTML = MSAIState.staticData.quickPills.map(pill => `
      <button class="suggestion-pill" data-prompt="${escapeHtml(pill.prompt)}">
        <span class="pill-icon">${pill.icon}</span>
        <span class="pill-label">${pill.label}</span>
      </button>
    `).join('');
  }
}

/**
 * Event Listeners Initialization
 */
function initEventListeners() {
  // New Chat
  document.getElementById('newChatBtn').addEventListener('click', () => {
    createNewConversation();
  });

  // Mobile Menu Toggle
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const sidebar = document.getElementById('sidebar');
  const sidebarOverlay = document.getElementById('sidebarOverlay');

  const toggleSidebar = () => {
    sidebar.classList.toggle('open');
    sidebarOverlay.classList.toggle('open');
  };

  mobileMenuBtn.addEventListener('click', toggleSidebar);
  sidebarOverlay.addEventListener('click', toggleSidebar);

  document.getElementById('toggleSidebarBtn').addEventListener('click', () => {
    if (window.innerWidth <= 768) {
      toggleSidebar();
    }
  });

  // Model Selector
  document.getElementById('modelSelector').addEventListener('change', (e) => {
    MSAIState.settings.model = e.target.value;
    saveStateToStorage();
  });

  // Search Chat Filter
  const searchInput = document.getElementById('chatSearchInput');
  let debounceTimer;
  searchInput.addEventListener('input', (e) => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      MSAIState.searchTerm = e.target.value.toLowerCase().trim();
      renderConversationsList();
    }, 150);
  });

  // Chat Input Auto-resize & Keydown
  const chatInput = document.getElementById('chatInput');
  const sendBtn = document.getElementById('sendBtn');

  chatInput.addEventListener('input', () => {
    chatInput.style.height = 'auto';
    chatInput.style.height = Math.min(chatInput.scrollHeight, 160) + 'px';
    sendBtn.disabled = chatInput.value.trim().length === 0;
  });

  chatInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      if (!sendBtn.disabled && !MSAIState.isGenerating) {
        handleSendMessage();
      }
    }
  });

  sendBtn.addEventListener('click', () => {
    if (!sendBtn.disabled && !MSAIState.isGenerating) {
      handleSendMessage();
    }
  });

  // Suggestion Pills Click
  document.getElementById('suggestionPills').addEventListener('click', (e) => {
    const pill = e.target.closest('.suggestion-pill');
    if (pill) {
      const prompt = pill.dataset.prompt;
      if (prompt) {
        chatInput.value = prompt;
        chatInput.dispatchEvent(new Event('input'));
        chatInput.focus();
      }
    }
  });

  // Voice Microphone Input
  const voiceBtn = document.getElementById('voiceBtn');
  if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    const recognition = new SpeechRecognition();
    recognition.continuous = false;
    recognition.interimResults = false;

    voiceBtn.addEventListener('click', () => {
      voiceBtn.classList.add('listening');
      recognition.start();
    });

    recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript;
      chatInput.value += (chatInput.value ? ' ' : '') + transcript;
      chatInput.dispatchEvent(new Event('input'));
      voiceBtn.classList.remove('listening');
    };

    recognition.onerror = recognition.onend = () => {
      voiceBtn.classList.remove('listening');
    };
  } else {
    voiceBtn.addEventListener('click', () => {
      alert('Voice speech recognition is not supported in this browser environment.');
    });
  }

  // Attachment Button
  document.getElementById('attachmentBtn').addEventListener('click', () => {
    document.getElementById('hiddenFileInput').click();
  });

  document.getElementById('hiddenFileInput').addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        chatInput.value += `\n\n[Attached File: ${file.name}]\n${event.target.result.slice(0, 1000)}`;
        chatInput.dispatchEvent(new Event('input'));
      };
      reader.readAsText(file);
    }
  });

  // Settings Modal Controls
  const openSettingsBtns = [document.getElementById('openSettingsBtn'), document.getElementById('headerSettingsBtn')];
  const settingsModal = document.getElementById('settingsModal');

  openSettingsBtns.forEach(btn => {
    if (btn) btn.addEventListener('click', () => settingsModal.classList.add('active'));
  });

  document.querySelectorAll('[data-close="settingsModal"]').forEach(btn => {
    btn.addEventListener('click', () => settingsModal.classList.remove('active'));
  });

  // Theme Switch inside Settings
  document.querySelectorAll('.theme-option-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const theme = e.target.dataset.theme;
      MSAIState.settings.theme = theme;
      initTheme();
    });
  });

  // Save Settings
  document.getElementById('saveSettingsBtn').addEventListener('click', () => {
    const apiKey = document.getElementById('apiKeyInput').value.trim();
    const model = document.getElementById('defaultModelSelect').value;
    MSAIState.settings.userApiKey = apiKey;
    MSAIState.settings.model = model;
    document.getElementById('modelSelector').value = model;
    saveStateToStorage();
    settingsModal.classList.remove('active');
  });

  // Clear All Chats
  document.getElementById('clearAllChatsBtn').addEventListener('click', () => {
    if (confirm('Are you sure you want to delete all conversation history?')) {
      MSAIState.conversations = [];
      MSAIState.activeConversationId = null;
      saveStateToStorage();
      renderConversationsList();
      renderWelcomeScreen();
      settingsModal.classList.remove('active');
    }
  });

  // Shortcuts Modal
  const shortcutsModal = document.getElementById('shortcutsModal');
  document.getElementById('shortcutsModalBtn').addEventListener('click', () => {
    shortcutsModal.classList.add('active');
  });
  document.querySelectorAll('[data-close="shortcutsModal"]').forEach(btn => {
    btn.addEventListener('click', () => shortcutsModal.classList.remove('active'));
  });

  // Global Keydown Shortcuts
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      settingsModal.classList.remove('active');
      shortcutsModal.classList.remove('active');
    }
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      document.getElementById('chatSearchInput').focus();
    }
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key.toLowerCase() === 'o') {
      e.preventDefault();
      createNewConversation();
    }
  });
}

/**
 * Creates a new conversation and switches view
 */
function createNewConversation() {
  const newConv = {
    id: 'conv_' + Date.now(),
    title: 'New Chat',
    messages: [],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  MSAIState.conversations.unshift(newConv);
  MSAIState.activeConversationId = newConv.id;
  saveStateToStorage();
  renderConversationsList();
  renderWelcomeScreen();

  if (window.innerWidth <= 768) {
    document.getElementById('sidebar').classList.remove('open');
    document.getElementById('sidebarOverlay').classList.remove('open');
  }
}

/**
 * Get active conversation object
 */
function getActiveConversation() {
  return MSAIState.conversations.find(c => c.id === MSAIState.activeConversationId);
}

function getConversationById(id) {
  return MSAIState.conversations.find(c => c.id === id);
}

/**
 * Renders conversations list in sidebar
 */
function renderConversationsList() {
  const listEl = document.getElementById('conversationsList');
  const badgeEl = document.getElementById('chatCountBadge');

  let filtered = MSAIState.conversations;
  if (MSAIState.searchTerm) {
    filtered = filtered.filter(c => c.title.toLowerCase().includes(MSAIState.searchTerm));
  }

  badgeEl.textContent = MSAIState.conversations.length;

  if (filtered.length === 0) {
    listEl.innerHTML = `
      <div class="no-convs">
        No conversations yet.<br>Start a new chat to begin.
      </div>
    `;
    return;
  }

  listEl.innerHTML = filtered.map(c => `
    <div class="conv-item ${c.id === MSAIState.activeConversationId ? 'active' : ''}" data-id="${c.id}">
      <span class="conv-title">${escapeHtml(c.title)}</span>
      <div class="conv-actions">
        <button class="conv-action-btn delete-conv-btn" title="Delete" data-id="${c.id}">&times;</button>
      </div>
    </div>
  `).join('');

  // Attach item click listeners
  listEl.querySelectorAll('.conv-item').forEach(item => {
    item.addEventListener('click', (e) => {
      if (e.target.classList.contains('delete-conv-btn')) {
        e.stopPropagation();
        deleteConversation(e.target.dataset.id);
        return;
      }
      switchConversation(item.dataset.id);
    });
  });
}

/**
 * Switch active conversation
 */
function switchConversation(id) {
  MSAIState.activeConversationId = id;
  saveStateToStorage();
  renderConversationsList();
  renderActiveConversation();

  if (window.innerWidth <= 768) {
    document.getElementById('sidebar').classList.remove('open');
    document.getElementById('sidebarOverlay').classList.remove('open');
  }
}

/**
 * Delete a conversation
 */
function deleteConversation(id) {
  MSAIState.conversations = MSAIState.conversations.filter(c => c.id !== id);
  if (MSAIState.activeConversationId === id) {
    MSAIState.activeConversationId = MSAIState.conversations.length > 0 ? MSAIState.conversations[0].id : null;
  }
  saveStateToStorage();
  renderConversationsList();

  if (MSAIState.activeConversationId) {
    renderActiveConversation();
  } else {
    renderWelcomeScreen();
  }
}

/**
 * Show Welcome View
 */
function renderWelcomeScreen() {
  document.getElementById('welcomeContainer').style.display = 'flex';
  const msgContainer = document.getElementById('messagesContainer');
  msgContainer.style.display = 'none';
  msgContainer.innerHTML = '';
}

/**
 * Render Active Conversation Messages
 */
function renderActiveConversation() {
  const conv = getActiveConversation();
  const welcomeContainer = document.getElementById('welcomeContainer');
  const msgContainer = document.getElementById('messagesContainer');

  if (!conv || conv.messages.length === 0) {
    renderWelcomeScreen();
    return;
  }

  welcomeContainer.style.display = 'none';
  msgContainer.style.display = 'flex';
  msgContainer.innerHTML = '';

  conv.messages.forEach((msg, idx) => {
    msgContainer.appendChild(createMessageElement(msg, idx));
  });

  scrollToBottom();
}

/**
 * Create DOM element for a single message
 */
function createMessageElement(msg, index) {
  const wrapper = document.createElement('div');
  wrapper.className = `message-wrapper ${msg.role}`;

  const isUser = msg.role === 'user';

  if (!isUser) {
    const avatar = document.createElement('div');
    avatar.className = 'avatar ai';
    avatar.textContent = 'M';
    wrapper.appendChild(avatar);
  }

  const body = document.createElement('div');
  body.className = 'message-body';

  const bubble = document.createElement('div');
  bubble.className = 'message-bubble';
  bubble.innerHTML = formatMarkdown(msg.content);
  body.appendChild(bubble);

  // Message Action Toolbar for AI responses
  if (!isUser) {
    const toolbar = document.createElement('div');
    toolbar.className = 'message-toolbar';
    toolbar.innerHTML = `
      <button class="msg-action-btn copy-msg-btn" title="Copy Message">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
      </button>
      <button class="msg-action-btn regen-msg-btn" title="Regenerate Response">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
      </button>
    `;

    toolbar.querySelector('.copy-msg-btn').addEventListener('click', () => {
      navigator.clipboard.writeText(msg.content);
    });

    toolbar.querySelector('.regen-msg-btn').addEventListener('click', () => {
      regenerateResponse(index);
    });

    body.appendChild(toolbar);
  }

  wrapper.appendChild(body);
  return wrapper;
}

/**
 * Handle Sending Message
 */
async function handleSendMessage() {
  const inputEl = document.getElementById('chatInput');
  const userText = inputEl.value.trim();
  if (!userText || MSAIState.isGenerating) return;

  // Clear input
  inputEl.value = '';
  inputEl.style.height = 'auto';
  document.getElementById('sendBtn').disabled = true;

  // If no conversation active, create one
  let conv = getActiveConversation();
  if (!conv) {
    const newConv = {
      id: 'conv_' + Date.now(),
      title: userText.slice(0, 30) + (userText.length > 30 ? '...' : ''),
      messages: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    MSAIState.conversations.unshift(newConv);
    MSAIState.activeConversationId = newConv.id;
    conv = newConv;
  } else if (conv.messages.length === 0) {
    conv.title = userText.slice(0, 30) + (userText.length > 30 ? '...' : '');
  }

  const userMsg = { role: 'user', content: userText, timestamp: new Date().toISOString() };
  conv.messages.push(userMsg);
  conv.updatedAt = new Date().toISOString();

  saveStateToStorage();
  renderConversationsList();
  renderActiveConversation();

  // Show typing indicator
  MSAIState.isGenerating = true;
  showTypingIndicator();

  try {
    const aiResponseText = await MSAIApi.sendMessage(conv.messages, {
      model: MSAIState.settings.model
    });

    removeTypingIndicator();
    const aiMsg = { role: 'assistant', content: aiResponseText, timestamp: new Date().toISOString() };
    conv.messages.push(aiMsg);
    conv.updatedAt = new Date().toISOString();

    saveStateToStorage();
    renderActiveConversation();
  } catch (err) {
    console.error('API Error:', err);
    removeTypingIndicator();
    const errorMsg = { role: 'assistant', content: `**Error**: ${err.message || 'Unable to connect to MSAI service. Please try again.'}`, timestamp: new Date().toISOString() };
    conv.messages.push(errorMsg);
    saveStateToStorage();
    renderActiveConversation();
  } finally {
    MSAIState.isGenerating = false;
  }
}

/**
 * Regenerate AI response
 */
async function regenerateResponse(aiMsgIndex) {
  const conv = getActiveConversation();
  if (!conv || aiMsgIndex < 0) return;

  // Truncate messages after user message
  if (conv.messages[aiMsgIndex].role === 'assistant') {
    conv.messages = conv.messages.slice(0, aiMsgIndex);
  }

  saveStateToStorage();
  renderActiveConversation();

  MSAIState.isGenerating = true;
  showTypingIndicator();

  try {
    const aiResponseText = await MSAIApi.sendMessage(conv.messages, {
      model: MSAIState.settings.model
    });

    removeTypingIndicator();
    conv.messages.push({ role: 'assistant', content: aiResponseText, timestamp: new Date().toISOString() });
    saveStateToStorage();
    renderActiveConversation();
  } catch (err) {
    removeTypingIndicator();
    conv.messages.push({ role: 'assistant', content: `**Error**: ${err.message}`, timestamp: new Date().toISOString() });
    saveStateToStorage();
    renderActiveConversation();
  } finally {
    MSAIState.isGenerating = false;
  }
}

/**
 * Show animated typing indicator
 */
function showTypingIndicator() {
  const msgContainer = document.getElementById('messagesContainer');
  const indicator = document.createElement('div');
  indicator.id = 'typingIndicator';
  indicator.className = 'message-wrapper assistant';
  indicator.innerHTML = `
    <div class="avatar ai">M</div>
    <div class="message-body">
      <div class="message-bubble">
        <div class="typing-indicator">
          <div class="typing-dot"></div>
          <div class="typing-dot"></div>
          <div class="typing-dot"></div>
        </div>
      </div>
    </div>
  `;
  msgContainer.appendChild(indicator);
  scrollToBottom();
}

/**
 * Remove typing indicator
 */
function removeTypingIndicator() {
  const indicator = document.getElementById('typingIndicator');
  if (indicator) indicator.remove();
}

/**
 * Scroll chat viewport to newest message
 */
function scrollToBottom() {
  const viewport = document.getElementById('chatViewport');
  viewport.scrollTop = viewport.scrollHeight;
}

/**
 * Lightweight Markdown Parser for Safe Formatting
 */
function formatMarkdown(text) {
  if (!text) return '';

  const codeBlocks = [];

  // Extract code blocks first to protect internal formatting
  let html = escapeHtml(text).replace(/```(\w*)\n([\s\S]*?)```/g, (match, lang, code) => {
    const language = lang || 'code';
    const index = codeBlocks.length;
    const cleanCode = code.trim();
    codeBlocks.push(`
      <div class="code-block-wrapper">
        <div class="code-block-header">
          <span>${language}</span>
          <button class="copy-code-btn" onclick="navigator.clipboard.writeText(\`${escapeJsString(cleanCode)}\`)">Copy</button>
        </div>
        <pre><code>${cleanCode}</code></pre>
      </div>
    `);
    return `___CODE_BLOCK_${index}___`;
  });

  // Inline code `code`
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>');

  // Bold **text**
  html = html.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');

  // Italic *text* or _text_
  html = html.replace(/\*([^*]+)\*/g, '<em>$1</em>');

  // Restore code blocks
  codeBlocks.forEach((block, index) => {
    html = html.replace(`___CODE_BLOCK_${index}___`, block);
  });

  // Paragraphs
  const lines = html.split('\n\n');
  return lines.map(line => {
    if (line.includes('code-block-wrapper') || line.startsWith('<ul')) return line;
    return `<p>${line.replace(/\n/g, '<br>')}</p>`;
  }).join('');
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeJsString(str) {
  return str.replace(/\\/g, '\\\\').replace(/`/g, '\\`').replace(/\$/g, '\\$');
}
