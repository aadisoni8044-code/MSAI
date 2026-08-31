/**
 * MSAI - HTML Sanitizer & XSS Shield
 */

const ALLOWED_TAGS = new Set([
  "h1", "h2", "h3", "h4", "h5", "h6",
  "p", "br", "hr", "blockquote",
  "strong", "b", "em", "i", "u", "s", "del", "mark",
  "code", "pre", "span", "div",
  "ul", "ol", "li",
  "table", "thead", "tbody", "tr", "th", "td",
  "a", "img", "details", "summary", "kbd", "sup", "sub",
  "button", "svg", "path", "rect", "polygon", "polyline", "line", "circle"
]);

const ALLOWED_ATTRS = {
  a: ["href", "title", "target", "rel", "class", "id"],
  img: ["src", "alt", "title", "width", "height", "class", "loading", "referrerpolicy"],
  code: ["class", "data-language", "id"],
  pre: ["class", "id"],
  span: ["class", "id", "style"],
  div: ["class", "id"],
  th: ["align", "class"],
  td: ["align", "class"],
  table: ["class"],
  button: ["class", "id", "type", "title", "aria-label", "data-code", "data-msg-id"],
  svg: ["class", "id", "width", "height", "viewbox", "fill", "stroke", "stroke-width", "stroke-linecap", "stroke-linejoin"],
  path: ["d", "fill", "stroke", "stroke-width", "stroke-linecap", "stroke-linejoin"],
  rect: ["x", "y", "width", "height", "rx", "ry", "fill", "stroke", "stroke-width"],
  polygon: ["points", "fill", "stroke", "stroke-width"],
  polyline: ["points", "fill", "stroke", "stroke-width"],
  line: ["x1", "y1", "x2", "y2", "stroke", "stroke-width", "stroke-linecap"],
  circle: ["cx", "cy", "r", "fill", "stroke", "stroke-width"],
};

export function escapeHtml(str) {
  if (!str) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

export function sanitizeHtml(html) {
  if (!html) return "";

  const parser = new DOMParser();
  const doc = parser.parseFromString(html, "text/html");

  function cleanNode(node) {
    const children = Array.from(node.childNodes);
    for (const child of children) {
      if (child.nodeType === Node.ELEMENT_NODE) {
        const tagName = child.tagName.toLowerCase();

        // Disallow dangerous or unlisted tags (script, style, iframe, object, etc.)
        if (!ALLOWED_TAGS.has(tagName)) {
          const textNode = doc.createTextNode(child.textContent || "");
          node.replaceChild(textNode, child);
          continue;
        }

        // Clean attributes
        const allowedForTag = ALLOWED_ATTRS[tagName] || ["class", "id"];
        const attrs = Array.from(child.attributes);
        for (const attr of attrs) {
          const attrName = attr.name.toLowerCase();
          if (!allowedForTag.includes(attrName) && !attrName.startsWith("data-")) {
            child.removeAttribute(attr.name);
          } else if (attrName === "href" || attrName === "src") {
            const val = attr.value.trim().toLowerCase();
            // Block javascript:, vbscript:, data: (except images)
            if (val.startsWith("javascript:") || val.startsWith("vbscript:") || (val.startsWith("data:") && !val.startsWith("data:image/"))) {
              child.removeAttribute(attr.name);
            }
          }
        }

        // Enforce safe link attributes
        if (tagName === "a") {
          child.setAttribute("target", "_blank");
          child.setAttribute("rel", "noopener noreferrer nofollow");
        }

        cleanNode(child);
      } else if (child.nodeType === Node.COMMENT_NODE) {
        node.removeChild(child);
      }
    }
  }

  cleanNode(doc.body);
  return doc.body.innerHTML;
}
