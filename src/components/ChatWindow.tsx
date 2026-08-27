import React, { useRef, useEffect } from 'react';
import { MessageItem } from './Message';
import { LoadingMessage } from './LoadingMessage';
import { Conversation } from '../types/chat';
import config from '../data/config.json';

interface ChatWindowProps {
  conversation: Conversation | null;
  isLoading: boolean;
  onSendSuggestion: (prompt: string) => void;
  onCopyText: (text: string) => void;
  onEditMessage: (messageId: string, newContent: string) => void;
  onDeleteMessage: (messageId: string) => void;
  onRegenerateResponse: () => void;
}

export const ChatWindow: React.FC<ChatWindowProps> = ({
  conversation,
  isLoading,
  onSendSuggestion,
  onCopyText,
  onEditMessage,
  onDeleteMessage,
  onRegenerateResponse,
}) => {
  const bottomRef = useRef<HTMLDivElement>(null);

  const messages = conversation?.messages || [];

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  if (!conversation || messages.length === 0) {
    return (
      <div className="empty-chat-welcome">
        <h1 className="hero-title">MSAI</h1>
        <div className="chat-suggestions-grid">
          {config.promptSuggestions.map((item) => (
            <button
              key={item.id}
              className="suggestion-pill"
              onClick={() => onSendSuggestion(item.prompt)}
            >
              <span>{item.label}</span>
            </button>
          ))}
        </div>
      </div>
    );
  }

  const lastAssistantMessageIndex = [...messages]
    .reverse()
    .findIndex((m) => m.role === 'assistant');
  const actualLastAssistantIndex =
    lastAssistantMessageIndex !== -1
      ? messages.length - 1 - lastAssistantMessageIndex
      : -1;

  return (
    <div className="messages-area">
      {messages.map((msg, index) => (
        <MessageItem
          key={msg.id}
          message={msg}
          onCopy={onCopyText}
          onEdit={onEditMessage}
          onDelete={onDeleteMessage}
          onRegenerate={onRegenerateResponse}
          isLastAssistantMessage={index === actualLastAssistantIndex}
        />
      ))}

      {isLoading && <LoadingMessage />}

      <div ref={bottomRef} />
    </div>
  );
};
