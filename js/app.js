import { themeManager } from './theme.js';
import { toast } from './toast.js';
import { sidebar } from './sidebar.js';
import { settingsManager } from './settings.js';
import { searchManager } from './search.js';
import { chatController } from './chat.js';
import { setupKeyboardShortcuts } from './shortcuts.js';
import { conversationManager } from './conversations.js';

/**
 * Main Application Bootstrapper
 */
document.addEventListener('DOMContentLoaded', async () => {
    try {
        // Initialize Core System Services
        toast.init();
        themeManager.init();

        // Initialize Chat Controller
        chatController.init();

        // Initialize Sidebar with event hooks
        sidebar.init({
            onSelectChat: (id) => chatController.loadConversation(id),
            onNewChat: () => chatController.startNewChat(),
            onDeleteChat: async (id) => {
                if (confirm('Are you sure you want to delete this conversation?')) {
                    const isActive = conversationManager.activeConversation?.id === id;
                    await conversationManager.deleteConversation(id);
                    toast.show('Conversation deleted', 'info');
                    if (isActive) {
                        chatController.startNewChat();
                    } else {
                        sidebar.renderConversationsList();
                    }
                }
            }
        });

        // Initialize Settings Manager
        settingsManager.init({
            onSettingsSaved: () => {
                sidebar.renderConversationsList();
                if (conversationManager.activeConversation) {
                    chatController.loadConversation(conversationManager.activeConversation.id);
                } else {
                    chatController.startNewChat();
                }
            }
        });

        // Initialize Search Manager
        searchManager.init({
            onSearchResults: (filteredConversations) => {
                sidebar.renderConversationsList(filteredConversations);
            }
        });

        // Setup Global Keyboard Shortcuts
        setupKeyboardShortcuts({
            onNewChat: () => chatController.startNewChat(),
            onSearchFocus: () => searchManager.focusInput(),
            onCloseModals: () => {
                settingsManager.closeModal();
                sidebar.closeMobileDrawer();
            },
            onToggleSidebar: () => sidebar.toggleCollapse()
        });

        // Bind Dark/Light Theme Switch Button
        const themeToggleBtn = document.getElementById('theme-toggle-btn');
        if (themeToggleBtn) {
            themeToggleBtn.addEventListener('click', () => {
                themeManager.toggleTheme();
            });
        }

        // Initial render of conversations list
        await sidebar.renderConversationsList();

    } catch (err) {
        console.error('Initialization error:', err);
    }
});
