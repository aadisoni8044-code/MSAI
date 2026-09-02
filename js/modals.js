/**
 * MSAI Modal Manager
 */
window.MSAI = window.MSAI || {};

window.MSAI.Modals = {
  activeModal: null,

  show(htmlContent, onInit = null) {
    this.close();

    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay active';
    overlay.innerHTML = `<div class="modal-card">${htmlContent}</div>`;

    document.body.appendChild(overlay);
    this.activeModal = overlay;

    overlay.querySelectorAll('.btn-close-modal').forEach(btn => {
      btn.addEventListener('click', () => this.close());
    });

    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) this.close();
    });

    if (typeof onInit === 'function') {
      onInit(overlay);
    }
  },

  close() {
    if (this.activeModal) {
      this.activeModal.remove();
      this.activeModal = null;
    }
  }
};
