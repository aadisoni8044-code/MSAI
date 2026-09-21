/**
 * MAIN MODULE
 * Global application initialization, dynamic content generation, download handlers & toasts
 */

document.addEventListener('DOMContentLoaded', () => {
  renderDynamicData();
  initDownloadButtons();
  initContactForm();
});

function renderDynamicData() {
  if (typeof GAME_DATA === 'undefined') return;

  // Render Features section if grid exists
  const featuresGrid = document.getElementById('featuresGrid');
  if (featuresGrid && GAME_DATA.features) {
    featuresGrid.innerHTML = GAME_DATA.features.map(f => `
      <div class="feature-card scroll-reveal">
        <div class="feature-icon">${f.icon}</div>
        <h3 class="feature-title">${f.title}</h3>
        <p class="feature-desc">${f.description}</p>
      </div>
    `).join('');
  }

  // Render Levels section if container exists (e.g. on game.html)
  const levelsGrid = document.getElementById('levelsGrid');
  if (levelsGrid && GAME_DATA.levels) {
    levelsGrid.innerHTML = GAME_DATA.levels.map(lvl => `
      <div class="level-card scroll-reveal" style="--level-accent: ${lvl.color};">
        <div class="level-card-header">
          <span class="level-badge">${lvl.badge}</span>
          <span class="level-icon">${lvl.icon}</span>
        </div>
        <h3 class="level-title">${lvl.name}</h3>
        <div class="level-element">Element: <strong>${lvl.element}</strong></div>
        <p class="level-desc">${lvl.description}</p>
        <div class="level-meta">
          <span>Boss: <em>${lvl.boss}</em></span>
          <span class="difficulty-pill">${lvl.difficulty}</span>
        </div>
      </div>
    `).join('');
  }

  // Render Weapons section if container exists
  const weaponsGrid = document.getElementById('weaponsGrid');
  if (weaponsGrid && GAME_DATA.weapons) {
    weaponsGrid.innerHTML = GAME_DATA.weapons.map(w => `
      <div class="weapon-card scroll-reveal">
        <div class="weapon-header">
          <span class="weapon-icon">${w.icon}</span>
          <span class="weapon-category">${w.category}</span>
        </div>
        <h3 class="weapon-name">${w.name}</h3>
        <div class="weapon-stats">
          <span>⚡ ${w.damage}</span>
          <span>🔥 ${w.rate}</span>
        </div>
        <p class="weapon-desc">${w.description}</p>
      </div>
    `).join('');
  }

  // Render Zombie Mode Features list if container exists
  const zombieList = document.getElementById('zombieFeaturesList');
  if (zombieList && GAME_DATA.zombieMode?.features) {
    zombieList.innerHTML = GAME_DATA.zombieMode.features.map(f => `
      <div class="zombie-feature-item scroll-reveal">
        <div class="zombie-feature-icon">💀</div>
        <div class="zombie-feature-text">
          <h4>${f.title}</h4>
          <p>${f.desc}</p>
        </div>
      </div>
    `).join('');
  }

  // Render Controls section if container exists
  const keyboardControls = document.getElementById('keyboardControlsGrid');
  const touchControls = document.getElementById('touchControlsGrid');

  if (keyboardControls && GAME_DATA.controls?.keyboard) {
    keyboardControls.innerHTML = GAME_DATA.controls.keyboard.map(c => `
      <div class="control-row">
        <kbd class="control-key">${c.key}</kbd>
        <span class="control-action">${c.action}</span>
      </div>
    `).join('');
  }

  if (touchControls && GAME_DATA.controls?.touch) {
    touchControls.innerHTML = GAME_DATA.controls.touch.map(c => `
      <div class="control-row">
        <span class="control-touch-badge">${c.key}</span>
        <span class="control-action">${c.action}</span>
      </div>
    `).join('');
  }
}

function initDownloadButtons() {
  const downloadBtns = document.querySelectorAll('.btn-download, .download-option-btn');
  downloadBtns.forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const platform = btn.getAttribute('data-platform') || 'PC';
      showToast(`Initiating Download for ${platform}... Direct installer package download standard setup.`);
    });
  });
}

function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    showToast("Thank you for reaching out! Our team will respond shortly.");
    form.reset();
  });
}

function showToast(message) {
  let toastContainer = document.getElementById('toastContainer');
  if (!toastContainer) {
    toastContainer = document.createElement('div');
    toastContainer.id = 'toastContainer';
    toastContainer.className = 'toast-container';
    document.body.appendChild(toastContainer);
  }

  const toast = document.createElement('div');
  toast.className = 'toast-message';
  toast.innerHTML = `
    <span class="toast-icon">⚡</span>
    <span class="toast-text">${message}</span>
  `;

  toastContainer.appendChild(toast);

  setTimeout(() => {
    toast.classList.add('show');
  }, 10);

  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => {
      toast.remove();
    }, 300);
  }, 3500);
}
