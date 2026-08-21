/**
 * HTML Sanitizer module to prevent XSS attacks
 */

/**
 * Escape unsafe HTML characters
 */
export function escapeHTML(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

/**
 * Sanitize HTML string, keeping safe markdown elements
 */
export function sanitizeHTML(dirtyHtml) {
    const temp = document.createElement('div');
    temp.innerHTML = dirtyHtml;

    // Remove dangerous executable elements while preserving code copy buttons
    const dangerousElements = temp.querySelectorAll('script, iframe, object, embed, style, form, input, button:not(.code-copy-btn)');
    dangerousElements.forEach(el => el.remove());

    // Strip inline event listeners and unsafe hrefs
    const allElements = temp.querySelectorAll('*');
    allElements.forEach(el => {
        // Remove all inline event attributes like onclick, onload
        for (let i = el.attributes.length - 1; i >= 0; i--) {
            const attrName = el.attributes[i].name;
            if (attrName.startsWith('on')) {
                el.removeAttribute(attrName);
            }
        }

        // Check href attribute
        if (el.hasAttribute('href')) {
            const href = el.getAttribute('href').trim().toLowerCase();
            if (href.startsWith('javascript:') || href.startsWith('data:')) {
                el.removeAttribute('href');
            } else {
                el.setAttribute('target', '_blank');
                el.setAttribute('rel', 'noopener noreferrer');
            }
        }
    });

    return temp.innerHTML;
}
