export type Role = 'user' | 'assistant' | 'system';

export interface Attachment {
  id: string;
  name: string;
  type: string;
  mimeType: string;
  size: number;
  data?: string; // Base64 encoded string if applicable
}

export interface Message {
  id: string;
  role: Role;
  content: string;
  createdAt: string;
  updatedAt?: string;
  isStreaming?: boolean;
  error?: string;
  attachments?: Attachment[];
}

export interface Conversation {
  id: string;
  title: string;
  messages: Message[];
  model: string;
  createdAt: string;
  updatedAt: string;
}

export interface ModelOption {
  id: string;
  name: string;
  description: string;
  badge?: string;
  provider: string;
}

export interface Settings {
  theme: 'dark' | 'light' | 'system';
  language: string;
  enterToSend: boolean;
  clearHistoryOnExit: boolean;
  model: string;
  temperature: number;
  systemPrompt: string;
}

export interface ApiError {
  type:
    | 'INVALID_API_KEY'
    | 'MISSING_API_KEY'
    | 'NETWORK_ERROR'
    | 'QUOTA_EXCEEDED'
    | 'RATE_LIMIT'
    | 'SERVER_ERROR'
    | 'EMPTY_RESPONSE'
    | 'REQUEST_TIMEOUT'
    | 'ABORTED'
    | 'INVALID_REQUEST';
  message: string;
}
