/**
 * Sidebar Navigation & Conversation List Controller
 */
import { conversations } from './conversations.js';
import { events } from './events.js';
import { notifications } from './notifications.js';
import { i18n } from './language.js';
import { escapeHtml } from './utils.js';
import { subscriptionsController } from './subscriptions.js';

class SidebarController {
  constructor() {
    this.sidebar = null;
    this.overlay = null;
    this.conversationsContainer = null;
    this.chatCountBadge = null;
    this.btnNewChat = null;
    this.btnToggleSidebar = null;
    this.btnSearchTrigger = null;
    this.navSubscriptions = null;
  }

  init() {
    this.sidebar = document.getElementById('sidebar');
    this.overlay = document.getElementById('sidebarOverlay');
    this.conversationsContainer = document.getElementById('sidebarConversations');
    this.chatCountBadge = document.getElementById('sidebarChatCount');
    this.btnNewChat = document.getElementById('btnNewChat');
    this.btnToggleSidebar = document.getElementById('btnToggleSidebar');
    this.navSubscriptions = document.getElementById('navSubscriptions');

    this.setupEvents();
    this.render();

    events.on('conversations:updated', () => this.render());
    events.on('conversation:active-changed', () => this.render());
    events.on('language:changed', () => this.render());
  }

  setupEvents() {
    // New chat button
    if (this.btnNewChat) {
      this.btnNewChat.addEventListener('click', () => {
        conversations.create('New Chat');
        this.closeMobileSidebar();
      });
    }

    // Toggle collapse on desktop / close drawer on mobile
    if (this.btnToggleSidebar) {
      this.btnToggleSidebar.addEventListener('click', () => {
        if (window.innerWidth <= 768) {
          this.toggleMobileSidebar();
        } else {
          this.sidebar.classList.toggle('collapsed');
        }
      });
    }

    // Overlay click closes mobile drawer
    if (this.overlay) {
      this.overlay.addEventListener('click', () => {
        this.closeMobileSidebar();
      });
    }

    // Subscriptions Nav Item
    if (this.navSubscriptions) {
      this.navSubscriptions.addEventListener('click', () => {
        subscriptionsController.openSubscriptionsView();
        this.closeMobileSidebar();
      });
    }
  }

  toggleMobileSidebar() {
    const isOpen = this.sidebar.classList.toggle('mobile-open');
    this.overlay.classList.toggle('active', isOpen);
  }

  closeMobileSidebar() {
    this.sidebar.classList.remove('mobile-open');
    this.overlay.classList.remove('active');
  }

  render() {
    if (!this.conversationsContainer) return;

    const allChats = conversations.getAll();
    if (this.chatCountBadge) {
      this.chatCountBadge.textContent = allChats.length.toString();
    }

    if (allChats.length === 0) {
      this.conversationsContainer.innerHTML = `
        <div class="conversation-empty-state">
          <div class="conversation-empty-title">${i18n.get('sidebar.noChats', 'No conversations yet')}</div>
          <div class="conversation-empty-subtitle">${i18n.get('sidebar.noChatsSub', 'Start a new chat to begin')}</div>
        </div>
      `;
      return;
    }

    const activeChat = conversations.getActive();
    // Sort pinned on top, then by updatedAt descending
    const sorted = [...allChats].sort((a, b) => {
      if (a.pinned === b.pinned) {
        return b.updatedAt - a.updatedAt;
      }
      return a.pinned ? -1 : 1;
    });

    this.conversationsContainer.innerHTML = '';

    sorted.forEach(chat => {
      const item = document.createElement('div');
      const isActive = activeChat && activeChat.id === chat.id;
      item.className = `conversation-item ${isActive ? 'active' : ''}`;
      item.dataset.id = chat.id;

      const pinIcon = chat.pinned ? `
        <span class="conversation-item-pin" title="${i18n.get('sidebar.pinned', 'Pinned')}">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor">
            <path d="M16 12V4h1V2H7v2h1v8l-2 2v2h5.2v6h1.6v-6H18v-2l-2-2z"/>
          </svg>
        </span>` : '';

      item.innerHTML = `
        ${pinIcon}
        <span class="conversation-item-title">${escapeHtml(chat.title)}</span>
        <div class="conversation-item-actions">
          <button class="btn-icon btn-action-pin" title="${chat.pinned ? i18n.get('sidebar.unpin', 'Unpin') : i18n.get('sidebar.pin', 'Pin')}">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="${chat.pinned ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2">
              <path d="M16 12V4h1V2H7v2h1v8l-2 2v2h5.2v6h1.6v-6H18v-2l-2-2z"/>
            </svg>
          </button>
          <button class="btn-icon btn-action-rename" title="${i18n.get('sidebar.rename', 'Rename')}">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"/>
            </svg>
          </button>
          <button class="btn-icon btn-action-delete" title="${i18n.get('sidebar.delete', 'Delete')}">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="3 6 5 6 21 6"></polyline>
              <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
            </svg>
          </button>
        </div>
      `;

      // Click on item selects conversation
      item.addEventListener('click', (e) => {
        if (e.target.closest('.conversation-item-actions')) return;
        conversations.setActive(chat.id);
        this.closeMobileSidebar();
      });

      // Pin
      item.querySelector('.btn-action-pin').addEventListener('click', (e) => {
        e.stopPropagation();
        conversations.togglePin(chat.id);
      });

      // Rename
      item.querySelector('.btn-action-rename').addEventListener('click', (e) => {
        e.stopPropagation();
        const newTitle = prompt(i18n.get('sidebar.rename', 'Rename chat:'), chat.title);
        if (newTitle) {
          conversations.rename(chat.id, newTitle);
          notifications.info(i18n.get('notifications.renamed', 'Conversation renamed'));
        }
      });

      // Delete
      item.querySelector('.btn-action-delete').addEventListener('click', (e) => {
        e.stopPropagation();
        conversations.delete(chat.id);
        notifications.info(i18n.get('notifications.deleted', 'Conversation deleted'));
      });

      this.conversationsContainer.appendChild(item);
    });
  }
}

export const sidebarController = new SidebarController();
