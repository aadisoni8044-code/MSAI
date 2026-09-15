/**
 * NV ZIP — AI Technology Explorer Grid Cards & Detailed Modal System
 * Dynamically renders cards for 12 primary AI technology topics and manages
 * the detailed glass popup modal with thorough explanations.
 */

class ExplorerCards {
  constructor() {
    this.grid = document.getElementById('explorer-cards-grid');
    this.modal = document.getElementById('concept-modal');
    this.modalCloseBtn = document.getElementById('modal-close-btn');
    this.modalActionBtn = document.getElementById('modal-action-btn');

    this.modalIcon = document.getElementById('modal-concept-icon');
    this.modalTitle = document.getElementById('modal-concept-title');
    this.modalCategory = document.getElementById('modal-concept-category');
    this.modalBody = document.getElementById('modal-concept-body');

    this.init();
  }

  init() {
    if (!this.grid) return;

    this.renderCards();

    // Modal Close listeners
    if (this.modalCloseBtn) {
      this.modalCloseBtn.addEventListener('click', () => this.closeModal());
    }

    if (this.modalActionBtn) {
      this.modalActionBtn.addEventListener('click', () => this.closeModal());
    }

    if (this.modal) {
      this.modal.addEventListener('click', (e) => {
        if (e.target === this.modal) {
          this.closeModal();
        }
      });
    }

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.modal && !this.modal.classList.contains('hidden')) {
        this.closeModal();
      }
    });
  }

  renderCards() {
    this.grid.innerHTML = '';
    const concepts = window.NV_DATA ? window.NV_DATA.concepts : {};
    const keys = Object.keys(concepts);

    keys.forEach(key => {
      const item = concepts[key];
      const card = document.createElement('div');
      card.className = 'concept-card glass-card';
      card.innerHTML = `
        <div class="card-icon">${item.icon}</div>
        <h3 class="card-title">${item.title}</h3>
        <p class="card-desc">${item.shortDesc}</p>
        <button class="btn btn-secondary glass-btn card-explore-btn" data-key="${key}">
          <span>Explore ${item.id.toUpperCase()}</span> →
        </button>
      `;

      const exploreBtn = card.querySelector('.card-explore-btn');
      exploreBtn.addEventListener('click', () => {
        this.openModal(key);
      });

      this.grid.appendChild(card);
    });
  }

  openModal(conceptKey) {
    const concepts = window.NV_DATA ? window.NV_DATA.concepts : {};
    const item = concepts[conceptKey];
    if (!item || !this.modal) return;

    if (this.modalIcon) this.modalIcon.textContent = item.icon;
    if (this.modalTitle) this.modalTitle.textContent = item.title;
    if (this.modalCategory) this.modalCategory.textContent = item.category;

    if (this.modalBody) {
      this.modalBody.innerHTML = `
        <div class="info-block">
          <label style="font-family: var(--font-code); color: var(--accent-cyan); font-size: 0.8rem;">WHAT IT IS:</label>
          <p style="color: var(--text-primary); font-size: 0.95rem; margin-top: 4px;">${item.what}</p>
        </div>

        <div class="info-block">
          <label style="font-family: var(--font-code); color: var(--accent-purple); font-size: 0.8rem;">WHY IT IS NEEDED:</label>
          <p style="color: var(--text-secondary); font-size: 0.9rem; margin-top: 4px;">${item.why}</p>
        </div>

        <div class="info-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 8px;">
          <div class="info-box glass-panel" style="padding: 12px; border-radius: 8px;">
            <label style="font-family: var(--font-code); color: var(--accent-cyan); font-size: 0.75rem;">INPUTS:</label>
            <div style="font-size: 0.85rem; color: var(--text-primary); margin-top: 2px;">${item.input}</div>
          </div>
          <div class="info-box glass-panel" style="padding: 12px; border-radius: 8px;">
            <label style="font-family: var(--font-code); color: var(--accent-emerald); font-size: 0.75rem;">OUTPUTS:</label>
            <div style="font-size: 0.85rem; color: var(--text-primary); margin-top: 2px;">${item.output}</div>
          </div>
        </div>

        <div class="analogy-block glass-panel" style="padding: 14px; border-radius: 12px; border-left: 3px solid var(--accent-amber); margin-top: 8px;">
          <label style="font-family: var(--font-code); color: var(--accent-amber); font-size: 0.8rem;">💡 REAL-WORLD ANALOGY:</label>
          <p style="font-size: 0.9rem; color: var(--text-primary); margin-top: 4px;">${item.analogy}</p>
        </div>

        <div style="margin-top: 8px;">
          <label style="font-family: var(--font-code); color: var(--text-muted); font-size: 0.8rem;">KEY TECHNICAL INSIGHTS:</label>
          <ul style="padding-left: 20px; font-size: 0.85rem; color: var(--text-secondary); margin-top: 4px; display: flex; flex-direction: column; gap: 4px;">
            ${item.details ? item.details.map(d => `<li>${d}</li>`).join('') : ''}
          </ul>
        </div>
      `;
    }

    this.modal.classList.remove('hidden');
    this.modal.setAttribute('aria-hidden', 'false');
  }

  closeModal() {
    if (this.modal) {
      this.modal.classList.add('hidden');
      this.modal.setAttribute('aria-hidden', 'true');
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.explorerCards = new ExplorerCards();
});
