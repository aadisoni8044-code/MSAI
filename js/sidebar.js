import { conversationManager } from './conversations.js';
import { formatTimestamp, escapeHTML } from './utils.js';

/**
 * Sidebar Drawer & Conversations List Manager
 */
export class SidebarManager {
    constructor() {
        this.sidebar = null;
        this.backdrop = null;
        this.listContainer = null;
        this.onSelectChatCallback = null;
        this.onNewChatCallback = null;
        this.onDeleteChatCallback = null;
    }

    init({ onSelectChat, onNewChat, onDeleteChat }) {
        this.onSelectChatCallback = onSelectChat;
        this.onNewChatCallback = onNewChat;
        this.onDeleteChatCallback = onDeleteChat;

        this.sidebar = document.getElementById('sidebar');
        this.backdrop = document.getElementById('sidebar-backdrop');
        this.listContainer = document.getElementById('conversations-list');

        const toggleBtn = document.getElementById('toggle-sidebar-btn');
        const mobileMenuBtn = document.getElementById('mobile-menu-btn');
        const newChatBtn = document.getElementById('new-chat-btn');
        const headerNewChatBtn = document.getElementById('header-new-chat-btn');

        if (toggleBtn) {
            toggleBtn.addEventListener('click', () => this.toggleCollapse());
        }

        if (mobileMenuBtn) {
            mobileMenuBtn.addEventListener('click', () => this.openMobileDrawer());
        }

        if (this.backdrop) {
            this.backdrop.addEventListener('click', () => this.closeMobileDrawer());
        }

        if (newChatBtn) {
            newChatBtn.addEventListener('click', () => {
                this.closeMobileDrawer();
                if (this.onNewChatCallback) this.onNewChatCallback();
            });
        }

        if (headerNewChatBtn) {
            headerNewChatBtn.addEventListener('click', () => {
                if (this.onNewChatCallback) this.onNewChatCallback();
            });
        }
    }

    toggleCollapse() {
        this.sidebar.classList.toggle('collapsed');
    }

    openMobileDrawer() {
        this.sidebar.classList.add('mobile-open');
        if (this.backdrop) this.backdrop.classList.add('active');
    }

    closeMobileDrawer() {
        this.sidebar.classList.remove('mobile-open');
        if (this.backdrop) this.backdrop.classList.remove('active');
    }

    async renderConversationsList(conversations = null) {
        if (!conversations) {
            conversations = await conversationManager.getConversations();
        }

        if (!conversations || conversations.length === 0) {
            this.listContainer.innerHTML = '<div style="padding: 1rem; text-align: center; color: var(--text-muted); font-size: 0.85rem;">No recent chats</div>';
            return;
        }

        const activeId = conversationManager.activeConversation?.id;

        this.listContainer.innerHTML = `
            <div class="conversation-group">
                <div class="sidebar-section-title">Recent Chats</div>
                ${conversations.map(c => `
                    <div class="chat-item ${c.id === activeId ? 'active' : ''}" data-id="${c.id}">
                        <div class="chat-item-info">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                            <span class="chat-item-title" title="${escapeHTML(c.title)}">${escapeHTML(c.title)}</span>
                        </div>
                        <div class="chat-item-actions">
                            <button class="delete-chat-btn icon-btn" data-id="${c.id}" title="Delete chat" style="width: 24px; height: 24px;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                            </button>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;

        // Bind chat item events
        this.listContainer.querySelectorAll('.chat-item').forEach(item => {
            item.addEventListener('click', (e) => {
                if (e.target.closest('.delete-chat-btn')) return; // Ignore if delete icon clicked
                const id = item.getAttribute('data-id');
                this.closeMobileDrawer();
                if (this.onSelectChatCallback) this.onSelectChatCallback(id);
            });
        });

        // Bind delete events
        this.listContainer.querySelectorAll('.delete-chat-btn').forEach(btn => {
            btn.addEventListener('click', async (e) => {
                e.stopPropagation();
                const id = btn.getAttribute('data-id');
                if (this.onDeleteChatCallback) this.onDeleteChatCallback(id);
            });
        });
    }
}

export const sidebar = new SidebarManager();
