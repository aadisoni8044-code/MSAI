/**
 * Sanitizer Module
 * Prevents XSS attacks by sanitizing and escaping strings/HTML.
 */

/**
 * Escapes unsafe HTML characters in a plain string
 */
export function escapeHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

/**
 * Strips script tags and unsafe attributes from formatted HTML
 */
export function sanitizeHtml(html) {
    if (!html) return '';

    // Remove script tags and inline event listeners (on*)
    let clean = html.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
    clean = clean.replace(/ on\w+="[^"]*"/gi, '');
    clean = clean.replace(/ on\w+='[^']*'/gi, '');
    clean = clean.replace(/ href="javascript:[^"]*"/gi, ' href="#"');

    return clean;
}
