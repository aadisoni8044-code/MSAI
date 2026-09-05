/**
 * Modal Dialog Controller
 */
class ModalManager {
  constructor() {
    this.activeModal = null;
  }

  init() {
    // Backdrop clicks to close
    document.querySelectorAll('.modal-backdrop').forEach(backdrop => {
      backdrop.addEventListener('click', (e) => {
        if (e.target === backdrop) {
          this.close(backdrop.id);
        }
      });
    });

    // Close buttons inside modals
    document.querySelectorAll('[data-modal-close]').forEach(btn => {
      btn.addEventListener('click', () => {
        const modalId = btn.getAttribute('data-modal-close');
        this.close(modalId);
      });
    });

    // Escape key closes active modal
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.activeModal) {
        this.close(this.activeModal);
      }
    });
  }

  open(modalId) {
    const modal = document.getElementById(modalId);
    if (!modal) return;
    modal.classList.add('open');
    this.activeModal = modalId;

    // Focus first input or button
    const focusable = modal.querySelector('input, select, textarea, button');
    if (focusable) {
      setTimeout(() => focusable.focus(), 50);
    }
  }

  close(modalId) {
    const modal = document.getElementById(modalId);
    if (!modal) return;
    modal.classList.remove('open');
    if (this.activeModal === modalId) {
      this.activeModal = null;
    }
  }
}

export const modalManager = new ModalManager();
