import React, { useState, useEffect, useRef } from 'react';
import { marked } from 'marked';
import hljs from 'highlight.js';
import 'highlight.js/styles/tokyo-night-dark.css';
import {
  Copy,
  Check,
  Edit2,
  Trash2,
  RotateCw,
  User,
  AlertTriangle,
  Paperclip
} from 'lucide-react';
import { Message } from '../types/chat';

interface MessageProps {
  message: Message;
  onCopy: (text: string) => void;
  onEdit?: (messageId: string, newContent: string) => void;
  onDelete: (messageId: string) => void;
  onRegenerate?: () => void;
  isLastAssistantMessage?: boolean;
}

export const MessageItem: React.FC<MessageProps> = ({
  message,
  onCopy,
  onEdit,
  onDelete,
  onRegenerate,
  isLastAssistantMessage,
}) => {
  const [copied, setCopied] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editContent, setEditContent] = useState(message.content);
  const bodyRef = useRef<HTMLDivElement>(null);

  const isUser = message.role === 'user';

  const handleCopyText = () => {
    onCopy(message.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleSaveEdit = () => {
    if (onEdit && editContent.trim()) {
      onEdit(message.id, editContent.trim());
    }
    setIsEditing(false);
  };

  // Configure marked with highlight.js syntax highlighting
  useEffect(() => {
    if (!bodyRef.current || isUser) return;

    // Parse markdown into sanitized HTML
    const rawHtml = marked.parse(message.content || '') as string;
    bodyRef.current.innerHTML = rawHtml;

    // Highlight code blocks and inject copy button headers
    const codeBlocks = bodyRef.current.querySelectorAll('pre code');
    codeBlocks.forEach((block) => {
      hljs.highlightElement(block as HTMLElement);

      const pre = block.parentElement;
      if (pre && !pre.classList.contains('hljs-wrapped')) {
        pre.classList.add('hljs-wrapped');

        // Extract language
        const langMatch = block.className.match(/language-(\w+)/);
        const language = langMatch ? langMatch[1] : 'code';

        // Wrap pre into container with header
        const wrapper = document.createElement('div');
        wrapper.className = 'code-block-wrapper';

        const header = document.createElement('div');
        header.className = 'code-block-header';

        const langSpan = document.createElement('span');
        langSpan.textContent = language;

        const copyBtn = document.createElement('button');
        copyBtn.className = 'code-copy-btn';
        copyBtn.innerHTML = `<span>Copy code</span>`;
        copyBtn.onclick = () => {
          const codeText = (block as HTMLElement).innerText;
          navigator.clipboard.writeText(codeText);
          copyBtn.innerHTML = `<span>Copied!</span>`;
          setTimeout(() => {
            copyBtn.innerHTML = `<span>Copy code</span>`;
          }, 2000);
        };

        header.appendChild(langSpan);
        header.appendChild(copyBtn);

        pre.parentNode?.insertBefore(wrapper, pre);
        wrapper.appendChild(header);
        wrapper.appendChild(pre);
      }
    });
  }, [message.content, isUser]);

  return (
    <div className={`message-wrapper ${message.role}`}>
      <div className="message-avatar">
        {isUser ? <User size={18} /> : 'M'}
      </div>

      <div className="message-content-box">
        <div className="message-header-row">
          <span className="message-author">
            {isUser ? 'You' : 'MSAI'}
          </span>
          <span className="message-timestamp">
            {new Date(message.createdAt).toLocaleTimeString([], {
              hour: '2-digit',
              minute: '2-digit',
            })}
          </span>
        </div>

        {/* Attachments preview if present */}
        {message.attachments && message.attachments.length > 0 && (
          <div className="message-attachments">
            {message.attachments.map((att) => (
              <div key={att.id}>
                {att.mimeType.startsWith('image/') && att.data ? (
                  <img
                    src={att.data}
                    alt={att.name}
                    className="attachment-preview-img"
                  />
                ) : (
                  <div className="attachment-chip">
                    <Paperclip size={14} />
                    <span>{att.name}</span>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* Editing mode or content rendering */}
        {isEditing ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <textarea
              value={editContent}
              onChange={(e) => setEditContent(e.target.value)}
              style={{
                width: '100%',
                background: 'var(--bg-input)',
                border: '1px solid var(--accent-color)',
                borderRadius: '8px',
                padding: '10px',
                color: 'var(--text-primary)',
                fontFamily: 'var(--font-sans)',
                fontSize: '0.92rem',
                minHeight: '80px',
              }}
            />
            <div style={{ display: 'flex', gap: 8 }}>
              <button
                className="mode-pill active"
                onClick={handleSaveEdit}
                style={{ background: 'var(--accent-color)', color: '#fff' }}
              >
                Save & Submit
              </button>
              <button
                className="mode-pill"
                onClick={() => setIsEditing(false)}
              >
                Cancel
              </button>
            </div>
          </div>
        ) : isUser ? (
          <div className="message-body">{message.content}</div>
        ) : (
          <div className="message-body" ref={bodyRef}>
            {/* Rendered by marked in useEffect */}
          </div>
        )}

        {/* Error notification display */}
        {message.error && (
          <div className="error-alert-box">
            <AlertTriangle size={18} />
            <span>{message.error}</span>
          </div>
        )}

        {/* Message Actions */}
        {!isEditing && (
          <div className="message-actions-bar">
            <button
              className="action-icon-btn"
              title="Copy message"
              onClick={handleCopyText}
            >
              {copied ? <Check size={14} color="#10b981" /> : <Copy size={14} />}
            </button>

            {isUser && onEdit && (
              <button
                className="action-icon-btn"
                title="Edit message"
                onClick={() => setIsEditing(true)}
              >
                <Edit2 size={14} />
              </button>
            )}

            {!isUser && isLastAssistantMessage && onRegenerate && (
              <button
                className="action-icon-btn"
                title="Regenerate response"
                onClick={onRegenerate}
              >
                <RotateCw size={14} />
              </button>
            )}

            <button
              className="action-icon-btn"
              title="Delete message"
              onClick={() => onDelete(message.id)}
            >
              <Trash2 size={14} />
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
