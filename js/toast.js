/**
 * MSAI - Toast Notification System
 */

class ToastManager {
  constructor() {
    this.container = null;
    this.ensureContainer();
  }

  ensureContainer() {
    if (typeof document === "undefined") return;
    let el = document.getElementById("msai-toast-container");
    if (!el) {
      el = document.createElement("div");
      el.id = "msai-toast-container";
      el.className = "toast-container";
      el.setAttribute("aria-live", "polite");
      document.body.appendChild(el);
    }
    this.container = el;
  }

  show({ message, type = "info", duration = 3200, actionText = null, onAction = null }) {
    this.ensureContainer();
    if (!this.container) return;

    const toast = document.createElement("div");
    toast.className = `toast-item toast-${type} animate-slide-in`;
    toast.setAttribute("role", "alert");

    // Icon based on type
    let iconSvg = "";
    if (type === "success") {
      iconSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>`;
    } else if (type === "error") {
      iconSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`;
    } else if (type === "warning") {
      iconSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`;
    } else {
      iconSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>`;
    }

    toast.innerHTML = `
      <div class="toast-icon-wrapper">${iconSvg}</div>
      <div class="toast-message">${message}</div>
      ${actionText ? `<button class="toast-action-btn">${actionText}</button>` : ""}
      <button class="toast-close-btn" aria-label="Close">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    `;

    if (actionText && onAction) {
      const actionBtn = toast.querySelector(".toast-action-btn");
      actionBtn?.addEventListener("click", () => {
        onAction();
        this.dismiss(toast);
      });
    }

    const closeBtn = toast.querySelector(".toast-close-btn");
    closeBtn?.addEventListener("click", () => this.dismiss(toast));

    this.container.appendChild(toast);

    if (duration > 0) {
      setTimeout(() => {
        this.dismiss(toast);
      }, duration);
    }
  }

  dismiss(toast) {
    if (!toast || !toast.parentNode) return;
    toast.classList.remove("animate-slide-in");
    toast.classList.add("animate-fade-out");
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, 250);
  }

  success(message, duration) {
    this.show({ message, type: "success", duration });
  }

  error(message, duration = 4500) {
    this.show({ message, type: "error", duration });
  }

  info(message, duration) {
    this.show({ message, type: "info", duration });
  }

  warning(message, duration) {
    this.show({ message, type: "warning", duration });
  }
}

export const toast = new ToastManager();
