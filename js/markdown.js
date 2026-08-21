/**
 * MSAI - Markdown Parser & Syntax Formatter
 * Converts markdown text into structured, clean, and safe HTML
 */

import { escapeHtml, sanitizeHtml } from "./sanitizer.js";

export function renderMarkdown(rawText = "") {
  if (!rawText) return "";

  let text = rawText;

  // 1. Extract code blocks to avoid messing up their contents during inline formatting
  const codeBlocks = [];
  text = text.replace(/```([a-zA-Z0-9_-]*)\n([\s\S]*?)```/g, (match, lang, code) => {
    const placeholder = `__CODE_BLOCK_${codeBlocks.length}__`;
    const language = (lang || "text").toLowerCase().trim();
    codeBlocks.push({
      language,
      code: code.replace(/\n$/, ""),
    });
    return placeholder;
  });

  // 2. Extract inline code
  const inlineCodes = [];
  text = text.replace(/`([^`\n]+)`/g, (match, code) => {
    const placeholder = `__INLINE_CODE_${inlineCodes.length}__`;
    inlineCodes.push(escapeHtml(code));
    return placeholder;
  });

  // 3. Escape HTML in regular text
  text = escapeHtml(text);

  // 4. Headings
  text = text.replace(/^###### (.*$)/gim, "<h6>$1</h6>");
  text = text.replace(/^##### (.*$)/gim, "<h5>$1</h5>");
  text = text.replace(/^#### (.*$)/gim, "<h4>$1</h4>");
  text = text.replace(/^### (.*$)/gim, "<h3>$1</h3>");
  text = text.replace(/^## (.*$)/gim, "<h2>$1</h2>");
  text = text.replace(/^# (.*$)/gim, "<h1>$1</h1>");

  // 5. Horizontal rules
  text = text.replace(/^(?:---|\*\*\*|___)\s*$/gim, "<hr class='markdown-hr'>");

  // 6. Blockquotes
  text = text.replace(/^\> (.*$)/gim, "<blockquote class='markdown-quote'>$1</blockquote>");

  // 7. Bold, Italic, Strikethrough
  text = text.replace(/\*\*\*(.*?)\*\*\*/g, "<strong><em>$1</em></strong>");
  text = text.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>");
  text = text.replace(/___(.*?)___/g, "<strong><em>$1</em></strong>");
  text = text.replace(/__(.*?)__/g, "<strong>$1</strong>");
  text = text.replace(/\*([^\*\n]+)\*/g, "<em>$1</em>");
  text = text.replace(/_([^_\n]+)_/g, "<em>$1</em>");
  text = text.replace(/~~(.*?)~~/g, "<del>$1</del>");

  // 8. Markdown Links
  text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (match, linkText, url) => {
    return `<a href="${url}" target="_blank" rel="noopener noreferrer" class="markdown-link">${linkText}</a>`;
  });

  // 9. Markdown Tables
  text = parseTables(text);

  // 10. Lists (Unordered and Ordered)
  text = parseLists(text);

  // 11. Paragraphs and line breaks
  const paragraphs = text.split(/\n{2,}/);
  text = paragraphs
    .map((p) => {
      p = p.trim();
      if (!p) return "";
      if (
        p.startsWith("<h") ||
        p.startsWith("<blockquote") ||
        p.startsWith("<ul") ||
        p.startsWith("<ol") ||
        p.startsWith("<table") ||
        p.startsWith("<hr") ||
        p.startsWith("__CODE_BLOCK_")
      ) {
        return p;
      }
      return `<p>${p.replace(/\n/g, "<br>")}</p>`;
    })
    .join("\n");

  // 12. Restore Inline Code
  inlineCodes.forEach((code, index) => {
    text = text.replace(`__INLINE_CODE_${index}__`, `<code class="inline-code">${code}</code>`);
  });

  // 13. Restore Code Blocks with Syntax Structure & Copy button
  codeBlocks.forEach((block, index) => {
    const rawCode = block.code;
    const escapedCode = escapeHtml(rawCode);
    const langDisplay = block.language ? block.language.toUpperCase() : "CODE";
    const blockId = `code-block-${Date.now()}-${index}`;

    const htmlBlock = `
      <div class="code-block-wrapper" id="${blockId}">
        <div class="code-block-header">
          <span class="code-block-lang">${langDisplay}</span>
          <button class="code-copy-btn" data-code="${encodeURIComponent(rawCode)}" title="Copy code" aria-label="Copy code">
            <svg class="copy-icon" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect width="14" height="14" x="8" y="8" rx="2" ry="2"/>
              <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/>
            </svg>
            <span class="copy-text">Copy</span>
          </button>
        </div>
        <div class="code-block-content">
          <pre><code class="language-${block.language}">${escapedCode}</code></pre>
        </div>
      </div>
    `;

    text = text.replace(`__CODE_BLOCK_${index}__`, htmlBlock);
  });

  return sanitizeHtml(text);
}

function parseLists(text) {
  // Unordered list
  text = text.replace(/^[\*\-\+] (.*$)/gim, "<li class='markdown-li'>$1</li>");
  text = text.replace(/(<li class='markdown-li'>.*<\/li>\n?)+/g, (match) => {
    return `<ul class="markdown-ul">${match}</ul>`;
  });

  // Ordered list
  text = text.replace(/^\d+\. (.*$)/gim, "<li class='markdown-oli'>$1</li>");
  text = text.replace(/(<li class='markdown-oli'>.*<\/li>\n?)+/g, (match) => {
    return `<ol class="markdown-ol">${match}</ol>`;
  });

  return text;
}

function parseTables(text) {
  const tableRegex = /((?:\|[^\n]+\|\r?\n)+)/g;
  return text.replace(tableRegex, (match) => {
    const rows = match.trim().split("\n");
    if (rows.length < 2) return match;

    const hasDivider = rows[1].includes("---");
    let tableHtml = '<div class="table-responsive"><table class="markdown-table">';

    rows.forEach((row, i) => {
      if (i === 1 && hasDivider) return; // Skip divider row
      const cells = row
        .split("|")
        .slice(1, -1)
        .map((cell) => cell.trim());

      if (i === 0 && hasDivider) {
        tableHtml += "<thead><tr>";
        cells.forEach((cell) => {
          tableHtml += `<th>${cell}</th>`;
        });
        tableHtml += "</tr></thead><tbody>";
      } else {
        tableHtml += "<tr>";
        cells.forEach((cell) => {
          tableHtml += `<td>${cell}</td>`;
        });
        tableHtml += "</tr>";
      }
    });

    if (hasDivider) tableHtml += "</tbody>";
    tableHtml += "</table></div>";
    return tableHtml;
  });
}
