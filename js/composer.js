/**
 * Composer UI Controller Module
 * Handles auto-expanding textareas, input validation, send/stop generation triggers, and file preview rendering.
 */

import { attachments } from './attachments.js';
import { conversations } from './conversations.js';
import { api } from './api.js';
import { renderer } from './renderer.js';
import { voice } from './voice.js';
import { toast } from './toast.js';
import { escapeHtml } from './sanitizer.js';

export class ComposerController {
    constructor() {
        this.textarea = document.getElementById("composer-textarea");
        this.btnSend = document.getElementById("btn-send");
        this.btnStop = document.getElementById("btn-stop");
        this.attachmentInput = document.getElementById("attachment-input");
        this.attachmentPreviewBar = document.getElementById("attachment-preview-bar");
        this.charCounter = document.getElementById("char-counter");
        this.btnVoice = document.getElementById("btn-voice-input");
        this.isGenerating = false;
    }

    init() {
        if (this.textarea) {
            this.textarea.addEventListener("input", () => {
                this.autoResizeTextarea();
                this.updateCharCounter();
            });

            this.textarea.addEventListener("keydown", (e) => {
                if (e.key === "Enter" && !e.shiftKey) {
                    const isEnterToSend = localStorage.getItem("msai_enter_to_send") !== "false";
                    if (isEnterToSend) {
                        e.preventDefault();
                        this.handleSend();
                    }
                }
            });
        }

        if (this.btnSend) {
            this.btnSend.addEventListener("click", () => this.handleSend());
        }

        if (this.btnStop) {
            this.btnStop.addEventListener("click", () => this.handleStop());
        }

        if (this.attachmentInput) {
            this.attachmentInput.addEventListener("change", (e) => {
                if (e.target.files && e.target.files.length > 0) {
                    attachments.handleFileInput(e.target.files);
                    e.target.value = ""; // Reset input
                }
            });
        }

        attachments.setOnChange((atts) => this.renderAttachmentPreviews(atts));

        if (this.btnVoice) {
            this.btnVoice.addEventListener("click", () => {
                voice.start(
                    (transcript) => {
                        if (this.textarea) {
                            this.textarea.value = transcript;
                            this.autoResizeTextarea();
                            this.updateCharCounter();
                        }
                    },
                    (isListening) => {
                        if (isListening) {
                            this.btnVoice.style.color = "var(--status-error)";
                            toast.show("Listening... Speak now", "info");
                        } else {
                            this.btnVoice.style.color = "";
                        }
                    }
                );
            });
        }

        // Handle suggestion cards on welcome screen
        document.querySelectorAll(".suggestion-card").forEach(card => {
            card.addEventListener("click", () => {
                const prompt = card.getAttribute("data-prompt");
                if (prompt) {
                    if (this.textarea) {
                        this.textarea.value = prompt;
                        this.autoResizeTextarea();
                        this.updateCharCounter();
                    }
                    this.handleSend();
                }
            });
        });
    }

    autoResizeTextarea() {
        if (!this.textarea) return;
        this.textarea.style.height = "auto";
        this.textarea.style.height = `${Math.min(this.textarea.scrollHeight, 200)}px`;
    }

    updateCharCounter() {
        if (!this.textarea || !this.charCounter) return;
        const len = this.textarea.value.length;
        this.charCounter.textContent = `${len} chars`;
    }

    renderAttachmentPreviews(atts) {
        if (!this.attachmentPreviewBar) return;

        if (!atts || atts.length === 0) {
            this.attachmentPreviewBar.style.display = "none";
            this.attachmentPreviewBar.innerHTML = "";
            return;
        }

        this.attachmentPreviewBar.style.display = "flex";
        let html = "";
        atts.forEach(att => {
            if (att.isImage) {
                html += `
                    <div class="attachment-chip">
                        <img src="data:${att.mimeType};base64,${att.base64}" alt="Preview">
                        <span>${escapeHtml(att.name)}</span>
                        <span class="attachment-remove" data-id="${att.id}">&times;</span>
                    </div>
                `;
            } else {
                html += `
                    <div class="attachment-chip">
                        <span>📄 ${escapeHtml(att.name)}</span>
                        <span class="attachment-remove" data-id="${att.id}">&times;</span>
                    </div>
                `;
            }
        });

        this.attachmentPreviewBar.innerHTML = html;

        this.attachmentPreviewBar.querySelectorAll(".attachment-remove").forEach(btn => {
            btn.addEventListener("click", () => {
                const id = btn.getAttribute("data-id");
                attachments.removeAttachment(id);
            });
        });
    }

    setGeneratingState(generating) {
        this.isGenerating = generating;
        if (generating) {
            if (this.btnSend) this.btnSend.style.display = "none";
            if (this.btnStop) this.btnStop.style.display = "inline-flex";
        } else {
            if (this.btnSend) this.btnSend.style.display = "inline-flex";
            if (this.btnStop) this.btnStop.style.display = "none";
        }
    }

    async handleSend() {
        if (this.isGenerating) return;

        const content = this.textarea ? this.textarea.value.trim() : "";
        const activeAtts = attachments.getAttachments();

        if (!content && activeAtts.length === 0) return;

        // Clear input state
        if (this.textarea) {
            this.textarea.value = "";
            this.autoResizeTextarea();
            this.updateCharCounter();
        }

        // Add user message
        await conversations.addMessage("user", content, [...activeAtts]);
        attachments.clear();

        // Render current state and start assistant response stream
        let activeConv = conversations.getActiveConversation();
        renderer.renderConversation(activeConv, true);

        this.setGeneratingState(true);

        try {
            // Add placeholder assistant message
            await conversations.addMessage("assistant", "");
            activeConv = conversations.getActiveConversation();

            await api.generateResponse(
                activeConv.messages.slice(0, -1), // Send previous history
                activeAtts,
                async (accumulatedText) => {
                    await conversations.updateLastAssistantMessage(accumulatedText);
                    renderer.renderConversation(conversations.getActiveConversation(), true);
                }
            );

        } catch (err) {
            console.error("API error during generation:", err);
            const errorMsg = err.message || "An unexpected error occurred.";
            toast.show(errorMsg, "error", 5000);
            await conversations.updateLastAssistantMessage(`⚠️ **Error:** ${errorMsg}`);
        } finally {
            this.setGeneratingState(false);
            renderer.renderConversation(conversations.getActiveConversation(), false);
        }
    }

    handleStop() {
        api.cancelRequest();
        this.setGeneratingState(false);
        toast.show("Generation stopped", "warning");
    }
}

export const composer = new ComposerController();
