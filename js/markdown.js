/**
 * Custom Light & Fast Markdown Parser with Code Block Copying & XSS Protection
 */

import { escapeHtml } from './sanitizer.js';

export function renderMarkdown(markdownText) {
    if (!markdownText) return '';

    let content = markdownText;

    // Step 1: Extract and stash code blocks so markdown rules don't mutate them
    const codeBlocks = [];
    content = content.replace(/```(\w*)\n([\s\S]*?)```/g, (match, lang, code) => {
        const placeholder = `__CODE_BLOCK_${codeBlocks.length}__`;
        codeBlocks.push({
            lang: lang.trim().toLowerCase() || 'text',
            code: code.replace(/\n$/, '')
        });
        return placeholder;
    });

    // Step 2: Escape HTML on the remaining text
    content = escapeHtml(content);

    // Step 3: Block level elements
    // Headings
    content = content.replace(/^#### (.*$)/gim, '<h4>$1</h4>');
    content = content.replace(/^### (.*$)/gim, '<h3>$1</h3>');
    content = content.replace(/^## (.*$)/gim, '<h2>$1</h2>');
    content = content.replace(/^# (.*$)/gim, '<h1>$1</h1>');

    // Blockquotes
    content = content.replace(/^\> (.*$)/gim, '<blockquote>$1</blockquote>');

    // Bold, Italic, Strikethrough, Inline Code
    content = content.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    content = content.replace(/__(.*?)__/g, '<strong>$1</strong>');
    content = content.replace(/\*(.*?)\*/g, '<em>$1</em>');
    content = content.replace(/_(.*?)_/g, '<em>$1</em>');
    content = content.replace(/~~(.*?)~~/g, '<del>$1</del>');
    content = content.replace(/`([^`]+)`/g, '<code>$1</code>');

    // Links [Text](URL)
    content = content.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>');

    // Unordered Lists (* or -)
    content = content.replace(/^\s*[\*\-]\s+(.*$)/gim, '<li>$1</li>');
    content = content.replace(/(<li>.*<\/li>)/gim, '<ul>$1</ul>');
    content = content.replace(/<\/ul>\s*<ul>/g, ''); // Join adjacent <ul>

    // Paragraphs for double newlines
    const paragraphs = content.split(/\n{2,}/);
    content = paragraphs.map(p => {
        p = p.trim();
        if (!p) return '';
        if (/^<(h[1-6]|ul|ol|blockquote|div|table)/i.test(p) || p.startsWith('__CODE_BLOCK_')) {
            return p;
        }
        return `<p>${p.replace(/\n/g, '<br>')}</p>`;
    }).join('\n');

    // Step 4: Restore code blocks with code header and Copy button
    content = content.replace(/__CODE_BLOCK_(\d+)__/g, (match, index) => {
        const block = codeBlocks[parseInt(index, 10)];
        if (!block) return '';
        const escapedCode = escapeHtml(block.code);
        return `
<div class="code-block-wrapper">
    <div class="code-block-header">
        <span class="code-lang-label">${escapeHtml(block.lang)}</span>
        <button class="btn-copy-code" data-code="${encodeURIComponent(block.code)}">
            <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg>
            <span>Copy</span>
        </button>
    </div>
    <pre><code>${escapedCode}</code></pre>
</div>`.trim();
    });

    return content;
}
