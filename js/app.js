/**
 * Main Application Bootstrap Entry Point
 * Initializes all modules, wires UI events, state subscribers, and modal triggers.
 */

import { theme } from './theme.js';
import { conversations } from './conversations.js';
import { sidebar } from './sidebar.js';
import { composer } from './composer.js';
import { renderer } from './renderer.js';
import { modal } from './modal.js';
import { settings } from './settings.js';
import { shortcuts } from './shortcuts.js';
import { toast } from './toast.js';
import { getAppConfig } from './config.js';

document.addEventListener("DOMContentLoaded", async () => {
    try {
        // 1. Initialize Theme
        theme.init();

        // 2. Initialize Conversations and Storage
        await conversations.init();

        // 3. Initialize UI Controllers
        sidebar.init();
        composer.init();
        shortcuts.init();

        // 4. Setup Theme Toggle Event Listeners
        const themeToggle = document.getElementById("nav-theme-toggle");
        if (themeToggle) {
            themeToggle.addEventListener("click", () => {
                const newTheme = theme.toggle();
                toast.show(`Switched to ${newTheme} mode`, "info", 1500);
            });
        }

        // 5. New Chat Buttons Event Listeners
        const btnNewChat = document.getElementById("btn-new-chat");
        const btnHeaderNewChat = document.getElementById("btn-header-new-chat");

        if (btnNewChat) {
            btnNewChat.addEventListener("click", () => conversations.createNewConversation());
        }
        if (btnHeaderNewChat) {
            btnHeaderNewChat.addEventListener("click", () => conversations.createNewConversation());
        }

        // 6. Settings Modal Event Listeners
        const btnSettingsNav = document.getElementById("nav-settings-btn");
        const btnSettingsHeader = document.getElementById("btn-header-settings");
        const btnSaveSettings = document.getElementById("btn-save-settings");
        const tempInput = document.getElementById("setting-temperature");

        if (btnSettingsNav) {
            btnSettingsNav.addEventListener("click", () => {
                settings.loadIntoForm();
                modal.openModal("modal-settings");
            });
        }
        if (btnSettingsHeader) {
            btnSettingsHeader.addEventListener("click", () => {
                settings.loadIntoForm();
                modal.openModal("modal-settings");
            });
        }

        if (tempInput) {
            tempInput.addEventListener("input", (e) => {
                const display = document.getElementById("temp-val-display");
                if (display) display.textContent = e.target.value;
            });
        }

        if (btnSaveSettings) {
            btnSaveSettings.addEventListener("click", () => {
                settings.saveFromForm();
                modal.closeActiveModal();
                toast.show("Settings saved successfully", "success");
            });
        }

        // Export Data Listener
        const btnExportData = document.getElementById("btn-export-data");
        if (btnExportData) {
            btnExportData.addEventListener("click", () => {
                const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(conversations.conversations, null, 2));
                const downloadAnchor = document.createElement('a');
                downloadAnchor.setAttribute("href", dataStr);
                downloadAnchor.setAttribute("download", `msai_export_${Date.now()}.json`);
                document.body.appendChild(downloadAnchor);
                downloadAnchor.click();
                downloadAnchor.remove();
                toast.show("Conversations exported", "success");
            });
        }

        // Clear All Data Listener
        const btnClearAll = document.getElementById("btn-clear-all-data");
        if (btnClearAll) {
            btnClearAll.addEventListener("click", async () => {
                if (confirm("Are you sure you want to delete ALL conversations permanently?")) {
                    await conversations.clearAllData();
                    modal.closeActiveModal();
                    toast.show("All data cleared", "info");
                }
            });
        }

        // Setup regenerate handler for assistant responses
        window.msaiRegenerateHandler = async (msgId) => {
            const activeConv = conversations.getActiveConversation();
            if (!activeConv || composer.isGenerating) return;

            const msgIndex = activeConv.messages.findIndex(m => m.id === msgId);
            if (msgIndex !== -1 && activeConv.messages[msgIndex].role === 'assistant') {
                // Truncate from this assistant message onwards
                activeConv.messages = activeConv.messages.slice(0, msgIndex);
                await conversations.addMessage("assistant", "");

                composer.setGeneratingState(true);
                renderer.renderConversation(conversations.getActiveConversation(), true);

                try {
                    await api.generateResponse(
                        conversations.getActiveConversation().messages.slice(0, -1),
                        [],
                        async (accumulatedText) => {
                            await conversations.updateLastAssistantMessage(accumulatedText);
                            renderer.renderConversation(conversations.getActiveConversation(), true);
                        }
                    );
                } catch (err) {
                    toast.show(err.message || "Failed to regenerate response", "error");
                    await conversations.updateLastAssistantMessage(`⚠️ **Error:** ${err.message}`);
                } finally {
                    composer.setGeneratingState(false);
                    renderer.renderConversation(conversations.getActiveConversation(), false);
                }
            }
        };

        // 7. Subscribe UI to Conversation State Changes
        conversations.subscribe((allConvs, activeConv) => {
            const searchInput = document.getElementById("search-chats-input");
            const query = searchInput ? searchInput.value : "";
            sidebar.renderConversations(allConvs, activeConv ? activeConv.id : null, query);
            renderer.renderConversation(activeConv);
        });

        // Initial Render
        const initialActiveConv = conversations.getActiveConversation();
        sidebar.renderConversations(conversations.conversations, initialActiveConv ? initialActiveConv.id : null);
        renderer.renderConversation(initialActiveConv);

        // Model Selector Badge
        const config = getAppConfig();
        const modelBadgeName = document.getElementById("current-model-name");
        if (modelBadgeName) {
            modelBadgeName.textContent = config.MODEL || "gemini-2.5-flash";
        }

        console.log("MSAI initialized successfully!");

    } catch (err) {
        console.error("Failed to initialize MSAI application:", err);
    }
});
