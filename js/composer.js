/**
 * MSAI Message Composer Controller
 */
window.MSAI = window.MSAI || {};

window.MSAI.Composer = {
  init() {
    const input = document.getElementById('composer-input');
    const sendBtn = document.getElementById('btn-send');
    const chipBtns = document.querySelectorAll('.chip-btn');

    if (input) {
      input.addEventListener('input', () => {
        input.style.height = 'auto';
        input.style.height = `${Math.min(input.scrollHeight, 200)}px`;
      });

      input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          this.sendMessage();
        }
      });
    }

    if (sendBtn) {
      sendBtn.addEventListener('click', () => {
        this.sendMessage();
      });
    }

    chipBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const text = btn.getAttribute('data-prompt');
        if (text && input) {
          input.value = text;
          this.sendMessage();
        }
      });
    });
  },

  sendMessage() {
    const input = document.getElementById('composer-input');
    if (!input) return;

    const content = input.value.trim();
    if (!content) return;

    input.value = '';
    input.style.height = 'auto';

    window.MSAI.Chat.handleUserMessage(content);
  }
};

document.addEventListener('DOMContentLoaded', () => {
  window.MSAI.Composer.init();
});
