/**
 * MSAI Markdown Lightweight Parser
 */
window.MSAI = window.MSAI || {};

window.MSAI.Markdown = {
  parse(text) {
    if (!text) return '';

    let html = window.MSAI.Security.sanitizeHTML(text);

    // Code blocks ```lang\ncode\n```
    html = html.replace(/```(\w*)\n([\s\S]*?)```/g, (match, lang, code) => {
      return `<pre><code>${code}</code><button class="code-copy-btn" onclick="navigator.clipboard.writeText(this.previousElementSibling.textContent); window.MSAI.Notifications.show('Code copied!');">Copy</button></pre>`;
    });

    // Inline code `code`
    html = html.replace(/`([^`]+)`/g, '<code style="background:var(--bg-tertiary); padding:2px 6px; border-radius:4px; font-family:var(--font-mono); font-size:0.85em;">$1</code>');

    // Bold **text**
    html = html.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');

    // Italic *text*
    html = html.replace(/\*([^*]+)\*/g, '<em>$1</em>');

    // Newlines to <br>
    html = html.replace(/\n/g, '<br>');

    return html;
  }
};
