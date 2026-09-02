/**
 * MSAI Prompt Library Controller
 */
window.MSAI = window.MSAI || {};

window.MSAI.Prompts = {
  prompts: [],

  async init() {
    try {
      const res = await fetch('./data/prompts.json');
      const data = await res.json();
      this.prompts = data.prompts || [];
    } catch (e) {
      console.warn('Failed to load preset prompts');
    }
  },

  openLibraryModal() {
    const modalContent = `
      <div class="modal-header">
        <h3>Prompt Library</h3>
        <button class="btn-icon btn-close-modal">✕</button>
      </div>
      <div class="modal-body">
        <div class="prompt-grid">
          ${this.prompts.map(p => `
            <div class="prompt-card">
              <div class="prompt-card-title">${window.MSAI.Security.sanitizeHTML(p.title)}</div>
              <div class="prompt-card-desc">${window.MSAI.Security.sanitizeHTML(p.description)}</div>
              <div class="prompt-card-actions">
                <button class="btn-primary btn-use-prompt" data-template="${encodeURIComponent(p.template)}">Use Prompt</button>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    `;

    window.MSAI.Modals.show(modalContent, (modalEl) => {
      modalEl.querySelectorAll('.btn-use-prompt').forEach(btn => {
        btn.addEventListener('click', () => {
          const tmpl = decodeURIComponent(btn.getAttribute('data-template'));
          const input = document.getElementById('composer-input');
          if (input) {
            input.value = tmpl;
            input.focus();
          }
          window.MSAI.Modals.close();
        });
      });
    });
  }
};

document.addEventListener('DOMContentLoaded', () => {
  window.MSAI.Prompts.init();
});
