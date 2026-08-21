/**
 * Sidebar UI Controller
 * Controls desktop collapsing, mobile drawer toggling, and list rendering.
 */

import { conversations } from './conversations.js';
import { search } from './search.js';
import { modal } from './modal.js';
import { escapeHtml } from './sanitizer.js';

export class SidebarController {
    constructor() {
        this.sidebarEl = document.getElementById("app-sidebar");
        this.overlayEl = document.getElementById("sidebar-overlay");
        this.conversationsContainer = document.getElementById("conversations-list");
        this.searchInput = document.getElementById("search-chats-input");
        this.pendingRenameId = null;
    }

    init() {
        const toggleBtn = document.getElementById("btn-toggle-sidebar");
        const mobileBtn = document.getElementById("btn-mobile-menu");

        if (toggleBtn) {
            toggleBtn.addEventListener("click", () => this.toggleCollapse());
        }
        if (mobileBtn) {
            mobileBtn.addEventListener("click", () => this.openMobileSidebar());
        }
        if (this.overlayEl) {
            this.overlayEl.addEventListener("click", () => this.closeMobileSidebar());
        }

        if (this.searchInput) {
            this.searchInput.addEventListener("input", (e) => {
                this.renderConversations(conversations.conversations, conversations.activeConversationId, e.target.value);
            });
        }

        // Rename modal confirm listener
        const confirmRenameBtn = document.getElementById("btn-confirm-rename");
        if (confirmRenameBtn) {
            confirmRenameBtn.addEventListener("click", () => {
                const titleInput = document.getElementById("rename-title-input");
                if (this.pendingRenameId && titleInput && titleInput.value.trim()) {
                    conversations.renameConversation(this.pendingRenameId, titleInput.value.trim());
                    this.pendingRenameId = null;
                    modal.closeActiveModal();
                }
            });
        }
    }

    toggleCollapse() {
        if (this.sidebarEl) {
            this.sidebarEl.classList.toggle("collapsed");
        }
    }

    openMobileSidebar() {
        if (this.sidebarEl && this.overlayEl) {
            this.sidebarEl.classList.add("mobile-open");
            this.overlayEl.classList.add("active");
        }
    }

    closeMobileSidebar() {
        if (this.sidebarEl && this.overlayEl) {
            this.sidebarEl.classList.remove("mobile-open");
            this.overlayEl.classList.remove("active");
        }
    }

    renderConversations(allConversations, activeId, searchQuery = "") {
        if (!this.conversationsContainer) return;

        const filtered = search.filterConversations(allConversations, searchQuery);

        if (filtered.length === 0) {
            this.conversationsContainer.innerHTML = `
                <div class="sidebar-section-title">Conversations</div>
                <div style="padding:1rem; font-size:0.85rem; color:var(--text-tertiary); text-align:center;">
                    ${searchQuery ? 'No matching chats found' : 'No previous conversations'}
                </div>
            `;
            return;
        }

        let html = `<div class="sidebar-section-title">Recent Conversations</div>`;

        filtered.forEach(conv => {
            const isActive = conv.id === activeId ? 'active' : '';
            html += `
                <div class="chat-item ${isActive}" data-id="${conv.id}">
                    <div class="chat-item-title-wrapper">
                        <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><path d="M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 9h12v2H6V9zm8 5H6v-2h8v2zm4-6H6V6h12v2z"/></svg>
                        <span class="chat-item-title">${escapeHtml(conv.title)}</span>
                    </div>
                    <div class="chat-item-actions">
                        <button class="chat-action-btn btn-rename" data-id="${conv.id}" title="Rename">
                            <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
                        </button>
                        <button class="chat-action-btn btn-delete" data-id="${conv.id}" title="Delete">
                            <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
                        </button>
                    </div>
                </div>
            `;
        });

        this.conversationsContainer.innerHTML = html;

        // Attach event listeners
        this.conversationsContainer.querySelectorAll(".chat-item").forEach(item => {
            item.addEventListener("click", (e) => {
                if (e.target.closest(".chat-action-btn")) return;
                const id = item.getAttribute("data-id");
                conversations.setActiveConversation(id);
                this.closeMobileSidebar();
            });
        });

        this.conversationsContainer.querySelectorAll(".btn-rename").forEach(btn => {
            btn.addEventListener("click", (e) => {
                e.stopPropagation();
                const id = btn.getAttribute("data-id");
                const conv = conversations.getConversation(id);
                if (conv) {
                    this.pendingRenameId = id;
                    const renameInput = document.getElementById("rename-title-input");
                    if (renameInput) renameInput.value = conv.title;
                    modal.openModal("modal-rename");
                }
            });
        });

        this.conversationsContainer.querySelectorAll(".btn-delete").forEach(btn => {
            btn.addEventListener("click", (e) => {
                e.stopPropagation();
                const id = btn.getAttribute("data-id");
                if (confirm("Are you sure you want to delete this conversation?")) {
                    conversations.deleteConversation(id);
                }
            });
        });
    }
}

export const sidebar = new SidebarController();
