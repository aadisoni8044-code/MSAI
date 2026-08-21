/**
 * Modal Manager Module
 * Handles opening, closing, and keyboard accessibility for popups.
 */

export class ModalManager {
    constructor() {
        this.activeModal = null;
        this.setupListeners();
    }

    setupListeners() {
        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape" && this.activeModal) {
                this.closeActiveModal();
            }
        });

        document.querySelectorAll(".modal-overlay").forEach(overlay => {
            overlay.addEventListener("click", (e) => {
                if (e.target === overlay) {
                    this.closeActiveModal();
                }
            });

            const closeBtns = overlay.querySelectorAll(".btn-close-modal");
            closeBtns.forEach(btn => {
                btn.addEventListener("click", () => this.closeActiveModal());
            });
        });
    }

    openModal(modalId) {
        this.closeActiveModal();
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.add("active");
            this.activeModal = modal;
        }
    }

    closeActiveModal() {
        if (this.activeModal) {
            this.activeModal.classList.remove("active");
            this.activeModal = null;
        }
    }
}

export const modal = new ModalManager();
