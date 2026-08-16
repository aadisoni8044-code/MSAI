import { collection, doc, setDoc, getDocs, getDoc, query, orderBy, deleteDoc, serverTimestamp } from 'firebase/firestore';
import { db, isConfigured } from './firebase-config';
import { ChatMessage } from './api';

export interface ChatSession {
  id: string;
  userId: string;
  title: string;
  createdAt: number;
  updatedAt: number;
  messages: ChatMessage[];
}

const LOCAL_STORAGE_CHATS_KEY = 'ms_ai_local_chats';

export class ChatService {
  private chats: ChatSession[] = [];
  private activeChatId: string | null = null;

  public async loadUserChats(userId: string): Promise<ChatSession[]> {
    if (isConfigured && userId) {
      try {
        const chatsRef = collection(db, 'users', userId, 'chats');
        const q = query(chatsRef, orderBy('updatedAt', 'desc'));
        const querySnapshot = await getDocs(q);

        const loadedChats: ChatSession[] = [];
        querySnapshot.forEach((docSnap) => {
          const data = docSnap.data();
          loadedChats.push({
            id: docSnap.id,
            userId: data.userId || userId,
            title: data.title || 'New Chat',
            createdAt: data.createdAt?.toMillis ? data.createdAt.toMillis() : (data.createdAt || Date.now()),
            updatedAt: data.updatedAt?.toMillis ? data.updatedAt.toMillis() : (data.updatedAt || Date.now()),
            messages: data.messages || []
          });
        });
        this.chats = loadedChats;
        return loadedChats;
      } catch (err) {
        console.warn('Failed to load chats from Firestore, using local storage fallback:', err);
      }
    }

    // Local storage fallback
    const raw = localStorage.getItem(`${LOCAL_STORAGE_CHATS_KEY}_${userId}`);
    if (raw) {
      try {
        this.chats = JSON.parse(raw);
      } catch {
        this.chats = [];
      }
    } else {
      this.chats = [];
    }
    return this.chats;
  }

  public getChats(): ChatSession[] {
    return this.chats;
  }

  public getActiveChat(): ChatSession | null {
    if (!this.activeChatId) return null;
    return this.chats.find(c => c.id === this.activeChatId) || null;
  }

  public setActiveChatId(id: string | null) {
    this.activeChatId = id;
  }

  public createNewChat(userId: string, initialTitle: string = 'New Chat'): ChatSession {
    const newSession: ChatSession = {
      id: 'chat_' + Date.now() + '_' + Math.random().toString(36).substr(2, 5),
      userId,
      title: initialTitle,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      messages: []
    };

    this.chats.unshift(newSession);
    this.activeChatId = newSession.id;
    this.saveChat(userId, newSession);
    return newSession;
  }

  public async saveChat(userId: string, session: ChatSession): Promise<void> {
    session.updatedAt = Date.now();

    if (isConfigured && userId) {
      try {
        const chatDocRef = doc(db, 'users', userId, 'chats', session.id);
        await setDoc(chatDocRef, {
          id: session.id,
          userId: session.userId,
          title: session.title,
          createdAt: session.createdAt,
          updatedAt: serverTimestamp(),
          messages: session.messages
        }, { merge: true });
      } catch (err) {
        console.warn('Failed to save chat to Firestore:', err);
      }
    }

    // Always keep local storage updated
    localStorage.setItem(`${LOCAL_STORAGE_CHATS_KEY}_${userId}`, JSON.stringify(this.chats));
  }

  public async deleteChat(userId: string, chatId: string): Promise<void> {
    this.chats = this.chats.filter(c => c.id !== chatId);
    if (this.activeChatId === chatId) {
      this.activeChatId = this.chats.length > 0 ? this.chats[0].id : null;
    }

    if (isConfigured && userId) {
      try {
        const chatDocRef = doc(db, 'users', userId, 'chats', chatId);
        await deleteDoc(chatDocRef);
      } catch (err) {
        console.warn('Failed to delete chat from Firestore:', err);
      }
    }

    localStorage.setItem(`${LOCAL_STORAGE_CHATS_KEY}_${userId}`, JSON.stringify(this.chats));
  }
}

export const chatService = new ChatService();
