/**
 * Lightweight Markdown-to-HTML parser for AI responses
 */
import { escapeHtml } from './utils.js';

export function renderMarkdown(markdownText) {
  if (!markdownText) return '';

  let html = markdownText;

  // 1. Code blocks with language detection and copy button
  html = html.replace(/```([a-zA-Z0-9_-]*)\n([\s\S]*?)```/g, (match, lang, code) => {
    const language = lang.trim() || 'code';
    const escapedCode = escapeHtml(code.trim());
    return `
      <div class="code-block-container">
        <div class="code-block-header">
          <span>${escapeHtml(language)}</span>
          <button class="code-block-copy-btn" data-copy="${escapeHtml(code.trim())}">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
              <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
            </svg>
            <span>Copy</span>
          </button>
        </div>
        <pre><code class="language-${language}">${escapedCode}</code></pre>
      </div>`;
  });

  // 2. Inline code
  html = html.replace(/`([^`]+)`/g, (match, code) => {
    return `<code>${escapeHtml(code)}</code>`;
  });

  // 3. Headings
  html = html.replace(/^### (.*$)/gim, '<h3>$1</h3>');
  html = html.replace(/^## (.*$)/gim, '<h2>$1</h2>');
  html = html.replace(/^# (.*$)/gim, '<h1>$1</h1>');

  // 4. Blockquotes
  html = html.replace(/^\> (.*$)/gim, '<blockquote>$1</blockquote>');

  // 5. Bold and Italics
  html = html.replace(/\*\*\*(.*?)\*\*\*/g, '<strong><em>$1</em></strong>');
  html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
  html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
  html = html.replace(/___(.*?)___/g, '<strong><em>$1</em></strong>');
  html = html.replace(/__(.*?)__/g, '<strong>$1</strong>');
  html = html.replace(/_(.*?)_/g, '<em>$1</em>');

  // 6. Unordered Lists (* or -)
  html = html.replace(/^\s*[\*\-]\s+(.*)$/gim, '<li>$1</li>');
  html = html.replace(/(<li>.*<\/li>)/gms, '<ul>$1</ul>');
  // Clean nested duplicate ul
  html = html.replace(/<\/ul>\s*<ul>/g, '');

  // 7. Ordered Lists
  html = html.replace(/^\s*\d+\.\s+(.*)$/gim, '<li>$1</li>');

  // 8. Links
  html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>');

  // 9. Paragraphs (lines separated by double newline)
  const paragraphs = html.split(/\n\n+/);
  html = paragraphs.map(p => {
    const trimmed = p.trim();
    if (trimmed.startsWith('<h') || trimmed.startsWith('<ul') || trimmed.startsWith('<ol') ||
        trimmed.startsWith('<blockquote') || trimmed.startsWith('<div class="code-block')) {
      return trimmed;
    }
    return `<p>${trimmed.replace(/\n/g, '<br>')}</p>`;
  }).join('');

  return html;
}
