/**
 * Nv Translate - Main Application Controller
 */

import { translateText, detectLanguage, getApiConfig, saveApiConfig } from './api.js';
import { speakText, stopSpeaking, createSpeechRecognizer, isTTSSupported, isSpeechRecognitionSupported } from './voice.js';
import { getHistory, getFavorites, saveTranslation, deleteHistoryItem, clearHistory, toggleFavorite, isFavorite, deleteFavoriteItem } from './history.js';

// Application State
const state = {
  languages: [],
  sourceLang: 'auto',
  targetLang: 'es',
  recentSourceLangs: ['en', 'hi', 'fr', 'de'],
  recentTargetLangs: ['es', 'hi', 'fr', 'de'],
  sourceText: '',
  translatedText: '',
  detectedSourceLang: '',
  isTranslating: false,
  isRecording: false,
  activeTab: 'history', // 'history' | 'favorites'
  activeLangSelectorModal: null, // 'source' | 'target'
  speechRecognizer: null
};

// DOM Element Cache
const elements = {};

document.addEventListener('DOMContentLoaded', async () => {
  cacheDOMElements();
  initTheme();
  await loadLanguages();
  initEventListeners();
  renderLanguageSelectors();
  renderHistoryAndFavorites();
  initSettingsValues();
  updateUIState();
});

/**
 * Cache necessary DOM references
 */
function cacheDOMElements() {
  elements.themeToggle = document.getElementById('theme-toggle');
  elements.sourceLangBtn = document.getElementById('source-lang-btn');
  elements.targetLangBtn = document.getElementById('target-lang-btn');
  elements.sourceLangName = document.getElementById('source-lang-name');
  elements.targetLangName = document.getElementById('target-lang-name');
  elements.swapLangBtn = document.getElementById('swap-lang-btn');

  elements.sourceTextarea = document.getElementById('source-text');
  elements.targetTextarea = document.getElementById('target-text');
  elements.charCount = document.getElementById('char-count');
  elements.clearBtn = document.getElementById('clear-btn');
  elements.pasteBtn = document.getElementById('paste-btn');
  elements.copySourceBtn = document.getElementById('copy-source-btn');
  elements.micBtn = document.getElementById('mic-btn');
  elements.speakSourceBtn = document.getElementById('speak-source-btn');

  elements.translateBtn = document.getElementById('translate-btn');
  elements.resultCard = document.getElementById('result-card');
  elements.resultStatus = document.getElementById('result-status');
  elements.copyTargetBtn = document.getElementById('copy-target-btn');
  elements.speakTargetBtn = document.getElementById('speak-target-btn');
  elements.favTargetBtn = document.getElementById('fav-target-btn');
  elements.detectedLangBadge = document.getElementById('detected-lang-badge');

  elements.historyTabBtn = document.getElementById('history-tab-btn');
  elements.favoritesTabBtn = document.getElementById('favorites-tab-btn');
  elements.clearHistoryBtn = document.getElementById('clear-history-btn');
  elements.historyList = document.getElementById('history-list');
  elements.favoritesList = document.getElementById('favorites-list');

  elements.settingsBtn = document.getElementById('settings-btn');
  elements.settingsModal = document.getElementById('settings-modal');
  elements.closeSettingsBtn = document.getElementById('close-settings-btn');
  elements.apiProviderSelect = document.getElementById('api-provider-select');
  elements.libreSettingsGroup = document.getElementById('libre-settings-group');
  elements.mymemorySettingsGroup = document.getElementById('mymemory-settings-group');
  elements.libreEndpointInput = document.getElementById('libre-endpoint-input');
  elements.libreApiKeyInput = document.getElementById('libre-api-key-input');
  elements.mymemoryEmailInput = document.getElementById('mymemory-email-input');
  elements.saveSettingsBtn = document.getElementById('save-settings-btn');

  elements.langModal = document.getElementById('lang-modal');
  elements.closeLangModalBtn = document.getElementById('close-lang-modal-btn');
  elements.langModalTitle = document.getElementById('lang-modal-title');
  elements.langSearchInput = document.getElementById('lang-search-input');
  elements.recentLangsContainer = document.getElementById('recent-langs-container');
  elements.recentLangsList = document.getElementById('recent-langs-list');
  elements.allLangsList = document.getElementById('all-langs-list');

  elements.toast = document.getElementById('toast');
}

/**
 * Initialize Light/Dark theme from localStorage or system preferences
 */
function initTheme() {
  const savedTheme = localStorage.getItem('nv_translate_theme');
  if (savedTheme) {
    document.documentElement.setAttribute('data-theme', savedTheme);
  } else {
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    document.documentElement.setAttribute('data-theme', prefersDark ? 'dark' : 'light');
  }

  if (elements.themeToggle) {
    elements.themeToggle.addEventListener('click', () => {
      const currentTheme = document.documentElement.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', newTheme);
      localStorage.setItem('nv_translate_theme', newTheme);
      showToast(`Switched to ${newTheme} mode`);
    });
  }
}

/**
 * Load languages list from JSON dataset
 */
async function loadLanguages() {
  try {
    const response = await fetch('languages.json');
    state.languages = await response.json();
  } catch (e) {
    console.error('Failed to load languages.json:', e);
    showToast('Failed to load languages dataset.', 'error');
  }
}

/**
 * Load and save recent languages in localStorage
 */
function getRecentLangs(type) {
  try {
    const saved = localStorage.getItem(`nv_translate_recent_${type}`);
    return saved ? JSON.parse(saved) : (type === 'source' ? ['en', 'hi', 'fr', 'de'] : ['es', 'hi', 'fr', 'de']);
  } catch (e) {
    return type === 'source' ? ['en', 'hi', 'fr', 'de'] : ['es', 'hi', 'fr', 'de'];
  }
}

function addRecentLang(type, code) {
  if (code === 'auto') return;
  let list = getRecentLangs(type).filter(c => c !== code);
  list.unshift(code);
  list = list.slice(0, 4);
  localStorage.setItem(`nv_translate_recent_${type}`, JSON.stringify(list));
}

/**
 * Event Listeners Registration
 */
function initEventListeners() {
  // Source text area input
  let autoTranslateTimer = null;
  elements.sourceTextarea.addEventListener('input', (e) => {
    state.sourceText = e.target.value;
    updateCharCount();
    updateUIState();

    clearTimeout(autoTranslateTimer);
    if (state.sourceText.trim()) {
      autoTranslateTimer = setTimeout(() => {
        handleTranslate();
      }, 700);
    } else {
      state.translatedText = '';
      elements.targetTextarea.value = '';
      elements.detectedLangBadge.classList.add('hidden');
    }
  });

  // Action Buttons
  elements.translateBtn.addEventListener('click', () => handleTranslate());
  elements.clearBtn.addEventListener('click', handleClearText);
  elements.pasteBtn.addEventListener('click', handlePasteText);
  elements.swapLangBtn.addEventListener('click', handleSwapLanguages);

  // Copy Buttons
  elements.copySourceBtn.addEventListener('click', () => copyToClipboard(state.sourceText, 'Source text copied'));
  elements.copyTargetBtn.addEventListener('click', () => copyToClipboard(state.translatedText, 'Translation copied'));

  // Text-To-Speech Buttons
  elements.speakSourceBtn.addEventListener('click', () => handleSpeak(state.sourceText, state.sourceLang));
  elements.speakTargetBtn.addEventListener('click', () => handleSpeak(state.translatedText, state.targetLang));

  // Voice Input Mic Button
  elements.micBtn.addEventListener('click', handleVoiceInput);

  // Favorite Toggle Button
  elements.favTargetBtn.addEventListener('click', handleToggleFavoriteCurrent);

  // Language Modal Triggers
  elements.sourceLangBtn.addEventListener('click', () => openLanguageModal('source'));
  elements.targetLangBtn.addEventListener('click', () => openLanguageModal('target'));
  elements.closeLangModalBtn.addEventListener('click', closeLanguageModal);
  elements.langModal.addEventListener('click', (e) => {
    if (e.target === elements.langModal) closeLanguageModal();
  });
  elements.langSearchInput.addEventListener('input', (e) => filterLanguageList(e.target.value));

  // History & Favorites Tabs
  elements.historyTabBtn.addEventListener('click', () => switchTab('history'));
  elements.favoritesTabBtn.addEventListener('click', () => switchTab('favorites'));
  elements.clearHistoryBtn.addEventListener('click', handleClearAllHistory);

  // Settings Modal
  elements.settingsBtn.addEventListener('click', openSettingsModal);
  elements.closeSettingsBtn.addEventListener('click', closeSettingsModal);
  elements.settingsModal.addEventListener('click', (e) => {
    if (e.target === elements.settingsModal) closeSettingsModal();
  });
  elements.apiProviderSelect.addEventListener('change', handleProviderChange);
  elements.saveSettingsBtn.addEventListener('click', handleSaveSettings);

  // Keyboard Navigation / Shortcuts
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
      e.preventDefault();
      handleTranslate();
    }
    if (e.key === 'Escape') {
      closeLanguageModal();
      closeSettingsModal();
    }
  });
}

/**
 * Core Translation Flow
 */
async function handleTranslate() {
  const text = elements.sourceTextarea.value.trim();
  if (!text) {
    showToast('Please enter text to translate.', 'info');
    return;
  }

  state.isTranslating = true;
  updateUIState();
  elements.resultStatus.textContent = 'Translating...';

  try {
    const result = await translateText(text, state.sourceLang, state.targetLang);
    state.translatedText = result.translatedText;
    elements.targetTextarea.value = result.translatedText;

    if (state.sourceLang === 'auto' && result.detectedSourceLanguage) {
      state.detectedSourceLang = result.detectedSourceLanguage;
      const detectedObj = state.languages.find(l => l.code === result.detectedSourceLanguage);
      const name = detectedObj ? detectedObj.name : result.detectedSourceLanguage.toUpperCase();
      elements.detectedLangBadge.textContent = `Detected: ${name}`;
      elements.detectedLangBadge.classList.remove('hidden');
    } else {
      elements.detectedLangBadge.classList.add('hidden');
    }

    elements.resultStatus.textContent = result.isDemo ? 'Translated (Demo Mode)' : `Translated via ${result.provider}`;

    // Add recent languages
    if (state.sourceLang !== 'auto') addRecentLang('source', state.sourceLang);
    addRecentLang('target', state.targetLang);

    // Save to history
    saveTranslation({
      sourceLang: state.sourceLang === 'auto' && state.detectedSourceLang ? state.detectedSourceLang : state.sourceLang,
      targetLang: state.targetLang,
      sourceText: text,
      translatedText: result.translatedText
    });

    renderHistoryAndFavorites();
    updateFavoriteButtonState();
  } catch (error) {
    console.error('Translation error:', error);
    elements.targetTextarea.value = '';
    elements.resultStatus.textContent = 'Translation failed';
    showToast(error.message || 'Failed to translate. Please check API configuration or connection.', 'error');
  } finally {
    state.isTranslating = false;
    updateUIState();
  }
}

/**
 * Clear source text and translation
 */
function handleClearText() {
  elements.sourceTextarea.value = '';
  elements.targetTextarea.value = '';
  state.sourceText = '';
  state.translatedText = '';
  elements.detectedLangBadge.classList.add('hidden');
  stopSpeaking();
  updateCharCount();
  updateUIState();
  elements.sourceTextarea.focus();
}

/**
 * Paste from Clipboard
 */
async function handlePasteText() {
  try {
    if (!navigator.clipboard || !navigator.clipboard.readText) {
      showToast('Clipboard paste permission restricted by browser.', 'error');
      return;
    }
    const text = await navigator.clipboard.readText();
    if (text) {
      elements.sourceTextarea.value = text;
      state.sourceText = text;
      updateCharCount();
      updateUIState();
      handleTranslate();
      showToast('Pasted from clipboard');
    }
  } catch (err) {
    showToast('Failed to paste from clipboard. Please paste manually.', 'error');
  }
}

/**
 * Swap Languages
 */
function handleSwapLanguages() {
  if (state.sourceLang === 'auto') {
    showToast('Cannot swap when source language is Auto Detect.', 'info');
    return;
  }

  const prevSource = state.sourceLang;
  const prevTarget = state.targetLang;

  state.sourceLang = prevTarget;
  state.targetLang = prevSource;

  // Swap text if translation exists
  if (state.translatedText) {
    const tempText = state.sourceText;
    state.sourceText = state.translatedText;
    state.translatedText = tempText;
    elements.sourceTextarea.value = state.sourceText;
    elements.targetTextarea.value = state.translatedText;
  }

  renderLanguageSelectors();
  updateUIState();

  if (state.sourceText.trim()) {
    handleTranslate();
  }
}

/**
 * Text-to-Speech Output
 */
function handleSpeak(text, langCode) {
  if (!text || !text.trim()) {
    showToast('Nothing to read out.', 'info');
    return;
  }

  if (!isTTSSupported()) {
    showToast('Text-to-Speech is not supported in this browser.', 'error');
    return;
  }

  let effectiveLang = langCode;
  if (langCode === 'auto') {
    effectiveLang = state.detectedSourceLang || 'en';
  }

  const langObj = state.languages.find(l => l.code === effectiveLang);
  const speechCode = langObj ? langObj.speechCode || langObj.code : 'en-US';

  speakText(text, speechCode, {
    onStart: () => showToast('Playing audio...'),
    onError: (err) => showToast(err.message || 'Error playing speech.', 'error')
  });
}

/**
 * Speech Recognition Input
 */
function handleVoiceInput() {
  if (!isSpeechRecognitionSupported()) {
    showToast('Voice input is not supported in your current browser.', 'error');
    return;
  }

  if (state.isRecording && state.speechRecognizer) {
    state.speechRecognizer.stop();
    return;
  }

  let effectiveLang = state.sourceLang;
  if (effectiveLang === 'auto') effectiveLang = 'en';

  const langObj = state.languages.find(l => l.code === effectiveLang);
  const speechCode = langObj ? langObj.speechCode || langObj.code : 'en-US';

  state.speechRecognizer = createSpeechRecognizer({
    onStart: () => {
      state.isRecording = true;
      elements.micBtn.classList.add('recording');
      elements.micBtn.setAttribute('title', 'Listening... Tap to stop');
      showToast('Listening... Speak into microphone');
    },
    onResult: ({ transcript, isFinal }) => {
      elements.sourceTextarea.value = transcript;
      state.sourceText = transcript;
      updateCharCount();
      updateUIState();
      if (isFinal) {
        handleTranslate();
      }
    },
    onError: (err) => {
      showToast(err.message, 'error');
      state.isRecording = false;
      elements.micBtn.classList.remove('recording');
    },
    onEnd: () => {
      state.isRecording = false;
      elements.micBtn.classList.remove('recording');
      elements.micBtn.setAttribute('title', 'Voice Input');
    }
  }, speechCode);

  if (state.speechRecognizer) {
    try {
      state.speechRecognizer.start();
    } catch (e) {
      console.error(e);
    }
  }
}

/**
 * Toggle Favorite status for active translation
 */
function handleToggleFavoriteCurrent() {
  if (!state.sourceText || !state.translatedText) {
    showToast('No active translation to save to favorites.', 'info');
    return;
  }

  const isFav = toggleFavorite({
    sourceLang: state.sourceLang === 'auto' && state.detectedSourceLang ? state.detectedSourceLang : state.sourceLang,
    targetLang: state.targetLang,
    sourceText: state.sourceText,
    translatedText: state.translatedText
  });

  updateFavoriteButtonState();
  renderHistoryAndFavorites();
  showToast(isFav ? 'Added to Favorites' : 'Removed from Favorites');
}

/**
 * Update UI controls state
 */
function updateUIState() {
  const hasSourceText = state.sourceText.trim().length > 0;
  const hasTranslatedText = state.translatedText.trim().length > 0;

  elements.clearBtn.style.display = hasSourceText ? 'inline-flex' : 'none';
  elements.copySourceBtn.style.display = hasSourceText ? 'inline-flex' : 'none';
  elements.speakSourceBtn.style.display = hasSourceText ? 'inline-flex' : 'none';

  elements.copyTargetBtn.style.display = hasTranslatedText ? 'inline-flex' : 'none';
  elements.speakTargetBtn.style.display = hasTranslatedText ? 'inline-flex' : 'none';
  elements.favTargetBtn.style.display = hasTranslatedText ? 'inline-flex' : 'none';

  elements.swapLangBtn.disabled = state.sourceLang === 'auto';

  if (state.isTranslating) {
    elements.translateBtn.disabled = true;
    elements.translateBtn.classList.add('loading');
  } else {
    elements.translateBtn.disabled = !hasSourceText;
    elements.translateBtn.classList.remove('loading');
  }

  updateFavoriteButtonState();
}

function updateFavoriteButtonState() {
  if (state.sourceText && state.translatedText) {
    const isFav = isFavorite(state.sourceText, state.translatedText, state.targetLang);
    if (isFav) {
      elements.favTargetBtn.classList.add('active');
      elements.favTargetBtn.setAttribute('aria-label', 'Remove from favorites');
    } else {
      elements.favTargetBtn.classList.remove('active');
      elements.favTargetBtn.setAttribute('aria-label', 'Save to favorites');
    }
  }
}

function updateCharCount() {
  const len = elements.sourceTextarea.value.length;
  elements.charCount.textContent = `${len} / 5000`;
}

/**
 * Language Selector Modal Management
 */
function openLanguageModal(type) {
  state.activeLangSelectorModal = type;
  elements.langModalTitle.textContent = type === 'source' ? 'Select Source Language' : 'Select Target Language';
  elements.langSearchInput.value = '';
  elements.langModal.classList.remove('hidden');
  elements.langSearchInput.focus();

  renderModalLanguageLists(type);
}

function closeLanguageModal() {
  elements.langModal.classList.add('hidden');
  state.activeLangSelectorModal = null;
}

function renderLanguageSelectors() {
  const sourceObj = state.languages.find(l => l.code === state.sourceLang) || { name: 'Auto Detect' };
  const targetObj = state.languages.find(l => l.code === state.targetLang) || { name: 'English' };

  elements.sourceLangName.textContent = sourceObj.name;
  elements.targetLangName.textContent = targetObj.name;
}

function renderModalLanguageLists(type, filterText = '') {
  const recentCodes = getRecentLangs(type);
  const search = filterText.toLowerCase().trim();

  // Recent Languages section
  elements.recentLangsList.innerHTML = '';
  if (type === 'source' && !search) {
    // Add Auto Detect to recents if source
    const autoBtn = createLangButton({ code: 'auto', name: 'Auto Detect', nativeName: 'Detect Language' }, type);
    elements.recentLangsList.appendChild(autoBtn);
  }

  recentCodes.forEach(code => {
    const langObj = state.languages.find(l => l.code === code);
    if (langObj && (!search || langObj.name.toLowerCase().includes(search) || langObj.nativeName.toLowerCase().includes(search))) {
      elements.recentLangsList.appendChild(createLangButton(langObj, type));
    }
  });

  if (elements.recentLangsList.children.length === 0) {
    elements.recentLangsContainer.style.display = 'none';
  } else {
    elements.recentLangsContainer.style.display = 'block';
  }

  // All Languages section
  elements.allLangsList.innerHTML = '';
  const filtered = state.languages.filter(l => {
    if (type === 'target' && l.code === 'auto') return false;
    if (!search) return true;
    return l.name.toLowerCase().includes(search) || l.nativeName.toLowerCase().includes(search) || l.code.toLowerCase().includes(search);
  });

  filtered.sort((a, b) => {
    if (a.code === 'auto') return -1;
    if (b.code === 'auto') return 1;
    return a.name.localeCompare(b.name);
  });

  filtered.forEach(langObj => {
    elements.allLangsList.appendChild(createLangButton(langObj, type));
  });
}

function createLangButton(langObj, type) {
  const button = document.createElement('button');
  button.className = 'lang-item';
  const currentLangCode = type === 'source' ? state.sourceLang : state.targetLang;

  if (langObj.code === currentLangCode) {
    button.classList.add('selected');
  }

  button.innerHTML = `
    <span class="lang-item-name">${escapeHTML(langObj.name)}</span>
    <span class="lang-item-native">${escapeHTML(langObj.nativeName || '')}</span>
  `;

  button.addEventListener('click', () => {
    if (type === 'source') {
      state.sourceLang = langObj.code;
    } else {
      state.targetLang = langObj.code;
    }
    renderLanguageSelectors();
    closeLanguageModal();
    updateUIState();
    if (state.sourceText.trim()) {
      handleTranslate();
    }
  });

  return button;
}

function filterLanguageList(filterText) {
  if (state.activeLangSelectorModal) {
    renderModalLanguageLists(state.activeLangSelectorModal, filterText);
  }
}

/**
 * History and Favorites Tabs Management
 */
function switchTab(tabName) {
  state.activeTab = tabName;
  if (tabName === 'history') {
    elements.historyTabBtn.classList.add('active');
    elements.favoritesTabBtn.classList.remove('active');
    elements.historyList.classList.remove('hidden');
    elements.favoritesList.classList.add('hidden');
    elements.clearHistoryBtn.style.display = 'inline-flex';
  } else {
    elements.favoritesTabBtn.classList.add('active');
    elements.historyTabBtn.classList.remove('active');
    elements.favoritesList.classList.remove('hidden');
    elements.historyList.classList.add('hidden');
    elements.clearHistoryBtn.style.display = 'none';
  }
}

function renderHistoryAndFavorites() {
  const historyItems = getHistory();
  const favoriteItems = getFavorites();

  // Render History
  elements.historyList.innerHTML = '';
  if (historyItems.length === 0) {
    elements.historyList.innerHTML = `<div class="empty-state">No translation history yet.</div>`;
  } else {
    historyItems.forEach(item => {
      elements.historyList.appendChild(createTranslationCard(item, 'history'));
    });
  }

  // Render Favorites
  elements.favoritesList.innerHTML = '';
  if (favoriteItems.length === 0) {
    elements.favoritesList.innerHTML = `<div class="empty-state">No saved favorite translations yet.</div>`;
  } else {
    favoriteItems.forEach(item => {
      elements.favoritesList.appendChild(createTranslationCard(item, 'favorite'));
    });
  }
}

function createTranslationCard(item, cardType) {
  const card = document.createElement('div');
  card.className = 'history-card';

  const sourceLangObj = state.languages.find(l => l.code === item.sourceLang) || { name: item.sourceLang };
  const targetLangObj = state.languages.find(l => l.code === item.targetLang) || { name: item.targetLang };
  const isFav = isFavorite(item.sourceText, item.translatedText, item.targetLang);

  card.innerHTML = `
    <div class="history-card-header">
      <span class="history-lang-tag">${escapeHTML(sourceLangObj.name)} ➔ ${escapeHTML(targetLangObj.name)}</span>
      <div class="history-actions">
        <button class="icon-btn fav-btn ${isFav ? 'active' : ''}" title="Favorite" aria-label="Toggle Favorite">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
        </button>
        <button class="icon-btn copy-btn" title="Copy Translation" aria-label="Copy Translation">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg>
        </button>
        <button class="icon-btn delete-btn" title="Delete" aria-label="Delete">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
        </button>
      </div>
    </div>
    <div class="history-source-text">${escapeHTML(item.sourceText)}</div>
    <div class="history-target-text">${escapeHTML(item.translatedText)}</div>
  `;

  // Restore on card click
  card.addEventListener('click', (e) => {
    if (e.target.closest('.history-actions')) return;
    state.sourceLang = item.sourceLang;
    state.targetLang = item.targetLang;
    state.sourceText = item.sourceText;
    state.translatedText = item.translatedText;

    elements.sourceTextarea.value = item.sourceText;
    elements.targetTextarea.value = item.translatedText;

    renderLanguageSelectors();
    updateCharCount();
    updateUIState();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });

  // Card Action buttons
  const favBtn = card.querySelector('.fav-btn');
  const copyBtn = card.querySelector('.copy-btn');
  const deleteBtn = card.querySelector('.delete-btn');

  favBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    toggleFavorite(item);
    renderHistoryAndFavorites();
    updateFavoriteButtonState();
  });

  copyBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    copyToClipboard(item.translatedText, 'Translation copied');
  });

  deleteBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    if (cardType === 'history') {
      deleteHistoryItem(item.id);
    } else {
      deleteFavoriteItem(item.id);
    }
    renderHistoryAndFavorites();
  });

  return card;
}

function handleClearAllHistory() {
  if (confirm('Are you sure you want to clear all translation history?')) {
    clearHistory();
    renderHistoryAndFavorites();
    showToast('Translation history cleared');
  }
}

/**
 * Settings Modal Management
 */
function openSettingsModal() {
  initSettingsValues();
  elements.settingsModal.classList.remove('hidden');
}

function closeSettingsModal() {
  elements.settingsModal.classList.add('hidden');
}

function initSettingsValues() {
  const config = getApiConfig();
  elements.apiProviderSelect.value = config.provider;
  elements.libreEndpointInput.value = config.libreEndpoint || '';
  elements.libreApiKeyInput.value = config.libreApiKey || '';
  elements.mymemoryEmailInput.value = config.mymemoryEmail || '';
  handleProviderChange();
}

function handleProviderChange() {
  const provider = elements.apiProviderSelect.value;
  if (provider === 'libretranslate') {
    elements.libreSettingsGroup.style.display = 'block';
    elements.mymemorySettingsGroup.style.display = 'none';
  } else if (provider === 'mymemory') {
    elements.libreSettingsGroup.style.display = 'none';
    elements.mymemorySettingsGroup.style.display = 'block';
  } else {
    elements.libreSettingsGroup.style.display = 'none';
    elements.mymemorySettingsGroup.style.display = 'none';
  }
}

function handleSaveSettings() {
  const provider = elements.apiProviderSelect.value;
  const config = {
    provider,
    libreEndpoint: elements.libreEndpointInput.value.trim(),
    libreApiKey: elements.libreApiKeyInput.value.trim(),
    mymemoryEmail: elements.mymemoryEmailInput.value.trim()
  };

  saveApiConfig(config);
  closeSettingsModal();
  showToast('API Settings Saved');
}

/**
 * Clipboard & Toast Utilities
 */
async function copyToClipboard(text, successMsg) {
  if (!text || !text.trim()) {
    showToast('Nothing to copy.', 'info');
    return;
  }

  try {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      await navigator.clipboard.writeText(text);
      showToast(successMsg);
    } else {
      // Fallback
      const textarea = document.createElement('textarea');
      textarea.value = text;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
      showToast(successMsg);
    }
  } catch (err) {
    showToast('Failed to copy text.', 'error');
  }
}

function showToast(message, type = 'info') {
  if (!elements.toast) return;
  elements.toast.textContent = message;
  elements.toast.className = `toast ${type} show`;

  setTimeout(() => {
    elements.toast.className = 'toast hidden';
  }, 3000);
}

function escapeHTML(str) {
  return str.replace(/[&<>'"]/g,
    tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
  );
}
