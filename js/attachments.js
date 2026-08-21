import { CONFIG } from './config.js';
import { fileToBase64 } from './utils.js';
import { toast } from './toast.js';

/**
 * File & Image Attachments Manager
 */
export class AttachmentsManager {
    constructor() {
        this.attachments = [];
        this.previewContainer = null;
    }

    init(previewContainerElement) {
        this.previewContainer = previewContainerElement;
    }

    async addFiles(files) {
        for (const file of files) {
            if (file.size > CONFIG.MAX_ATTACHMENT_SIZE_MB * 1024 * 1024) {
                toast.show(`File ${file.name} exceeds ${CONFIG.MAX_ATTACHMENT_SIZE_MB}MB limit`, 'error');
                continue;
            }

            try {
                const base64Obj = await fileToBase64(file);
                this.attachments.push(base64Obj);
            } catch (err) {
                toast.show(`Failed to process file ${file.name}`, 'error');
            }
        }
        this.renderPreviews();
    }

    removeAttachment(index) {
        this.attachments.splice(index, 1);
        this.renderPreviews();
    }

    clear() {
        this.attachments = [];
        this.renderPreviews();
    }

    getAttachments() {
        return this.attachments;
    }

    renderPreviews() {
        if (!this.previewContainer) return;

        if (this.attachments.length === 0) {
            this.previewContainer.style.display = 'none';
            this.previewContainer.innerHTML = '';
            return;
        }

        this.previewContainer.style.display = 'flex';
        this.previewContainer.innerHTML = this.attachments.map((att, idx) => `
            <div class="attachment-chip">
                ${att.mimeType.startsWith('image/') ? `<img src="${att.dataUrl}" alt="preview">` : '📄'}
                <span class="attachment-name">${att.name}</span>
                <span class="remove-attachment-btn" data-index="${idx}">&times;</span>
            </div>
        `).join('');

        this.previewContainer.querySelectorAll('.remove-attachment-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const idx = parseInt(e.target.getAttribute('data-index'), 10);
                this.removeAttachment(idx);
            });
        });
    }
}

export const attachmentsManager = new AttachmentsManager();
