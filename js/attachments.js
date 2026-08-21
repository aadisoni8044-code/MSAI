/**
 * MSAI - File & Image Attachment Manager (Multimodal Input)
 */

import { CONFIG } from "./config.js";
import { formatBytes } from "./utils.js";
import { toast } from "./toast.js";

class AttachmentManager {
  constructor() {
    this.attachments = [];
    this.onChangeCallback = null;
  }

  setChangeCallback(cb) {
    this.onChangeCallback = cb;
  }

  getAttachments() {
    return this.attachments;
  }

  clear() {
    this.attachments = [];
    this.renderPreviews();
    if (this.onChangeCallback) this.onChangeCallback(this.attachments);
  }

  async handleFiles(fileList) {
    if (!fileList || fileList.length === 0) return;

    const files = Array.from(fileList);
    const validFiles = [];

    for (const file of files) {
      // Validate file size
      const maxBytes = CONFIG.MAX_FILE_SIZE_MB * 1024 * 1024;
      if (file.size > maxBytes) {
        toast.error(`File "${file.name}" exceeds the ${CONFIG.MAX_FILE_SIZE_MB}MB size limit.`);
        continue;
      }

      // Read file to Base64
      try {
        const base64Data = await this.readFileAsBase64(file);
        const isImage = file.type.startsWith("image/");

        validFiles.push({
          id: "att-" + Date.now() + "-" + Math.random().toString(36).substring(2, 7),
          name: file.name,
          size: file.size,
          mimeType: file.type || "application/octet-stream",
          data: base64Data,
          isImage,
        });
      } catch (err) {
        console.error("Error reading file:", err);
        toast.error(`Failed to read file: ${file.name}`);
      }
    }

    if (validFiles.length > 0) {
      this.attachments.push(...validFiles);
      this.renderPreviews();
      if (this.onChangeCallback) this.onChangeCallback(this.attachments);
      toast.success(`Attached ${validFiles.length} file${validFiles.length > 1 ? "s" : ""}`);
    }
  }

  readFileAsBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = (error) => reject(error);
      reader.readAsDataURL(file);
    });
  }

  removeAttachment(id) {
    this.attachments = this.attachments.filter((a) => a.id !== id);
    this.renderPreviews();
    if (this.onChangeCallback) this.onChangeCallback(this.attachments);
  }

  renderPreviews() {
    const container = document.getElementById("composer-attachments-preview");
    if (!container) return;

    if (this.attachments.length === 0) {
      container.innerHTML = "";
      container.style.display = "none";
      return;
    }

    container.style.display = "flex";
    container.innerHTML = this.attachments
      .map((att) => {
        let previewHtml = "";
        if (att.isImage) {
          previewHtml = `<img src="${att.data}" alt="${att.name}" class="attachment-thumb" />`;
        } else {
          previewHtml = `
            <div class="attachment-file-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
                <polyline points="14 2 14 8 20 8"/>
              </svg>
            </div>
          `;
        }

        return `
          <div class="attachment-chip" id="${att.id}">
            ${previewHtml}
            <div class="attachment-meta">
              <span class="attachment-name" title="${att.name}">${att.name}</span>
              <span class="attachment-size">${formatBytes(att.size)}</span>
            </div>
            <button type="button" class="attachment-remove-btn" data-remove-id="${att.id}" aria-label="Remove attachment" title="Remove">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"/>
                <line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>
        `;
      })
      .join("");

    // Bind remove events
    container.querySelectorAll(".attachment-remove-btn").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const id = btn.getAttribute("data-remove-id");
        this.removeAttachment(id);
      });
    });
  }
}

export const attachmentManager = new AttachmentManager();
