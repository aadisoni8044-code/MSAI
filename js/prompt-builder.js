/**
 * MSAI Structured Prompt Builder Controller
 */
window.MSAI = window.MSAI || {};

window.MSAI.PromptBuilder = {
  openModal() {
    const modalContent = `
      <div class="modal-header">
        <h3>Prompt Builder</h3>
        <button class="btn-icon btn-close-modal">✕</button>
      </div>
      <div class="modal-body">
        <div class="settings-section">
          <label class="settings-label">Goal</label>
          <input type="text" id="pb-goal" class="form-input" placeholder="e.g., Write a comprehensive article on AI trends">
        </div>
        <div class="settings-section">
          <label class="settings-label">Role</label>
          <input type="text" id="pb-role" class="form-input" placeholder="e.g., Senior Tech Writer">
        </div>
        <div class="settings-section">
          <label class="settings-label">Task & Output Format</label>
          <input type="text" id="pb-task" class="form-input" placeholder="e.g., Markdown outline with key points">
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn-secondary btn-close-modal">Cancel</button>
        <button id="btn-generate-pb" class="btn-primary">Generate & Insert Prompt</button>
      </div>
    `;

    window.MSAI.Modals.show(modalContent, (modalEl) => {
      const genBtn = modalEl.querySelector('#btn-generate-pb');
      if (genBtn) {
        genBtn.addEventListener('click', () => {
          const goal = modalEl.querySelector('#pb-goal').value;
          const role = modalEl.querySelector('#pb-role').value;
          const task = modalEl.querySelector('#pb-task').value;

          const prompt = `Role: ${role}\nGoal: ${goal}\nTask: ${task}`;
          const input = document.getElementById('composer-input');
          if (input) {
            input.value = prompt;
            input.focus();
          }
          window.MSAI.Modals.close();
        });
      }
    });
  }
};
