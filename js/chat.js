/**
 * MSAI - Main Chat Workflow Orchestrator
 */

import { conversationManager } from "./conversations.js";
import { api } from "./api.js";
import { renderer } from "./renderer.js";
import { composer } from "./composer.js";
import { sidebar } from "./sidebar.js";
import { toast } from "./toast.js";
import { storage } from "./storage.js";

class ChatController {
  constructor() {
    this.isGenerating = false;
    this.currentStreamingMsgId = null;
  }

  init() {
    // Subscribe to conversation manager updates
    conversationManager.subscribe((event, data) => {
      if (event === "conversation:loaded" || event === "conversation:created") {
        renderer.renderConversation(data, { autoScroll: true });
        sidebar.renderConversationList();
      } else if (event === "conversation:updated" || event === "conversation:deleted") {
        sidebar.renderConversationList();
      }
    });

    // Delegate message bubble action events (Edit, Regenerate, Retry)
    document.addEventListener("click", async (e) => {
      const target = e.target.closest("button");
      if (!target) return;

      // Edit prompt
      if (target.classList.contains("edit-msg-btn")) {
        const msgId = target.getAttribute("data-msg-id");
        this.handleEditPrompt(msgId);
      }

      // Regenerate assistant response
      if (target.classList.contains("regenerate-btn")) {
        const msgId = target.getAttribute("data-msg-id");
        this.handleRegenerate(msgId);
      }

      // Retry failed message
      if (target.classList.contains("retry-msg-btn")) {
        this.handleRetry();
      }
    });
  }

  async handleSendMessage(userPrompt, attachments = []) {
    if (this.isGenerating) {
      toast.warning("Please wait for the current response to finish, or click Stop.");
      return;
    }

    let conv = conversationManager.getCurrentConversation();
    const isFirstMessage = !conv || conv.messages.length === 0;

    // 1. Add user message
    const userMsg = await conversationManager.addMessage("user", userPrompt, attachments);
    renderer.appendMessageElement(userMsg, true);

    // 2. Prepare assistant placeholder & thinking state
    this.isGenerating = true;
    composer.setGenerating(true);
    renderer.showThinkingIndicator();

    const historyPayload = conversationManager.getHistoryForAPI();

    let assistantMsg = null;
    let accumulatedText = "";

    try {
      await api.sendMessage({
        messages: historyPayload,
        onChunk: (chunk, fullText) => {
          renderer.removeThinkingIndicator();
          if (!assistantMsg) {
            // First chunk received: create assistant message in state
            assistantMsg = {
              id: "msg-" + Date.now(),
              role: "assistant",
              content: fullText,
              timestamp: new Date().toISOString(),
            };
            this.currentStreamingMsgId = assistantMsg.id;
            renderer.appendMessageElement(assistantMsg, true);
          } else {
            renderer.updateStreamingMessage(assistantMsg.id, fullText);
          }
          accumulatedText = fullText;
        },
        onDone: async (finalText, wasAborted) => {
          renderer.removeThinkingIndicator();
          this.isGenerating = false;
          composer.setGenerating(false);

          if (accumulatedText) {
            // Persist the assistant message
            const savedMsg = await conversationManager.addMessage("assistant", accumulatedText);
            if (assistantMsg) {
              renderer.finalizeStreamingMessage(assistantMsg.id, savedMsg);
            }
          }

          // If this was the first message, generate a smart title
          if (isFirstMessage && userPrompt && conv?.id) {
            this.triggerTitleGeneration(userPrompt, conv.id);
          }

          sidebar.renderConversationList();

          if (wasAborted) {
            toast.info("Generation stopped.");
          }
        },
        onError: (err) => {
          renderer.removeThinkingIndicator();
          this.isGenerating = false;
          composer.setGenerating(false);

          const friendlyMsg = err?.message || "An unexpected error occurred. Please try again.";
          renderer.appendErrorElement(friendlyMsg, () => {
            this.handleRetry();
          });
          toast.error(friendlyMsg);
        },
      });
    } catch (e) {
      console.error("Chat flow error:", e);
      this.isGenerating = false;
      composer.setGenerating(false);
      renderer.removeThinkingIndicator();
    }
  }

  async triggerTitleGeneration(prompt, targetConvId) {
    try {
      const generatedTitle = await api.generateTitle(prompt);
      if (generatedTitle && targetConvId) {
        const conv = await storage.getConversationById(targetConvId);
        if (conv) {
          await conversationManager.renameConversation(targetConvId, generatedTitle);
        }
      }
    } catch (e) {
      console.warn("Could not generate AI title:", e);
    }
  }

  handleStop() {
    if (this.isGenerating) {
      api.abortCurrentRequest();
      this.isGenerating = false;
      composer.setGenerating(false);
      renderer.removeThinkingIndicator();
    }
  }

  async handleRegenerate(msgId) {
    const conv = conversationManager.getCurrentConversation();
    if (!conv || this.isGenerating) return;

    // Find the message index
    const msgIndex = conv.messages.findIndex((m) => m.id === msgId);
    if (msgIndex <= 0) return;

    // Remove this and any following messages
    conv.messages = conv.messages.slice(0, msgIndex);
    await storage.saveConversation(conv);
    renderer.renderConversation(conv);

    // Get the last user message to resend
    const lastUserMsg = conv.messages[conv.messages.length - 1];
    if (lastUserMsg && lastUserMsg.role === "user") {
      this.resendPrompt(lastUserMsg.content, lastUserMsg.attachments);
    }
  }

  async resendPrompt(prompt, attachments) {
    this.isGenerating = true;
    composer.setGenerating(true);
    renderer.removeErrorElements();
    renderer.showThinkingIndicator();

    const historyPayload = conversationManager.getHistoryForAPI();

    let assistantMsg = null;
    let accumulatedText = "";

    try {
      await api.sendMessage({
        messages: historyPayload,
        onChunk: (chunk, fullText) => {
          renderer.removeThinkingIndicator();
          if (!assistantMsg) {
            assistantMsg = {
              id: "msg-" + Date.now(),
              role: "assistant",
              content: fullText,
              timestamp: new Date().toISOString(),
            };
            this.currentStreamingMsgId = assistantMsg.id;
            renderer.appendMessageElement(assistantMsg, true);
          } else {
            renderer.updateStreamingMessage(assistantMsg.id, fullText);
          }
          accumulatedText = fullText;
        },
        onDone: async (finalText, wasAborted) => {
          renderer.removeThinkingIndicator();
          this.isGenerating = false;
          composer.setGenerating(false);

          if (accumulatedText) {
            const savedMsg = await conversationManager.addMessage("assistant", accumulatedText);
            if (assistantMsg) {
              renderer.finalizeStreamingMessage(assistantMsg.id, savedMsg);
            }
          }
          sidebar.renderConversationList();
        },
        onError: (err) => {
          renderer.removeThinkingIndicator();
          this.isGenerating = false;
          composer.setGenerating(false);

          const friendlyMsg = err?.message || "An unexpected error occurred. Please try again.";
          renderer.appendErrorElement(friendlyMsg, () => {
            this.handleRetry();
          });
          toast.error(friendlyMsg);
        },
      });
    } catch (e) {
      this.isGenerating = false;
      composer.setGenerating(false);
      renderer.removeThinkingIndicator();
    }
  }

  async handleEditPrompt(msgId) {
    const conv = conversationManager.getCurrentConversation();
    if (!conv) return;

    const msg = conv.messages.find((m) => m.id === msgId);
    if (!msg) return;

    composer.setPrompt(msg.content, false);
    toast.info("Prompt loaded into composer for editing.");
  }

  handleRetry() {
    if (this.isGenerating) return;

    renderer.removeErrorElements();

    const conv = conversationManager.getCurrentConversation();
    if (!conv || !conv.messages || conv.messages.length === 0) return;

    // Find the last user message
    const lastUserMsg = [...conv.messages].reverse().find((m) => m.role === "user");
    if (lastUserMsg) {
      this.resendPrompt(lastUserMsg.content, lastUserMsg.attachments);
    }
  }
}

export const chatController = new ChatController();
