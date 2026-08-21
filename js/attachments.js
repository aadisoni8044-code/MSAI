/**
 * Attachment Management Module
 * Handles file selection, validation (size & mime-type), preview generation, and base64 encoding.
 */

export class AttachmentManager {
    constructor() {
        this.attachments = [];
        this.maxFileSizeMB = 10;
        this.onChangeListener = null;
    }

    setOnChange(listener) {
        this.onChangeListener = listener;
    }

    notify() {
        if (this.onChangeListener) {
            this.onChangeListener(this.attachments);
        }
    }

    getAttachments() {
        return this.attachments;
    }

    clear() {
        this.attachments = [];
        this.notify();
    }

    removeAttachment(id) {
        this.attachments = this.attachments.filter(att => att.id !== id);
        this.notify();
    }

    async handleFileInput(files) {
        const fileList = Array.from(files);
        for (const file of fileList) {
            if (file.size > this.maxFileSizeMB * 1024 * 1024) {
                alert(`File ${file.name} exceeds ${this.maxFileSizeMB}MB limit.`);
                continue;
            }

            try {
                const base64Data = await this._fileToBase64(file);
                this.attachments.push({
                    id: 'att_' + Date.now() + '_' + Math.random().toString(36).substring(2, 5),
                    name: file.name,
                    size: file.size,
                    type: file.type || 'text/plain',
                    mimeType: file.type || 'text/plain',
                    isImage: file.type.startsWith('image/'),
                    base64: base64Data
                });
            } catch (err) {
                console.error("Error processing attachment:", err);
            }
        }
        this.notify();
    }

    _fileToBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const result = reader.result;
                // Remove base64 data URL prefix (e.g. "data:image/png;base64,")
                const base64String = result.split(',')[1] || result;
                resolve(base64String);
            };
            reader.onerror = error => reject(error);
            reader.readAsDataURL(file);
        });
    }
}

export const attachments = new AttachmentManager();
