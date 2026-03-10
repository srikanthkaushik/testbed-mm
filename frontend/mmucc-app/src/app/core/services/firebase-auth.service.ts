import { Injectable } from '@angular/core';
import { initializeApp, getApps, FirebaseApp } from 'firebase/app';
import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  signInWithEmailAndPassword,
  signOut,
  Auth,
  UserCredential,
} from 'firebase/auth';
import { environment } from '../../../environments/environment';

/**
 * Wraps the Firebase JS SDK (v10 modular API).
 * Responsible only for obtaining Firebase ID tokens — not for session
 * management, which is handled by AuthService + the backend JWT.
 */
@Injectable({ providedIn: 'root' })
export class FirebaseAuthService {
  private readonly app: FirebaseApp;
  private readonly auth: Auth;

  constructor() {
    // Guard against double-initialisation (e.g. HMR reloads)
    this.app = getApps().length
      ? getApps()[0]
      : initializeApp(environment.firebase);
    this.auth = getAuth(this.app);
  }

  /** Open Google Sign-In popup and return the Firebase ID token. */
  async signInWithGoogle(): Promise<string> {
    const provider = new GoogleAuthProvider();
    provider.setCustomParameters({ prompt: 'select_account' });
    const credential: UserCredential = await signInWithPopup(this.auth, provider);
    return credential.user.getIdToken();
  }

  /** Sign in with email + password and return the Firebase ID token. */
  async signInWithEmailAndPassword(email: string, password: string): Promise<string> {
    const credential: UserCredential = await signInWithEmailAndPassword(
      this.auth,
      email,
      password,
    );
    return credential.user.getIdToken();
  }

  /** Sign out of Firebase (clears local Firebase session). */
  async signOut(): Promise<void> {
    await signOut(this.auth);
  }
}
