// Firebase Configuration
// Replace with your project's Firebase configuration or configure via Settings UI
export interface FirebaseConfig {
  apiKey: string;
  authDomain: string;
  projectId: string;
  storageBucket: string;
  messagingSenderId: string;
  appId: string;
}

export const defaultFirebaseConfig: FirebaseConfig = {
  apiKey: "AIzaSyDemoKeyForMSAIApplication12345678",
  authDomain: "ms-ai-app.firebaseapp.com",
  projectId: "ms-ai-app",
  storageBucket: "ms-ai-app.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890"
};

export function getFirebaseConfig(): FirebaseConfig {
  const saved = localStorage.getItem('ms_ai_firebase_config');
  if (saved) {
    try {
      return JSON.parse(saved);
    } catch (e) {
      console.warn('Failed to parse saved Firebase config, using default:', e);
    }
  }
  return defaultFirebaseConfig;
}

export function saveFirebaseConfig(config: FirebaseConfig): void {
  localStorage.setItem('ms_ai_firebase_config', JSON.stringify(config));
}
