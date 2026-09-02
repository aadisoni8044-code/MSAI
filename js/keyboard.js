/**
 * MSAI Keyboard Shortcuts Listener
 */
window.MSAI = window.MSAI || {};

window.MSAI.Keyboard = {
  init() {
    document.addEventListener('keydown', (e) => {
      // Ctrl + K or Cmd + K -> Search
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        window.MSAI.Search.openModal();
      }

      // Escape -> Close Modals
      if (e.key === 'Escape') {
        window.MSAI.Modals.close();
      }
    });
  }
};

document.addEventListener('DOMContentLoaded', () => {
  window.MSAI.Keyboard.init();
});
