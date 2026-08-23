import { getIconSvg } from './icons';

export interface ToastMessage {
  id: string;
  message: string;
  type: 'info' | 'success' | 'error' | 'warning';
}

export class ToastManager {
  public element: HTMLDivElement;
  private toasts: ToastMessage[] = [];

  constructor() {
    this.element = document.createElement('div');
    this.element.className = "fixed top-4 right-4 z-[9999] flex flex-col gap-2.5 max-w-sm pointer-events-none font-['Rajdhani']";
  }

  public showToast(message: string, type: 'info' | 'success' | 'error' | 'warning' = 'info') {
    const id = Math.random().toString(36).substring(2, 9);
    const toast: ToastMessage = { id, message, type };
    this.toasts.push(toast);
    this.render();

    setTimeout(() => {
      this.dismiss(id);
    }, 3200);
  }

  public dismiss(id: string) {
    this.toasts = this.toasts.filter(t => t.id !== id);
    this.render();
  }

  private render() {
    this.element.innerHTML = '';
    this.toasts.forEach(toast => {
      const iconName = {
        success: 'check-circle2',
        error: 'alert-circle',
        warning: 'alert-triangle',
        info: 'info'
      }[toast.type];

      const iconColor = {
        success: 'text-emerald-400',
        error: 'text-rose-400',
        warning: 'text-amber-400',
        info: 'text-cyan-400'
      }[toast.type];

      const borderColor = {
        success: 'border-emerald-500/60 shadow-[0_0_20px_rgba(16,185,129,0.3)]',
        error: 'border-rose-500/60 shadow-[0_0_20px_rgba(244,63,94,0.3)]',
        warning: 'border-amber-500/60 shadow-[0_0_20px_rgba(245,158,11,0.3)]',
        info: 'border-cyan-500/60 shadow-[0_0_20px_rgba(6,182,212,0.3)]',
      }[toast.type];

      const toastEl = document.createElement('div');
      toastEl.className = `pointer-events-auto flex items-center gap-3 p-3.5 rounded-2xl bg-slate-950/90 backdrop-blur-md border ${borderColor} text-slate-100 font-semibold text-xs sm:text-sm animate-in slide-in-from-top-4 duration-200 cursor-pointer`;
      toastEl.onclick = () => this.dismiss(toast.id);

      toastEl.innerHTML = `
        <span class="${iconColor} flex-shrink-0">${getIconSvg(iconName, 'w-5 h-5')}</span>
        <span class="flex-1">${toast.message}</span>
      `;

      this.element.appendChild(toastEl);
    });
  }
}
