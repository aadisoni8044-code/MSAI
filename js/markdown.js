import { escapeHTML, sanitizeHTML } from './sanitizer.js';

/**
 * Lightweight & secure Markdown parser with code block formatting support
 */
export function renderMarkdown(markdownText) {
    if (!markdownText) return '';

    let text = markdownText;

    // 1. Extract Code Blocks to prevent formatting inside code
    const codeBlocks = [];
    text = text.replace(/```(\w*)\n([\s\S]*?)```/g, (match, lang, code) => {
        const placeholder = `__CODE_BLOCK_${codeBlocks.length}__`;
        codeBlocks.push({
            lang: lang.trim() || 'code',
            code: escapeHTML(code.trim())
        });
        return placeholder;
    });

    // 2. Inline Code
    const inlineCodes = [];
    text = text.replace(/`([^`]+)`/g, (match, code) => {
        const placeholder = `__INLINE_CODE_${inlineCodes.length}__`;
        inlineCodes.push(escapeHTML(code));
        return placeholder;
    });

    // 3. Escape raw HTML tags in text
    text = escapeHTML(text);

    // 4. Headings
    text = text.replace(/^### (.*$)/gim, '<h3>$1</h3>');
    text = text.replace(/^## (.*$)/gim, '<h2>$1</h2>');
    text = text.replace(/^# (.*$)/gim, '<h1>$1</h1>');

    // 5. Bold & Italic
    text = text.replace(/\*\*\*(.*?)\*\*\*/g, '<strong><em>$1</em></strong>');
    text = text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    text = text.replace(/\*(.*?)\*/g, '<em>$1</em>');

    // 6. Blockquotes
    text = text.replace(/^\> (.*$)/gim, '<blockquote>$1</blockquote>');

    // 7. Unordered Lists
    text = text.replace(/^\s*[\-\*] (.*$)/gim, '<ul><li>$1</li></ul>');
    text = text.replace(/<\/ul>\s*<ul>/g, '');

    // 8. Ordered Lists
    text = text.replace(/^\s*\d+\. (.*$)/gim, '<ol><li>$1</li></ol>');
    text = text.replace(/<\/ol>\s*<ol>/g, '');

    // 9. Links
    text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>');

    // 10. Paragraphs & Line Breaks
    const paragraphs = text.split(/\n\n+/);
    text = paragraphs.map(p => {
        if (p.startsWith('<h') || p.startsWith('<ul>') || p.startsWith('<ol>') || p.startsWith('<blockquote>') || p.startsWith('__CODE_BLOCK_')) {
            return p;
        }
        return `<p>${p.replace(/\n/g, '<br>')}</p>`;
    }).join('');

    // Restore Inline Code
    inlineCodes.forEach((code, index) => {
        text = text.replace(`__INLINE_CODE_${index}__`, `<code>${code}</code>`);
    });

    // Restore Code Blocks with Language Header & Copy Button
    codeBlocks.forEach((block, index) => {
        const codeHTML = `
            <div class="code-block-container">
                <div class="code-block-header">
                    <span class="code-lang">${block.lang}</span>
                    <button class="code-copy-btn" data-code="${encodeURIComponent(block.code)}">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                        <span>Copy</span>
                    </button>
                </div>
                <pre class="code-block-content"><code>${block.code}</code></pre>
            </div>
        `;
        text = text.replace(`__CODE_BLOCK_${index}__`, codeHTML);
    });

    return sanitizeHTML(text);
}
