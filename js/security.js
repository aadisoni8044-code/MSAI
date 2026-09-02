/**
 * MSAI Security & HTML Sanitization
 */
window.MSAI = window.MSAI || {};

window.MSAI.Security = {
  sanitizeHTML(str) {
    if (!str) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }
};
