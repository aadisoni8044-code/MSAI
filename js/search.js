/**
 * MSAI Global Search Controller
 */
window.MSAI = window.MSAI || {};

window.MSAI.Search = {
  openModal() {
    const modalContent = `
      <div class="modal-header">
        <h3>Global Search</h3>
        <button class="btn-icon btn-close-modal">✕</button>
      </div>
      <div class="modal-body">
        <div class="search-input-wrapper">
          <svg class="search-icon" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
          <input type="text" id="global-search-input" class="search-input" placeholder="Search conversations and messages...">
        </div>
        <div id="search-results-list" style="display: flex; flex-direction: column; gap: 8px; margin-top: 10px;">
          <div style="font-size: 0.84rem; color: var(--text-muted); text-align: center; padding: 20px;">
            Type a query above to search.
          </div>
        </div>
      </div>
    `;

    window.MSAI.Modals.show(modalContent, (modalEl) => {
      const input = modalEl.querySelector('#global-search-input');
      const resultsList = modalEl.querySelector('#search-results-list');
      if (input) {
        input.focus();
        input.addEventListener('input', () => {
          const query = input.value.trim().toLowerCase();
          if (!query) {
            resultsList.innerHTML = `<div style="font-size: 0.84rem; color: var(--text-muted); text-align: center; padding: 20px;">Type a query above to search.</div>`;
            return;
          }

          const matches = [];
          window.MSAI.State.conversations.forEach(c => {
            if (c.title.toLowerCase().includes(query)) {
              matches.push({ type: 'Chat', title: c.title, id: c.id });
            }
            c.messages.forEach(m => {
              if (m.content.toLowerCase().includes(query)) {
                matches.push({ type: 'Message', title: m.content.substring(0, 50) + '...', id: c.id });
              }
            });
          });

          if (matches.length === 0) {
            resultsList.innerHTML = `<div style="font-size: 0.84rem; color: var(--text-muted); text-align: center; padding: 20px;">No results found for "${query}"</div>`;
          } else {
            resultsList.innerHTML = matches.map(m => `
              <div class="chat-item" data-id="${m.id}" style="padding: 10px; background: var(--bg-tertiary); border-radius: var(--radius-md);">
                <div>
                  <span style="font-size: 0.7rem; font-weight: 700; color: var(--accent-color);">${m.type}</span>
                  <div style="font-size: 0.88rem; font-weight: 500; color: var(--text-primary);">${window.MSAI.Security.sanitizeHTML(m.title)}</div>
                </div>
              </div>
            `).join('');

            resultsList.querySelectorAll('.chat-item').forEach(item => {
              item.addEventListener('click', () => {
                const id = item.getAttribute('data-id');
                window.MSAI.Chat.loadConversation(id);
                window.MSAI.Modals.close();
              });
            });
          }
        });
      }
    });
  }
};
