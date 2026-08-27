import React, { useState } from 'react';
import {
  Plus,
  Search,
  MessageSquare,
  Trash2,
  Edit2,
  PanelLeftClose,
  PanelLeft,
  Folder,
  Box,
  Code,
  Sliders,
  Check,
  X
} from 'lucide-react';
import { Conversation } from '../types/chat';

interface SidebarProps {
  conversations: Conversation[];
  activeConversationId: string | null;
  collapsed: boolean;
  mobileOpen: boolean;
  onToggleCollapse: () => void;
  onCloseMobile: () => void;
  onNewChat: () => void;
  onSelectConversation: (id: string) => void;
  onDeleteConversation: (id: string) => void;
  onRenameConversation: (id: string, newTitle: string) => void;
  onOpenSettings: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  conversations,
  activeConversationId,
  collapsed,
  mobileOpen,
  onToggleCollapse,
  onCloseMobile,
  onNewChat,
  onSelectConversation,
  onDeleteConversation,
  onRenameConversation,
  onOpenSettings,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editTitle, setEditTitle] = useState('');

  const filteredConversations = conversations.filter((c) =>
    c.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const startRename = (c: Conversation, e: React.MouseEvent) => {
    e.stopPropagation();
    setEditingId(c.id);
    setEditTitle(c.title);
  };

  const saveRename = (id: string, e?: React.FormEvent) => {
    if (e) e.preventDefault();
    if (editTitle.trim()) {
      onRenameConversation(id, editTitle.trim());
    }
    setEditingId(null);
  };

  const cancelRename = (e: React.MouseEvent) => {
    e.stopPropagation();
    setEditingId(null);
  };

  return (
    <>
      {/* Mobile Backdrop */}
      {mobileOpen && (
        <div className="sidebar-backdrop" onClick={onCloseMobile} />
      )}

      <aside
        className={`sidebar ${collapsed ? 'collapsed' : ''} ${
          mobileOpen ? 'mobile-open' : ''
        }`}
      >
        <div className="sidebar-header">
          <div className="brand-logo">
            <div className="brand-icon">M</div>
            <span>MSAI</span>
          </div>

          <div className="sidebar-actions">
            <button
              className="icon-button"
              title={collapsed ? 'Expand Sidebar' : 'Collapse Sidebar'}
              onClick={onToggleCollapse}
            >
              {collapsed ? <PanelLeft size={18} /> : <PanelLeftClose size={18} />}
            </button>
          </div>
        </div>

        <button className="btn-new-chat" onClick={onNewChat}>
          <Plus size={18} />
          <span>New Chat</span>
        </button>

        {/* Custom Navigation Sections */}
        <div className="sidebar-nav-section">
          <div className="nav-item">
            <Folder size={16} />
            <span>Projects</span>
          </div>
          <div className="nav-item">
            <Box size={16} />
            <span>Artifacts</span>
          </div>
          <div className="nav-item">
            <Code size={16} />
            <span>Code</span>
          </div>
          <div className="nav-item" onClick={onOpenSettings}>
            <Sliders size={16} />
            <span>Customize</span>
          </div>
        </div>

        <div className="sidebar-divider" />

        <div className="chats-header">
          <span>CHATS AND TASKS</span>
          <span className="chats-count-badge">{conversations.length}</span>
        </div>

        <div className="sidebar-search-box">
          <Search size={14} className="sidebar-search-icon" />
          <input
            type="text"
            className="sidebar-search-input"
            placeholder="Search conversations..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        <div className="conversations-list">
          {filteredConversations.length === 0 ? (
            <div className="no-conversations">
              <p>No conversations yet</p>
              <small>Start a new chat to begin</small>
            </div>
          ) : (
            filteredConversations.map((c) => {
              const isActive = c.id === activeConversationId;
              const isEditing = c.id === editingId;

              return (
                <div
                  key={c.id}
                  className={`conversation-item ${isActive ? 'active' : ''}`}
                  onClick={() => {
                    onSelectConversation(c.id);
                    onCloseMobile();
                  }}
                >
                  <div className="conversation-title-wrapper">
                    <MessageSquare size={15} />
                    {isEditing ? (
                      <form
                        onSubmit={(e) => saveRename(c.id, e)}
                        onClick={(e) => e.stopPropagation()}
                        style={{ display: 'flex', alignItems: 'center', gap: 4, flex: 1 }}
                      >
                        <input
                          type="text"
                          autoFocus
                          value={editTitle}
                          onChange={(e) => setEditTitle(e.target.value)}
                          style={{
                            width: '100%',
                            background: 'var(--bg-input)',
                            border: '1px solid var(--accent-color)',
                            color: 'var(--text-primary)',
                            borderRadius: '4px',
                            padding: '2px 4px',
                            fontSize: '0.82rem',
                          }}
                        />
                        <button
                          type="submit"
                          className="conversation-action-btn"
                          title="Save"
                        >
                          <Check size={14} />
                        </button>
                        <button
                          type="button"
                          className="conversation-action-btn"
                          onClick={cancelRename}
                          title="Cancel"
                        >
                          <X size={14} />
                        </button>
                      </form>
                    ) : (
                      <span className="conversation-title">{c.title}</span>
                    )}
                  </div>

                  {!isEditing && (
                    <div className="conversation-actions">
                      <button
                        className="conversation-action-btn"
                        title="Rename"
                        onClick={(e) => startRename(c, e)}
                      >
                        <Edit2 size={13} />
                      </button>
                      <button
                        className="conversation-action-btn delete"
                        title="Delete"
                        onClick={(e) => {
                          e.stopPropagation();
                          onDeleteConversation(c.id);
                        }}
                      >
                        <Trash2 size={13} />
                      </button>
                    </div>
                  )}
                </div>
              );
            })
          )}
        </div>

        <div className="sidebar-footer">
          <div className="user-profile">
            <div className="user-avatar">M</div>
            <div className="user-info">
              <span className="user-name">MSAI User</span>
              <span className="user-plan">Free Plan</span>
            </div>
          </div>
          <button
            className="icon-button"
            title="Settings"
            onClick={onOpenSettings}
          >
            <Sliders size={18} />
          </button>
        </div>
      </aside>
    </>
  );
};
