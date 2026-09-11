/**
 * NS TRANSLATE - Interactive Mobile UI Controller
 */

document.addEventListener('DOMContentLoaded', () => {

  // Dictionary of sample mock translations for demonstration
  const mockTranslations = {
    es: {
      "Hello, how are you doing today?": "Hola, ¿cómo estás hoy?",
      "Welcome to NS Translate": "Bienvenido a NS Translate",
      "default": "Hola, este es un texto traducido de ejemplo en español."
    },
    fr: {
      "Hello, how are you doing today?": "Bonjour, comment allez-vous aujourd'hui ?",
      "Welcome to NS Translate": "Bienvenue sur NS Translate",
      "default": "Bonjour, ceci est un exemple de texte traduit en français."
    },
    de: {
      "Hello, how are you doing today?": "Hallo, wie geht es dir heute?",
      "Welcome to NS Translate": "Willkommen bei NS Translate",
      "default": "Hallo, dies ist ein Beispiel für einen übersetzten Text auf Deutsch."
    },
    hi: {
      "Hello, how are you doing today?": "नमस्ते, आप आज कैसे हैं?",
      "Welcome to NS Translate": "NS Translate में आपका स्वागत है",
      "default": "नमस्ते, यह हिंदी में एक अनुवादित पाठ उदाहरण है।"
    },
    ja: {
      "Hello, how are you doing today?": "こんにちは、お元気ですか？",
      "Welcome to NS Translate": "NS Translateへようこそ",
      "default": "こんにちは、これは日本語の翻訳テキストの例です。"
    },
    en: {
      "default": "Hello, this is a translated sample text in English."
    }
  };

  const languageNames = {
    en: 'English',
    es: 'Spanish',
    fr: 'French',
    de: 'German',
    hi: 'Hindi',
    ja: 'Japanese'
  };

  // Toast notification system
  const toastEl = document.getElementById('toast');
  let toastTimeout;

  function showToast(message) {
    if (!toastEl) return;
    toastEl.textContent = message;
    toastEl.classList.add('show');

    clearTimeout(toastTimeout);
    toastTimeout = setTimeout(() => {
      toastEl.classList.remove('show');
    }, 2400);
  }

  // Bind controls for both Light and Dark mode devices
  const devices = document.querySelectorAll('.mobile-device');

  devices.forEach((device) => {
    const sourceSelect = device.querySelector('.source-lang');
    const targetSelect = device.querySelector('.target-lang');
    const swapBtn = device.querySelector('.swap-btn');
    const textarea = device.querySelector('.source-textarea');
    const clearBtn = device.querySelector('.clear-btn');
    const translateBtn = device.querySelector('.translate-btn');
    const outputCard = device.querySelector('.output-card');
    const outputContent = device.querySelector('.output-content');
    const langLabel = device.querySelector('.lang-label');
    const copyBtn = device.querySelector('.copy-btn');
    const speakerBtn = device.querySelector('.speaker-btn');
    const dockTabs = device.querySelectorAll('.dock-tab');
    const settingsBtn = device.querySelector('.settings-btn');

    // 1. Swap Languages
    swapBtn.addEventListener('click', () => {
      const temp = sourceSelect.value;
      sourceSelect.value = targetSelect.value;
      targetSelect.value = temp;

      // Update target language label
      if (langLabel) {
        langLabel.textContent = languageNames[targetSelect.value] || 'Translation';
      }

      // Add rotation animation feedback
      swapBtn.style.transform = 'rotate(180deg)';
      setTimeout(() => {
        swapBtn.style.transform = '';
      }, 300);

      performTranslation(device);
    });

    // 2. Language Change Event
    sourceSelect.addEventListener('change', () => performTranslation(device));
    targetSelect.addEventListener('change', () => {
      if (langLabel) {
        langLabel.textContent = languageNames[targetSelect.value] || 'Translation';
      }
      performTranslation(device);
    });

    // 3. Clear Text Area
    clearBtn.addEventListener('click', () => {
      textarea.value = '';
      textarea.focus();
      outputContent.textContent = '...';
    });

    // 4. Perform Translation
    translateBtn.addEventListener('click', () => {
      performTranslation(device);
      showToast('Text translated successfully');
    });

    // 5. Copy Text to Clipboard
    copyBtn.addEventListener('click', () => {
      const textToCopy = outputContent.textContent.trim();
      if (textToCopy && textToCopy !== '...') {
        navigator.clipboard.writeText(textToCopy).then(() => {
          showToast('Copied to clipboard');
        }).catch(() => {
          showToast('Copied to clipboard');
        });
      }
    });

    // 6. Text-To-Speech (Speaker)
    speakerBtn.addEventListener('click', () => {
      const textToSpeak = outputContent.textContent.trim();
      if (textToSpeak && textToSpeak !== '...' && 'speechSynthesis' in window) {
        const utterance = new SpeechSynthesisUtterance(textToSpeak);
        utterance.lang = targetSelect.value;
        window.speechSynthesis.speak(utterance);
        showToast('Playing audio...');
      } else {
        showToast('Playing audio preview');
      }
    });

    // 7. Quick Actions Bottom Dock Navigation
    dockTabs.forEach((tab) => {
      tab.addEventListener('click', () => {
        dockTabs.forEach((t) => t.classList.remove('active'));
        tab.classList.add('active');

        const tabName = tab.getAttribute('data-tab');
        if (tabName === 'voice') {
          showToast('Voice mode activated');
        } else if (tabName === 'camera') {
          showToast('Camera translation mode activated');
        } else {
          showToast('Text translation mode activated');
        }
      });
    });

    // 8. Settings Button
    settingsBtn.addEventListener('click', () => {
      showToast('Settings & Profile');
    });

    // Helper: Perform translation lookup
    function performTranslation(deviceContainer) {
      const text = textarea.value.trim();
      const targetLang = targetSelect.value;

      if (!text) {
        outputContent.textContent = '...';
        return;
      }

      if (mockTranslations[targetLang]) {
        outputContent.textContent = mockTranslations[targetLang][text] || mockTranslations[targetLang]['default'];
      } else {
        outputContent.textContent = `[${languageNames[targetLang]}] ${text}`;
      }
    }
  });

});
