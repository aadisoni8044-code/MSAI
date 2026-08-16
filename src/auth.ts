import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signInWithPopup,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  User
} from 'firebase/auth';
import { doc, setDoc, getDoc, serverTimestamp } from 'firebase/firestore';
import { auth, googleProvider, appleProvider, db, isConfigured } from './firebase-config';

export interface UserProfile {
  uid: string;
  email: string | null;
  displayName: string | null;
  photoURL: string | null;
  createdAt?: any;
}

const LOCAL_STORAGE_USER_KEY = 'ms_ai_mock_user';

export class AuthService {
  private currentUser: UserProfile | null = null;
  private authListeners: ((user: UserProfile | null) => void)[] = [];

  constructor() {
    if (isConfigured) {
      onAuthStateChanged(auth, async (firebaseUser) => {
        if (firebaseUser) {
          const profile = await this.syncUserProfile(firebaseUser);
          this.currentUser = profile;
        } else {
          this.currentUser = null;
        }
        this.notifyListeners();
      });
    } else {
      // Offline / Local Demo mode fallback
      const savedUser = localStorage.getItem(LOCAL_STORAGE_USER_KEY);
      if (savedUser) {
        try {
          this.currentUser = JSON.parse(savedUser);
        } catch {
          this.currentUser = null;
        }
      }
    }
  }

  public getCurrentUser(): UserProfile | null {
    return this.currentUser;
  }

  public onAuthStateChanged(callback: (user: UserProfile | null) => void) {
    this.authListeners.push(callback);
    // Initial call
    callback(this.currentUser);
    return () => {
      this.authListeners = this.authListeners.filter(cb => cb !== callback);
    };
  }

  private notifyListeners() {
    this.authListeners.forEach(cb => cb(this.currentUser));
  }

  private async syncUserProfile(firebaseUser: User): Promise<UserProfile> {
    const userRef = doc(db, 'users', firebaseUser.uid);
    const snap = await getDoc(userRef);

    const profile: UserProfile = {
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName || firebaseUser.email?.split('@')[0] || 'User',
      photoURL: firebaseUser.photoURL,
    };

    if (!snap.exists()) {
      await setDoc(userRef, {
        ...profile,
        createdAt: serverTimestamp()
      });
    }

    return profile;
  }

  public async signUpWithEmail(email: string, pass: string): Promise<UserProfile> {
    if (!email || !pass) throw new Error('Email and password are required');
    if (pass.length < 6) throw new Error('Password must be at least 6 characters');

    if (isConfigured) {
      const cred = await createUserWithEmailAndPassword(auth, email, pass);
      return await this.syncUserProfile(cred.user);
    } else {
      // Mock account creation
      const mockUser: UserProfile = {
        uid: 'user_' + Math.random().toString(36).substr(2, 9),
        email,
        displayName: email.split('@')[0],
        photoURL: null,
      };
      this.currentUser = mockUser;
      localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(mockUser));
      this.notifyListeners();
      return mockUser;
    }
  }

  public async signInWithEmail(email: string, pass: string): Promise<UserProfile> {
    if (!email || !pass) throw new Error('Email and password are required');

    if (isConfigured) {
      const cred = await signInWithEmailAndPassword(auth, email, pass);
      return await this.syncUserProfile(cred.user);
    } else {
      // Mock sign in
      const mockUser: UserProfile = {
        uid: 'user_demo_123',
        email,
        displayName: email.split('@')[0],
        photoURL: null,
      };
      this.currentUser = mockUser;
      localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(mockUser));
      this.notifyListeners();
      return mockUser;
    }
  }

  public async signInWithGoogle(): Promise<UserProfile> {
    if (isConfigured) {
      const cred = await signInWithPopup(auth, googleProvider);
      return await this.syncUserProfile(cred.user);
    } else {
      const mockUser: UserProfile = {
        uid: 'google_user_456',
        email: 'alex.google@example.com',
        displayName: 'Alex Google',
        photoURL: null,
      };
      this.currentUser = mockUser;
      localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(mockUser));
      this.notifyListeners();
      return mockUser;
    }
  }

  public async signInWithApple(): Promise<UserProfile> {
    if (isConfigured) {
      const cred = await signInWithPopup(auth, appleProvider);
      return await this.syncUserProfile(cred.user);
    } else {
      const mockUser: UserProfile = {
        uid: 'apple_user_789',
        email: 'jordan.apple@example.com',
        displayName: 'Jordan Apple',
        photoURL: null,
      };
      this.currentUser = mockUser;
      localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(mockUser));
      this.notifyListeners();
      return mockUser;
    }
  }

  public async signOut(): Promise<void> {
    if (isConfigured) {
      await firebaseSignOut(auth);
    }
    this.currentUser = null;
    localStorage.removeItem(LOCAL_STORAGE_USER_KEY);
    this.notifyListeners();
  }
}

export const authService = new AuthService();
