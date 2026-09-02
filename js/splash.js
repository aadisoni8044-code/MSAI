/**
 * MSAI Startup / Splash Screen Controller
 * Enforces exactly 4.0 seconds duration before revealing the main UI.
 */

window.MSAI = window.MSAI || {};

window.MSAI.Splash = {
  duration: 4000, // Exactly 4 seconds
  startTime: 0,

  init() {
    this.startTime = Date.now();
    const splashEl = document.getElementById('splash-screen');
    const appEl = document.getElementById('app-root');

    if (!splashEl) return;

    // Begin background application preparation
    if (window.MSAI.App && typeof window.MSAI.App.preload === 'function') {
      window.MSAI.App.preload();
    }

    // Begin countdown to 4.0 seconds
    const elapsed = Date.now() - this.startTime;
    const remaining = Math.max(0, this.duration - elapsed);

    setTimeout(() => {
      this.dismiss(splashEl, appEl);
    }, remaining);
  },

  dismiss(splashEl, appEl) {
    splashEl.classList.add('fade-out');

    if (appEl) {
      appEl.style.opacity = '1';
      appEl.style.pointerEvents = 'auto';
    }

    setTimeout(() => {
      splashEl.style.display = 'none';
      if (window.MSAI.App && typeof window.MSAI.App.onReady === 'function') {
        window.MSAI.App.onReady();
      }
    }, 800); // Wait for transition fade out to finish
  }
};
