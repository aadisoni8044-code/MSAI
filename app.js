/**
 * NS Translate - Web Application Logic
 * Implements real-time translation simulation, theme switching, history management,
 * document upload handling, text-to-speech, and copy operations.
 */

document.addEventListener('DOMContentLoaded', () => {
    // --- State Elements & Constants ---
    const state = {
        theme: localStorage.getItem('ns_theme') || 'light',
        sourceLang: 'auto',
        targetLang: 'es',
        history: JSON.parse(localStorage.getItem('ns_history') || '[]'),
        saved: JSON.parse(localStorage.getItem('ns_saved') || '[]'),
        debounceTimer: null
    };

    // Dictionary for mock translation
    const mockTranslations = {
        'en-es': {
            'hello': 'hola',
            'welcome to ns translate': 'bienvenido a ns translate',
            'good morning': 'buenos días',
            'how are you?': '¿cómo estás?',
            'thank you': 'gracias'
        },
        'es-en': {
            'hola': 'hello',
            'bienvenido a ns translate': 'welcome to ns translate',
            'buenos días': 'good morning',
            'gracias': 'thank you'
        }
    };

    // --- DOM Elements ---
    const htmlEl = document.documentElement;
    const themeToggleBtn = document.getElementById('themeToggleBtn');
    const themeIcon = document.getElementById('themeIcon');
    const sourceLangSelect = document.getElementById('sourceLang');
    const targetLangSelect = document.getElementById('targetLang');
    const swapLangBtn = document.getElementById('swapLangBtn');
    const sourceTextarea = document.getElementById('sourceText');
    const targetOutputDisplay = document.getElementById('targetText');
    const charCountEl = document.getElementById('charCount');
    const clearInputBtn = document.getElementById('clearInputBtn');
    const voiceMicBtn = document.getElementById('voiceMicBtn');
    const listenSourceBtn = document.getElementById('listenSourceBtn');
    const listenTargetBtn = document.getElementById('listenTargetBtn');
    const copyOutputBtn = document.getElementById('copyOutputBtn');
    const starOutputBtn = document.getElementById('starOutputBtn');
    const shareOutputBtn = document.getElementById('shareOutputBtn');
    const translationStatus = document.getElementById('translationStatus');

    // Drawer & Modals
    const historyNavBtn = document.getElementById('historyNavBtn');
    const drawerHistoryBtn = document.getElementById('drawerHistoryBtn');
    const historyDrawer = document.getElementById('historyDrawer');
    const historyDrawerOverlay = document.getElementById('historyDrawerOverlay');
    const closeDrawerBtn = document.getElementById('closeDrawerBtn');
    const historyList = document.getElementById('historyList');
    const clearHistoryBtn = document.getElementById('clearHistoryBtn');

    const fileUploadBtn = document.getElementById('fileUploadBtn');
    const uploadModalOverlay = document.getElementById('uploadModalOverlay');
    const closeUploadModalBtn = document.getElementById('closeUploadModalBtn');
    const cancelUploadBtn = document.getElementById('cancelUploadBtn');
    const fileDropzone = document.getElementById('fileDropzone');
    const fileInput = document.getElementById('fileInput');
    const fileInfo = document.getElementById('fileInfo');
    const fileNameEl = document.getElementById('fileName');
    const removeFileBtn = document.getElementById('removeFileBtn');
    const processDocBtn = document.getElementById('processDocBtn');

    const savedTranslationsBtn = document.getElementById('savedTranslationsBtn');
    const savedModalOverlay = document.getElementById('savedModalOverlay');
    const closeSavedModalBtn = document.getElementById('closeSavedModalBtn');
    const savedList = document.getElementById('savedList');

    const toastNotification = document.getElementById('toastNotification');

    // --- Theme Switcher ---
    function applyTheme(theme) {
        state.theme = theme;
        htmlEl.setAttribute('data-theme', theme);
        localStorage.setItem('ns_theme', theme);
        themeIcon.textContent = theme === 'dark' ? 'light_mode' : 'dark_mode';
    }

    applyTheme(state.theme);

    themeToggleBtn.addEventListener('click', () => {
        const nextTheme = state.theme === 'light' ? 'dark' : 'light';
        applyTheme(nextTheme);
        showToast(`Switched to ${nextTheme} mode`);
    });

    // --- Toast Notifications ---
    function showToast(msg) {
        toastNotification.textContent = msg;
        toastNotification.classList.add('show');
        setTimeout(() => {
            toastNotification.classList.remove('show');
        }, 2800);
    }

    // --- Translation Logic ---
    function triggerTranslation() {
        const text = sourceTextarea.value.trim();
        const src = sourceLangSelect.value;
        const tgt = targetLangSelect.value;

        if (!text) {
            targetOutputDisplay.innerHTML = '<span class="placeholder-text">Translation will appear here in real-time...</span>';
            translationStatus.textContent = 'Ready';
            translationStatus.classList.remove('translating');
            return;
        }

        translationStatus.textContent = 'Translating...';
        translationStatus.classList.add('translating');

        clearTimeout(state.debounceTimer);
        state.debounceTimer = setTimeout(() => {
            let translationResult = '';
            const key = `${src}-${tgt}`.toLowerCase();
            const lowerText = text.toLowerCase();

            if (mockTranslations[key] && mockTranslations[key][lowerText]) {
                translationResult = mockTranslations[key][lowerText];
            } else {
                // Generative mock translation based on language
                const prefixMap = {
                    'es': '[ES] ',
                    'fr': '[FR] ',
                    'de': '[DE] ',
                    'hi': '[HI] ',
                    'ja': '[JA] ',
                    'zh': '[ZH] ',
                    'en': '[EN] '
                };
                const prefix = prefixMap[tgt] || '[Translated] ';
                translationResult = prefix + text;
            }

            targetOutputDisplay.textContent = translationResult;
            translationStatus.textContent = 'Translated';
            translationStatus.classList.remove('translating');

            // Save to history if distinct
            saveToHistory(text, translationResult, src, tgt);
        }, 350);
    }

    // --- Input Events ---
    sourceTextarea.addEventListener('input', () => {
        const count = sourceTextarea.value.length;
        charCountEl.textContent = count;
        triggerTranslation();
    });

    clearInputBtn.addEventListener('click', () => {
        sourceTextarea.value = '';
        charCountEl.textContent = '0';
        triggerTranslation();
        sourceTextarea.focus();
    });

    // Language selector change
    sourceLangSelect.addEventListener('change', () => {
        state.sourceLang = sourceLangSelect.value;
        triggerTranslation();
    });

    targetLangSelect.addEventListener('change', () => {
        state.targetLang = targetLangSelect.value;
        triggerTranslation();
    });

    // Swap Languages
    swapLangBtn.addEventListener('click', () => {
        if (sourceLangSelect.value === 'auto') {
            sourceLangSelect.value = 'en';
        }
        const temp = sourceLangSelect.value;
        sourceLangSelect.value = targetLangSelect.value;
        targetLangSelect.value = temp;

        const currentOutput = targetOutputDisplay.textContent;
        if (currentOutput && !targetOutputDisplay.querySelector('.placeholder-text')) {
            sourceTextarea.value = currentOutput;
            charCountEl.textContent = sourceTextarea.value.length;
        }

        triggerTranslation();
        showToast('Languages swapped');
    });

    // Voice Input Simulation
    let isListening = false;
    voiceMicBtn.addEventListener('click', () => {
        isListening = !isListening;
        if (isListening) {
            voiceMicBtn.classList.add('active');
            showToast('Listening... Speak into your microphone');
            setTimeout(() => {
                sourceTextarea.value = 'Welcome to NS Translate';
                charCountEl.textContent = sourceTextarea.value.length;
                triggerTranslation();
                voiceMicBtn.classList.remove('active');
                isListening = false;
                showToast('Voice input captured');
            }, 2500);
        } else {
            voiceMicBtn.classList.remove('active');
        }
    });

    // Text to speech simulation
    listenSourceBtn.addEventListener('click', () => {
        const text = sourceTextarea.value;
        if (!text) return;
        if ('speechSynthesis' in window) {
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = sourceLangSelect.value === 'auto' ? 'en-US' : sourceLangSelect.value;
            window.speechSynthesis.speak(utterance);
        }
        showToast('Playing source audio...');
    });

    listenTargetBtn.addEventListener('click', () => {
        const text = targetOutputDisplay.textContent;
        if (!text || targetOutputDisplay.querySelector('.placeholder-text')) return;
        if ('speechSynthesis' in window) {
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = targetLangSelect.value;
            window.speechSynthesis.speak(utterance);
        }
        showToast('Playing translation audio...');
    });

    // Copy to Clipboard
    copyOutputBtn.addEventListener('click', () => {
        const text = targetOutputDisplay.textContent;
        if (!text || targetOutputDisplay.querySelector('.placeholder-text')) return;

        navigator.clipboard.writeText(text).then(() => {
            showToast('Copied to clipboard!');
        }).catch(() => {
            showToast('Failed to copy');
        });
    });

    // Save/Star Translation
    starOutputBtn.addEventListener('click', () => {
        const text = targetOutputDisplay.textContent;
        if (!text || targetOutputDisplay.querySelector('.placeholder-text')) return;

        const srcText = sourceTextarea.value;
        const item = {
            id: Date.now(),
            source: srcText,
            target: text,
            srcLang: sourceLangSelect.value,
            tgtLang: targetLangSelect.value
        };

        state.saved.unshift(item);
        localStorage.setItem('ns_saved', JSON.stringify(state.saved));
        showToast('Saved to Starred Translations');
    });

    // Share Translation Link
    shareOutputBtn.addEventListener('click', () => {
        const text = targetOutputDisplay.textContent;
        if (!text || targetOutputDisplay.querySelector('.placeholder-text')) return;

        if (navigator.share) {
            navigator.share({
                title: 'NS Translate Share',
                text: `${sourceTextarea.value} -> ${text}`
            }).catch(() => {});
        } else {
            showToast('Share link copied to clipboard');
        }
    });

    // --- History Management ---
    function saveToHistory(srcText, tgtText, srcLang, tgtLang) {
        if (!srcText || !tgtText) return;
        const exists = state.history.some(item => item.source === srcText && item.target === tgtText);
        if (exists) return;

        const item = {
            id: Date.now(),
            source: srcText,
            target: tgtText,
            srcLang: srcLang,
            tgtLang: tgtLang
        };

        state.history.unshift(item);
        if (state.history.length > 50) state.history.pop();
        localStorage.setItem('ns_history', JSON.stringify(state.history));
        renderHistory();
    }

    function renderHistory() {
        if (state.history.length === 0) {
            historyList.innerHTML = '<p class="empty-state">No translation history recorded yet.</p>';
            return;
        }

        historyList.innerHTML = state.history.map(item => `
            <div class="history-item" data-src="${item.source}" data-tgt="${item.target}">
                <div class="history-lang-meta">${item.srcLang} &rarr; ${item.tgtLang}</div>
                <div class="history-src">${item.source}</div>
                <div class="history-tgt">${item.target}</div>
            </div>
        `).join('');

        historyList.querySelectorAll('.history-item').forEach(el => {
            el.addEventListener('click', () => {
                sourceTextarea.value = el.getAttribute('data-src');
                charCountEl.textContent = sourceTextarea.value.length;
                triggerTranslation();
                closeDrawer();
            });
        });
    }

    function openDrawer() {
        renderHistory();
        historyDrawer.classList.add('active');
        historyDrawerOverlay.classList.add('active');
    }

    function closeDrawer() {
        historyDrawer.classList.remove('active');
        historyDrawerOverlay.classList.remove('active');
    }

    historyNavBtn.addEventListener('click', openDrawer);
    drawerHistoryBtn.addEventListener('click', openDrawer);
    closeDrawerBtn.addEventListener('click', closeDrawer);
    historyDrawerOverlay.addEventListener('click', closeDrawer);

    clearHistoryBtn.addEventListener('click', () => {
        state.history = [];
        localStorage.removeItem('ns_history');
        renderHistory();
        showToast('History cleared');
    });

    // --- Saved Translations Modal ---
    function renderSaved() {
        if (state.saved.length === 0) {
            savedList.innerHTML = '<p class="empty-state">No saved translations found.</p>';
            return;
        }

        savedList.innerHTML = state.saved.map(item => `
            <div class="saved-item" data-src="${item.source}">
                <div class="history-lang-meta">${item.srcLang} &rarr; ${item.tgtLang}</div>
                <div class="history-src">${item.source}</div>
                <div class="history-tgt">${item.target}</div>
            </div>
        `).join('');

        savedList.querySelectorAll('.saved-item').forEach(el => {
            el.addEventListener('click', () => {
                sourceTextarea.value = el.getAttribute('data-src');
                charCountEl.textContent = sourceTextarea.value.length;
                triggerTranslation();
                savedModalOverlay.classList.remove('active');
            });
        });
    }

    savedTranslationsBtn.addEventListener('click', () => {
        renderSaved();
        savedModalOverlay.classList.add('active');
    });

    closeSavedModalBtn.addEventListener('click', () => {
        savedModalOverlay.classList.remove('active');
    });

    // --- Document Upload Modal ---
    fileUploadBtn.addEventListener('click', () => {
        uploadModalOverlay.classList.add('active');
    });

    const closeDocModal = () => {
        uploadModalOverlay.classList.remove('active');
        fileInput.value = '';
        fileInfo.classList.add('hidden');
        processDocBtn.disabled = true;
    };

    closeUploadModalBtn.addEventListener('click', closeDocModal);
    cancelUploadBtn.addEventListener('click', closeDocModal);

    fileDropzone.addEventListener('dragover', (e) => {
        e.preventDefault();
        fileDropzone.classList.add('dragover');
    });

    fileDropzone.addEventListener('dragleave', () => {
        fileDropzone.classList.remove('dragover');
    });

    fileDropzone.addEventListener('drop', (e) => {
        e.preventDefault();
        fileDropzone.classList.remove('dragover');
        if (e.dataTransfer.files.length) {
            handleFileSelect(e.dataTransfer.files[0]);
        }
    });

    fileInput.addEventListener('change', () => {
        if (fileInput.files.length) {
            handleFileSelect(fileInput.files[0]);
        }
    });

    function handleFileSelect(file) {
        fileNameEl.textContent = file.name;
        fileInfo.classList.remove('hidden');
        processDocBtn.disabled = false;
    }

    removeFileBtn.addEventListener('click', () => {
        fileInput.value = '';
        fileInfo.classList.add('hidden');
        processDocBtn.disabled = true;
    });

    processDocBtn.addEventListener('click', () => {
        showToast('Document uploaded & translated successfully');
        sourceTextarea.value = 'Welcome to NS Translate. This text was extracted from your uploaded document.';
        charCountEl.textContent = sourceTextarea.value.length;
        triggerTranslation();
        closeDocModal();
    });

    // Initial placeholder trigger
    triggerTranslation();
});
