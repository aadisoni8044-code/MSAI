/**
 * MSAI Helper Utilities
 */
window.MSAI = window.MSAI || {};

window.MSAI.Utils = {
  formatDate(isoString) {
    try {
      const date = new Date(isoString);
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } catch (e) {
      return '';
    }
  }
};
