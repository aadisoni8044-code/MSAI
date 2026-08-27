import { Conversation, Message, Attachment } from '../types/chat';

export function createNewConversation(model: string = 'MSAI Flash'): Conversation {
  const id = 'chat_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6);
  return {
    id,
    title: 'New Conversation',
    messages: [],
    model,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}

export function createUserMessage(content: string, attachments: Attachment[] = []): Message {
  return {
    id: 'msg_u_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
    role: 'user',
    content,
    createdAt: new Date().toISOString(),
    attachments: attachments.length > 0 ? attachments : undefined,
  };
}

export function createAssistantMessage(content: string = '', isStreaming: boolean = true): Message {
  return {
    id: 'msg_a_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
    role: 'assistant',
    content,
    createdAt: new Date().toISOString(),
    isStreaming,
  };
}

export function generateTitleFromContent(content: string): string {
  if (!content || !content.trim()) return 'New Conversation';
  const clean = content.trim().replace(/[\r\n]+/g, ' ');
  if (clean.length <= 32) return clean;
  return clean.substring(0, 32) + '...';
}

export function filterConversations(conversations: Conversation[], query: string): Conversation[] {
  if (!query || !query.trim()) return conversations;
  const q = query.toLowerCase().trim();
  return conversations.filter((conv) => {
    if (conv.title.toLowerCase().includes(q)) return true;
    return conv.messages.some((msg) => msg.content.toLowerCase().includes(q));
  });
}
