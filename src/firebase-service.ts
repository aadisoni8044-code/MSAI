import { initializeApp, getApps, FirebaseApp } from "firebase/app";
import {
  getAuth,
  signInWithPopup,
  GoogleAuthProvider,
  signInAnonymously,
  signOut,
  onAuthStateChanged,
  User,
  Auth
} from "firebase/auth";
import {
  getFirestore,
  collection,
  doc,
  setDoc,
  getDocs,
  query,
  orderBy,
  deleteDoc,
  Firestore
} from "firebase/firestore";
import { getFirebaseConfig } from "./firebase-config";

export interface ChatMessage {
  id: string;
  role: 'user' | 'model' | 'system';
  content: string;
  timestamp: number;
  modeId?: string;
}

export interface ChatSession {
  id: string;
  title: string;
  modeId: string;
  createdAt: number;
  updatedAt: number;
  messages: ChatMessage[];
  userId?: string;
}

export interface UserProfile {
  uid: string;
  displayName: string | null;
  email: string | null;
  photoURL: string | null;
  isAnonymous: boolean;
}

class FirebaseService {
  private app: FirebaseApp | null = null;
  private auth: Auth | null = null;
  private db: Firestore | null = null;
  public currentUser: UserProfile | null = null;
  private isFirebaseInitialized: boolean = false;

  constructor() {
    this.initFirebase();
  }

  public initFirebase(): boolean {
    try {
      const config = getFirebaseConfig();
      if (!getApps().length) {
        this.app = initializeApp(config);
      } else {
        this.app = getApps()[0];
      }
      this.auth = getAuth(this.app);
      this.db = getFirestore(this.app);
      this.isFirebaseInitialized = true;
      return true;
    } catch (error) {
      console.warn("Firebase initialization failed or running in fallback mode:", error);
      this.isFirebaseInitialized = false;
      return false;
    }
  }

  public onAuthChange(callback: (user: UserProfile | null) => void) {
    if (this.auth) {
      return onAuthStateChanged(this.auth, (user: User | null) => {
        if (user) {
          this.currentUser = {
            uid: user.uid,
            displayName: user.displayName || (user.isAnonymous ? 'Guest User' : 'User'),
            email: user.email,
            photoURL: user.photoURL,
            isAnonymous: user.isAnonymous
          };
        } else {
          this.currentUser = null;
        }
        callback(this.currentUser);
      });
    } else {
      // Fallback guest user mode
      const guestUser: UserProfile = {
        uid: 'local_guest',
        displayName: 'Local Guest',
        email: null,
        photoURL: null,
        isAnonymous: true
      };
      this.currentUser = guestUser;
      callback(guestUser);
      return () => {};
    }
  }

  public async loginWithGoogle(): Promise<UserProfile> {
    if (!this.auth) throw new Error("Firebase Auth is not initialized.");
    const provider = new GoogleAuthProvider();
    const result = await signInWithPopup(this.auth, provider);
    const user = result.user;
    this.currentUser = {
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      isAnonymous: user.isAnonymous
    };
    return this.currentUser;
  }

  public async loginAnonymously(): Promise<UserProfile> {
    if (!this.auth) {
      const guestUser: UserProfile = {
        uid: 'local_guest',
        displayName: 'Local Guest',
        email: null,
        photoURL: null,
        isAnonymous: true
      };
      this.currentUser = guestUser;
      return guestUser;
    }
    const result = await signInAnonymously(this.auth);
    const user = result.user;
    this.currentUser = {
      uid: user.uid,
      displayName: 'Guest User',
      email: null,
      photoURL: null,
      isAnonymous: true
    };
    return this.currentUser;
  }

  public async logout(): Promise<void> {
    if (this.auth) {
      await signOut(this.auth);
    }
    this.currentUser = null;
  }

  // Database / Firestore operations with LocalStorage fallback

  public async saveChatSession(session: ChatSession): Promise<void> {
    const userId = this.currentUser?.uid || 'local_guest';
    session.userId = userId;

    // Local Storage backup/sync
    this.saveSessionToLocalStorage(session);

    if (this.db && userId !== 'local_guest') {
      try {
        const sessionRef = doc(this.db, 'users', userId, 'sessions', session.id);
        await setDoc(sessionRef, {
          id: session.id,
          title: session.title,
          modeId: session.modeId,
          createdAt: session.createdAt,
          updatedAt: session.updatedAt,
          messages: session.messages,
          userId: userId
        });
      } catch (err) {
        console.warn('Failed to save to Firestore, local storage active:', err);
      }
    }
  }

  public async loadUserSessions(): Promise<ChatSession[]> {
    const userId = this.currentUser?.uid || 'local_guest';

    if (this.db && userId !== 'local_guest') {
      try {
        const sessionsRef = collection(this.db, 'users', userId, 'sessions');
        const q = query(sessionsRef, orderBy('updatedAt', 'desc'));
        const querySnapshot = await getDocs(q);
        const sessions: ChatSession[] = [];
        querySnapshot.forEach((docSnap) => {
          sessions.push(docSnap.data() as ChatSession);
        });
        if (sessions.length > 0) {
          return sessions;
        }
      } catch (err) {
        console.warn('Failed to fetch sessions from Firestore, falling back to local storage:', err);
      }
    }

    return this.loadSessionsFromLocalStorage(userId);
  }

  public async deleteChatSession(sessionId: string): Promise<void> {
    const userId = this.currentUser?.uid || 'local_guest';

    this.deleteSessionFromLocalStorage(userId, sessionId);

    if (this.db && userId !== 'local_guest') {
      try {
        const sessionRef = doc(this.db, 'users', userId, 'sessions', sessionId);
        await deleteDoc(sessionRef);
      } catch (err) {
        console.warn('Failed to delete session from Firestore:', err);
      }
    }
  }

  // LocalStorage Helpers
  private getStorageKey(userId: string): string {
    return `ms_ai_sessions_${userId}`;
  }

  private saveSessionToLocalStorage(session: ChatSession): void {
    const userId = session.userId || 'local_guest';
    const key = this.getStorageKey(userId);
    const existing = this.loadSessionsFromLocalStorage(userId);
    const idx = existing.findIndex(s => s.id === session.id);
    if (idx >= 0) {
      existing[idx] = session;
    } else {
      existing.unshift(session);
    }
    localStorage.setItem(key, JSON.stringify(existing));
  }

  private loadSessionsFromLocalStorage(userId: string): ChatSession[] {
    const key = this.getStorageKey(userId);
    const data = localStorage.getItem(key);
    if (!data) return [];
    try {
      return JSON.parse(data);
    } catch {
      return [];
    }
  }

  private deleteSessionFromLocalStorage(userId: string, sessionId: string): void {
    const key = this.getStorageKey(userId);
    const existing = this.loadSessionsFromLocalStorage(userId);
    const filtered = existing.filter(s => s.id !== sessionId);
    localStorage.setItem(key, JSON.stringify(filtered));
  }
}

export const firebaseService = new FirebaseService();
