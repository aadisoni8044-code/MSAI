import React, { useState, useEffect, useRef } from 'react';
import { Sidebar } from './components/Sidebar';
import { Header } from './components/Header';
import { ChatWindow } from './components/ChatWindow';
import { MessageInput } from './components/MessageInput';
import { SettingsModal } from './components/Settings';
import {
  Conversation,
  Message,
  Settings,
  Attachment,
  ApiError
} from './types/chat';
import { storageService } from './services/storageService';
import { googleApi } from './api/googleApi';
import {
  createNewConversation,
  createUserMessage,
  createAssistantMessage,
  generateTitleFromContent
} from './services/chatService';

export const App: React.FC = () => {
  const [conversations, setConversations] = useState<Conversation[]>(() =>
    storageService.loadConversations()
  );
  const [activeConversationId, setActiveConversationId] = useState<string | null>(
    () => storageService.loadActiveConversationId()
  );
  const [settings, setSettings] = useState<Settings>(() =>
    storageService.loadSettings()
  );
  const [sidebarCollapsed, setSidebarCollapsed] = useState<boolean>(() =>
    storageService.loadSidebarCollapsed()
  );
  const [mobileOpen, setMobileOpen] = useState<boolean>(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState<boolean>(false);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [serverStatus, setServerStatus] = useState<{ status: string; hasApiKey: boolean }>({
    status: 'checking',
    hasApiKey: false,
  });

  const abortControllerRef = useRef<AbortController | null>(null);

  // Check backend server status on mount
  useEffect(() => {
    async function checkServer() {
      const res = await googleApi.checkHealth();
      setServerStatus(res);
    }
    checkServer();
    const interval = setInterval(checkServer, 15000);
    return () => clearInterval(interval);
  }, []);

  // Save conversations on change
  useEffect(() => {
    storageService.saveConversations(conversations);
  }, [conversations]);

  // Save active id on change
  useEffect(() => {
    storageService.saveActiveConversationId(activeConversationId);
  }, [activeConversationId]);

  // Save sidebar state
  useEffect(() => {
    storageService.saveSidebarCollapsed(sidebarCollapsed);
  }, [sidebarCollapsed]);

  // Get active conversation
  const activeConversation =
    conversations.find((c) => c.id === activeConversationId) || null;

  // Handler: Create new chat
  const handleNewChat = () => {
    const newConv = createNewConversation(settings.model);
    setConversations((prev) => [newConv, ...prev]);
    setActiveConversationId(newConv.id);
  };

  // Handler: Select conversation
  const handleSelectConversation = (id: string) => {
    setActiveConversationId(id);
  };

  // Handler: Delete conversation
  const handleDeleteConversation = (id: string) => {
    setConversations((prev) => prev.filter((c) => c.id !== id));
    if (activeConversationId === id) {
      const remaining = conversations.filter((c) => c.id !== id);
      setActiveConversationId(remaining.length > 0 ? remaining[0].id : null);
    }
  };

  // Handler: Rename conversation
  const handleRenameConversation = (id: string, newTitle: string) => {
    setConversations((prev) =>
      prev.map((c) => (c.id === id ? { ...c, title: newTitle } : c))
    );
  };

  // Handler: Select model
  const handleSelectModel = (modelId: string) => {
    const updatedSettings = { ...settings, model: modelId };
    setSettings(updatedSettings);
    storageService.saveSettings(updatedSettings);

    if (activeConversationId) {
      setConversations((prev) =>
        prev.map((c) =>
          c.id === activeConversationId ? { ...c, model: modelId } : c
        )
      );
    }
  };

  // Handler: Save settings
  const handleSaveSettings = (newSettings: Settings) => {
    setSettings(newSettings);
    storageService.saveSettings(newSettings);
  };

  // Handler: Clear all conversations
  const handleClearAllConversations = () => {
    setConversations([]);
    setActiveConversationId(null);
    storageService.clearAllData();
  };

  // Handler: Stop current generation
  const handleStopGeneration = () => {
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
      abortControllerRef.current = null;
    }
    setIsLoading(false);
  };

  // Handler: Send Message
  const handleSendMessage = async (
    text: string,
    attachments: Attachment[] = []
  ) => {
    let targetConvId = activeConversationId;
    let currentConv = conversations.find((c) => c.id === targetConvId);

    // If no active conversation, create one
    if (!currentConv) {
      const newConv = createNewConversation(settings.model);
      targetConvId = newConv.id;
      currentConv = newConv;
      setConversations((prev) => [newConv, ...prev]);
      setActiveConversationId(newConv.id);
    }

    const userMsg = createUserMessage(text, attachments);
    const assistantMsg = createAssistantMessage('', true);

    // Update title if first message
    const isFirstMessage = currentConv.messages.length === 0;
    const newTitle = isFirstMessage
      ? generateTitleFromContent(text)
      : currentConv.title;

    const updatedMessages = [...currentConv.messages, userMsg, assistantMsg];

    setConversations((prev) =>
      prev.map((c) =>
        c.id === targetConvId
          ? {
              ...c,
              title: newTitle,
              messages: updatedMessages,
              updatedAt: new Date().toISOString(),
            }
          : c
      )
    );

    setIsLoading(true);

    const abortController = new AbortController();
    abortControllerRef.current = abortController;

    let accumulatedText = '';

    await googleApi.streamChatResponse(
      [...currentConv.messages, userMsg],
      currentConv.model || settings.model,
      settings.systemPrompt,
      {
        onChunk: (chunk) => {
          accumulatedText += chunk;
          setConversations((prev) =>
            prev.map((c) => {
              if (c.id !== targetConvId) return c;
              const msgs = c.messages.map((m) =>
                m.id === assistantMsg.id
                  ? { ...m, content: accumulatedText, isStreaming: true }
                  : m
              );
              return { ...c, messages: msgs };
            })
          );
        },
        onError: (err: ApiError) => {
          setConversations((prev) =>
            prev.map((c) => {
              if (c.id !== targetConvId) return c;
              const msgs = c.messages.map((m) =>
                m.id === assistantMsg.id
                  ? {
                      ...m,
                      isStreaming: false,
                      error: err.message,
                      content: accumulatedText || 'Could not generate a response.',
                    }
                  : m
              );
              return { ...c, messages: msgs };
            })
          );
          setIsLoading(false);
        },
        onFinish: () => {
          setConversations((prev) =>
            prev.map((c) => {
              if (c.id !== targetConvId) return c;
              const msgs = c.messages.map((m) =>
                m.id === assistantMsg.id ? { ...m, isStreaming: false } : m
              );
              return { ...c, messages: msgs };
            })
          );
          setIsLoading(false);
        },
      },
      abortController.signal
    );
  };

  // Handler: Edit Message & Resubmit
  const handleEditMessage = (messageId: string, newContent: string) => {
    if (!activeConversation) return;

    const msgIndex = activeConversation.messages.findIndex(
      (m) => m.id === messageId
    );
    if (msgIndex === -1) return;

    // Truncate message history up to edited user message
    const trimmedMessages = activeConversation.messages.slice(0, msgIndex);
    const updatedUserMsg: Message = {
      ...activeConversation.messages[msgIndex],
      content: newContent,
      updatedAt: new Date().toISOString(),
    };

    setConversations((prev) =>
      prev.map((c) =>
        c.id === activeConversation.id
          ? { ...c, messages: [...trimmedMessages, updatedUserMsg] }
          : c
      )
    );

    // Trigger AI response generation for edited prompt
    handleSendMessage(newContent);
  };

  // Handler: Delete single message
  const handleDeleteMessage = (messageId: string) => {
    if (!activeConversation) return;
    setConversations((prev) =>
      prev.map((c) =>
        c.id === activeConversation.id
          ? {
              ...c,
              messages: c.messages.filter((m) => m.id !== messageId),
            }
          : c
      )
    );
  };

  // Handler: Regenerate last AI response
  const handleRegenerateResponse = () => {
    if (!activeConversation || activeConversation.messages.length === 0) return;
    const lastUserMsg = [...activeConversation.messages]
      .reverse()
      .find((m) => m.role === 'user');

    if (lastUserMsg) {
      handleSendMessage(lastUserMsg.content, lastUserMsg.attachments);
    }
  };

  // Handler: Copy text helper
  const handleCopyText = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  return (
    <div className="app-container">
      <Sidebar
        conversations={conversations}
        activeConversationId={activeConversationId}
        collapsed={sidebarCollapsed}
        mobileOpen={mobileOpen}
        onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
        onCloseMobile={() => setMobileOpen(false)}
        onNewChat={handleNewChat}
        onSelectConversation={handleSelectConversation}
        onDeleteConversation={handleDeleteConversation}
        onRenameConversation={handleRenameConversation}
        onOpenSettings={() => setIsSettingsOpen(true)}
      />

      <main className="main-chat-container">
        <Header
          selectedModel={settings.model}
          onSelectModel={handleSelectModel}
          serverStatus={serverStatus}
          sidebarCollapsed={sidebarCollapsed}
          onToggleSidebar={() => setSidebarCollapsed(!sidebarCollapsed)}
          onOpenMobileSidebar={() => setMobileOpen(true)}
          onOpenSettings={() => setIsSettingsOpen(true)}
        />

        <ChatWindow
          conversation={activeConversation}
          isLoading={isLoading}
          onSendSuggestion={(prompt) => handleSendMessage(prompt)}
          onCopyText={handleCopyText}
          onEditMessage={handleEditMessage}
          onDeleteMessage={handleDeleteMessage}
          onRegenerateResponse={handleRegenerateResponse}
        />

        <MessageInput
          onSendMessage={handleSendMessage}
          onStopGeneration={handleStopGeneration}
          isLoading={isLoading}
          enterToSend={settings.enterToSend}
        />
      </main>

      {isSettingsOpen && (
        <SettingsModal
          settings={settings}
          onSaveSettings={handleSaveSettings}
          onClearAllConversations={handleClearAllConversations}
          onClose={() => setIsSettingsOpen(false)}
        />
      )}
    </div>
  );
};
