/**
 * MSAI - Sidebar & Conversation List Manager
 */

import { storage } from "./storage.js";
import { conversationManager } from "./conversations.js";
import { getChatGroup, formatDate, downloadFile } from "./utils.js";
import { escapeHtml } from "./sanitizer.js";
import { toast } from "./toast.js";

export class Sidebar {
  constructor() {
    this.sidebarEl = null;
    this.historyListEl = null;
    this.chatCountBadgeEl = null;
    this.isCollapsed = false;
    this.isMobileOpen = false;
    this.onSelectChatCallback = null;
    this.onNewChatCallback = null;
  }

  init({ sidebarEl, historyListEl, chatCountBadgeEl, onSelectChat, onNewChat }) {
    this.sidebarEl = sidebarEl;
    this.historyListEl = historyListEl;
    this.chatCountBadgeEl = chatCountBadgeEl;
    this.onSelectChatCallback = onSelectChat;
    this.onNewChatCallback = onNewChat;

    // Load saved collapsed state
    const savedCollapsed = localStorage.getItem("msai_sidebar_collapsed") === "true";
    if (savedCollapsed) {
      this.setCollapsed(true);
    }

    this.bindEvents();
  }

  bindEvents() {
    // New chat buttons
    document.querySelectorAll(".new-chat-trigger-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        if (this.onNewChatCallback) this.onNewChatCallback();
        if (window.innerWidth < 768) this.closeMobile();
      });
    });

    // Collapse toggle buttons
    document.querySelectorAll(".sidebar-toggle-btn").forEach((btn) => {
      btn.addEventListener("click", () => this.toggleCollapse());
    });

    // Mobile overlay close
    const overlay = document.getElementById("mobile-sidebar-overlay");
    overlay?.addEventListener("click", () => this.closeMobile());
  }

  toggleCollapse() {
    this.setCollapsed(!this.isCollapsed);
  }

  setCollapsed(collapsed) {
    this.isCollapsed = collapsed;
    localStorage.setItem("msai_sidebar_collapsed", collapsed ? "true" : "false");

    if (this.sidebarEl) {
      if (collapsed) {
        this.sidebarEl.classList.add("sidebar-collapsed");
        document.body.classList.add("sidebar-is-collapsed");
      } else {
        this.sidebarEl.classList.remove("sidebar-collapsed");
        document.body.classList.remove("sidebar-is-collapsed");
      }
    }
  }

  openMobile() {
    this.isMobileOpen = true;
    this.sidebarEl?.classList.add("mobile-open");
    const overlay = document.getElementById("mobile-sidebar-overlay");
    if (overlay) overlay.classList.add("active");
  }

  closeMobile() {
    this.isMobileOpen = false;
    this.sidebarEl?.classList.remove("mobile-open");
    const overlay = document.getElementById("mobile-sidebar-overlay");
    if (overlay) overlay.classList.remove("active");
  }

  async renderConversationList() {
    if (!this.historyListEl) return;

    const conversations = await storage.getAllConversations();
    const activeChatId = storage.getActiveChatId();

    // Update count badge
    if (this.chatCountBadgeEl) {
      this.chatCountBadgeEl.textContent = conversations.length.toString();
    }

    if (conversations.length === 0) {
      this.historyListEl.innerHTML = `
        <div class="empty-history-state">
          <p>No conversations yet</p>
          <span>Start a new chat to begin</span>
        </div>
      `;
      return;
    }

    // Group conversations by date & pinned
    const pinnedChats = [];
    const groups = {
      Today: [],
      Yesterday: [],
      "Previous 7 Days": [],
      "Previous 30 Days": [],
      Older: [],
    };

    conversations.forEach((conv) => {
      if (conv.pinned) {
        pinnedChats.push(conv);
      } else {
        const group = getChatGroup(conv.updatedAt);
        if (groups[group]) {
          groups[group].push(conv);
        } else {
          groups["Older"].push(conv);
        }
      }
    });

    let html = "";

    // Pinned group
    if (pinnedChats.length > 0) {
      html += `<div class="history-group-header">Pinned</div>`;
      html += pinnedChats.map((c) => this.renderChatItem(c, c.id === activeChatId)).join("");
    }

    // Date groups
    Object.entries(groups).forEach(([groupName, chats]) => {
      if (chats.length > 0) {
        html += `<div class="history-group-header">${groupName}</div>`;
        html += chats.map((c) => this.renderChatItem(c, c.id === activeChatId)).join("");
      }
    });

    this.historyListEl.innerHTML = html;
    this.bindChatListEvents();
  }

  renderChatItem(conv, isActive) {
    const rawTitle = conv.title || "New Conversation";
    const safeTitle = escapeHtml(rawTitle);
    const safeId = escapeHtml(conv.id);

    return `
      <div class="chat-item-wrapper ${isActive ? "active" : ""}" data-chat-id="${safeId}" id="chat-item-${safeId}">
        <button class="chat-item-btn" title="${safeTitle}">
          <div class="chat-item-icon">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
            </svg>
          </div>
          <span class="chat-item-title">${safeTitle}</span>
        </button>
        <div class="chat-item-actions">
          <button class="chat-action-menu-btn" data-chat-id="${safeId}" title="Options" aria-label="Conversation options">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="1"/>
              <circle cx="12" cy="5" r="1"/>
              <circle cx="12" cy="19" r="1"/>
            </svg>
          </button>
          <div class="chat-dropdown-menu" id="dropdown-${safeId}">
            <button class="dropdown-item rename-chat-btn" data-chat-id="${safeId}">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/></svg>
              <span>Rename</span>
            </button>
            <button class="dropdown-item pin-chat-btn" data-chat-id="${safeId}">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="17" x2="12" y2="22"/><path d="M5 17h14v-1.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V6h1a2 2 0 0 0 0-4H8a2 2 0 0 0 0 4h1v4.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24Z"/></svg>
              <span>${conv.pinned ? "Unpin" : "Pin"}</span>
            </button>
            <button class="dropdown-item export-chat-btn" data-chat-id="${safeId}">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
              <span>Export Markdown</span>
            </button>
            <div class="dropdown-divider"></div>
            <button class="dropdown-item delete-chat-btn delete-danger" data-chat-id="${safeId}">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>
              <span>Delete</span>
            </button>
          </div>
        </div>
      </div>
    `;
  }

  bindChatListEvents() {
    // Select chat
    this.historyListEl.querySelectorAll(".chat-item-btn").forEach((btn) => {
      btn.addEventListener("click", () => {
        const item = btn.closest(".chat-item-wrapper");
        const chatId = item?.getAttribute("data-chat-id");
        if (chatId && this.onSelectChatCallback) {
          this.onSelectChatCallback(chatId);
          if (window.innerWidth < 768) this.closeMobile();
        }
      });
    });

    // Toggle menu
    this.historyListEl.querySelectorAll(".chat-action-menu-btn").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const chatId = btn.getAttribute("data-chat-id");
        const dropdown = document.getElementById(`dropdown-${chatId}`);

        // Close other dropdowns
        document.querySelectorAll(".chat-dropdown-menu.show").forEach((d) => {
          if (d !== dropdown) d.classList.remove("show");
        });

        dropdown?.classList.toggle("show");
      });
    });

    // Rename chat
    this.historyListEl.querySelectorAll(".rename-chat-btn").forEach((btn) => {
      btn.addEventListener("click", async (e) => {
        e.stopPropagation();
        document.querySelectorAll(".chat-dropdown-menu.show").forEach((d) => d.classList.remove("show"));
        const chatId = btn.getAttribute("data-chat-id");
        const conv = await storage.getConversationById(chatId);
        if (!conv) return;

        const newTitle = prompt("Enter new title for conversation:", conv.title);
        if (newTitle && newTitle.trim()) {
          await conversationManager.renameConversation(chatId, newTitle.trim());
          await this.renderConversationList();
          toast.success("Conversation renamed.");
        }
      });
    });

    // Pin chat
    this.historyListEl.querySelectorAll(".pin-chat-btn").forEach((btn) => {
      btn.addEventListener("click", async (e) => {
        e.stopPropagation();
        document.querySelectorAll(".chat-dropdown-menu.show").forEach((d) => d.classList.remove("show"));
        const chatId = btn.getAttribute("data-chat-id");
        await conversationManager.togglePin(chatId);
        await this.renderConversationList();
        toast.info("Conversation updated.");
      });
    });

    // Export markdown
    this.historyListEl.querySelectorAll(".export-chat-btn").forEach((btn) => {
      btn.addEventListener("click", async (e) => {
        e.stopPropagation();
        document.querySelectorAll(".chat-dropdown-menu.show").forEach((d) => d.classList.remove("show"));
        const chatId = btn.getAttribute("data-chat-id");
        const conv = await storage.getConversationById(chatId);
        if (conv) {
          const md = storage.exportConversationAsMarkdown(conv);
          downloadFile(md, `${(conv.title || "msai-chat").replace(/\s+/g, "_")}.md`, "text/markdown");
          toast.success("Exported conversation as Markdown!");
        }
      });
    });

    // Delete chat
    this.historyListEl.querySelectorAll(".delete-chat-btn").forEach((btn) => {
      btn.addEventListener("click", async (e) => {
        e.stopPropagation();
        document.querySelectorAll(".chat-dropdown-menu.show").forEach((d) => d.classList.remove("show"));
        const chatId = btn.getAttribute("data-chat-id");
        if (confirm("Delete this conversation? This action cannot be undone.")) {
          await conversationManager.deleteConversation(chatId);
          await this.renderConversationList();
          toast.success("Conversation deleted.");
        }
      });
    });

    // Global click listener to close dropdowns
    document.addEventListener("click", () => {
      document.querySelectorAll(".chat-dropdown-menu.show").forEach((d) => d.classList.remove("show"));
    });
  }
}

export const sidebar = new Sidebar();
