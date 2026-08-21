import { storage } from './storage.js';
import { attachmentsManager } from './attachments.js';
import { voiceInput } from './voice.js';

/**
 * Textarea Composer Manager
 */
export class ComposerManager {
    constructor() {
        this.textarea = null;
        this.sendBtn = null;
        this.stopBtn = null;
        this.fileBtn = null;
        this.fileInput = null;
        this.voiceBtn = null;
        this.previewContainer = null;
        this.onSendCallback = null;
        this.onStopCallback = null;
    }

    init({ onSend, onStop }) {
        this.onSendCallback = onSend;
        this.onStopCallback = onStop;

        this.textarea = document.getElementById('chat-input');
        this.sendBtn = document.getElementById('send-message-btn');
        this.stopBtn = document.getElementById('stop-generation-btn');
        this.fileBtn = document.getElementById('attach-file-btn');
        this.fileInput = document.getElementById('file-input');
        this.voiceBtn = document.getElementById('voice-input-btn');
        this.previewContainer = document.getElementById('attachments-preview');

        attachmentsManager.init(this.previewContainer);

        this.setupEvents();
    }

    setupEvents() {
        // Auto-expand textarea on typing
        this.textarea.addEventListener('input', () => {
            this.adjustHeight();
        });

        // Keydown Enter vs Shift+Enter
        this.textarea.addEventListener('keydown', (e) => {
            const enterToSend = storage.getSetting('enter_send', true);

            if (e.key === 'Enter' && !e.shiftKey) {
                if (enterToSend) {
                    e.preventDefault();
                    this.handleSend();
                }
            }
        });

        // Click Send
        this.sendBtn.addEventListener('click', () => this.handleSend());

        // Click Stop
        this.stopBtn.addEventListener('click', () => {
            if (this.onStopCallback) this.onStopCallback();
        });

        // Click File Attachment
        this.fileBtn.addEventListener('click', () => this.fileInput.click());

        this.fileInput.addEventListener('change', (e) => {
            if (e.target.files && e.target.files.length > 0) {
                attachmentsManager.addFiles(Array.from(e.target.files));
                this.fileInput.value = '';
            }
        });

        // Click Voice Input
        this.voiceBtn.addEventListener('click', () => {
            voiceInput.toggle((transcript) => {
                this.textarea.value += (this.textarea.value ? ' ' : '') + transcript;
                this.adjustHeight();
            });
        });
    }

    adjustHeight() {
        this.textarea.style.height = 'auto';
        this.textarea.style.height = Math.min(this.textarea.scrollHeight, 200) + 'px';
    }

    handleSend() {
        const text = this.textarea.value.trim();
        const attachments = attachmentsManager.getAttachments();

        if (!text && attachments.length === 0) return; // Prevent empty send

        if (this.onSendCallback) {
            this.onSendCallback(text, attachments);
        }

        // Reset composer
        this.textarea.value = '';
        this.adjustHeight();
        attachmentsManager.clear();
    }

    setGeneratingState(isGenerating) {
        if (isGenerating) {
            this.sendBtn.style.display = 'none';
            this.stopBtn.style.display = 'flex';
            this.textarea.disabled = true;
        } else {
            this.sendBtn.style.display = 'flex';
            this.stopBtn.style.display = 'none';
            this.textarea.disabled = false;
            this.textarea.focus();
        }
    }

    setPrompt(promptText) {
        this.textarea.value = promptText;
        this.adjustHeight();
        this.textarea.focus();
    }
}

export const composer = new ComposerManager();
