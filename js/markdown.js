import { escapeHtml } from './utils.js';

export function renderMarkdown(text) {
  if (!text) return '';

  let raw = escapeHtml(text);

  // Code blocks with syntax copy header
  raw = raw.replace(/```(\w*)\n([\s\S]*?)```/g, (match, lang, code) => {
    return `<div class="code-block-wrapper">
      <div class="code-header">
        <span>${lang || 'code'}</span>
        <button class="btn-copy-code" onclick="navigator.clipboard.writeText(this.parentElement.nextElementSibling.innerText)">Copy code</button>
      </div>
      <pre><code class="language-${lang}">${code.trim()}</code></pre>
    </div>`;
  });

  // Inline code
  raw = raw.replace(/`([^`]+)`/g, '<code>$1</code>');

  // Headings
  raw = raw.replace(/^### (.*$)/gim, '<h3>$1</h3>');
  raw = raw.replace(/^## (.*$)/gim, '<h2>$1</h2>');
  raw = raw.replace(/^# (.*$)/gim, '<h1>$1</h1>');

  // Bold & Italic
  raw = raw.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
  raw = raw.replace(/\*(.*?)\*/g, '<em>$1</em>');

  // Paragraphs
  const lines = raw.split('\n\n').map(p => p.trim() ? `<p>${p}</p>` : '').join('');
  return lines;
}