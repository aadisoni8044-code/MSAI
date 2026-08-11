// ============================================================================
// google.js - Google Authentication & Firestore Sync System for plo.io
// ============================================================================

import { initializeApp } from "firebase/app";
import { getAuth, signInWithPopup, GoogleAuthProvider, signOut, onAuthStateChanged, setPersistence, browserLocalPersistence } from "firebase/auth";
import { getFirestore, doc, getDoc, setDoc, updateDoc, collection, query, where, getDocs, runTransaction, onSnapshot } from "firebase/firestore";
import { getStorage, ref, uploadString, getDownloadURL } from "firebase/storage";
import { getDatabase, ref as rtdbRef, set, onValue, push, remove, get as rtdbGet } from "firebase/database";

// --- PLACEHOLDER CONFIGURATION ---
// Please paste your Firebase Project configuration here.
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

// Expose legacy-compatible firebase.auth().currentUser on the global window object
window.firebase = {
    auth: () => {
        return {
            get currentUser() {
                return auth.currentUser;
            }
        };
    }
};

// Enable Firebase Auth Persistence explicitly
setPersistence(auth, browserLocalPersistence)
    .then(() => {
        console.log("[Auth] Persistence enabled successfully using browserLocalPersistence.");
    })
    .catch((error) => {
        console.error("[Auth] Error setting persistence:", error);
    });

const db = getFirestore(app);
const storage = getStorage(app);
const rtdb = getDatabase(app);
const provider = new GoogleAuthProvider();

// Track currently logged-in user
let currentUser = null;
let activeUserDocListener = null;

// --- GOOGLE AUTHENTICATION HANDLERS ---

/**
 * Initiates the Google Sign-In popup flow.
 */
export async function loginWithGoogle() {
    try {
        console.log("[Auth] Initiating Google Sign-In popup...");
        const result = await signInWithPopup(auth, provider);
        const user = result.user;
        console.log(`[Auth] Google Sign-In successful for: ${user.displayName}`);
    } catch (error) {
        console.error("[Auth] Error during Google Sign-In:", error);
        alert(`Sign-in failed: ${error.message}`);
    }
}

/**
 * Signs out the currently authenticated user.
 */
export async function logoutUser() {
    try {
        console.log("[Auth] Initiating sign-out...");
        await signOut(auth);
        console.log("[Auth] Sign-out successful.");
    } catch (error) {
        console.error("[Auth] Error during sign-out:", error);
    }
}

// Attach Auth State Listener to maintain user login session across refreshes
onAuthStateChanged(auth, async (user) => {
    const loggedOutSection = document.getElementById("google-logged-out");
    const loggedInSection = document.getElementById("google-logged-in");
    const userPhoto = document.getElementById("google-user-photo");
    const userName = document.getElementById("google-user-name");
    const userEmail = document.getElementById("google-user-email");

    window.isLoggedIn = !!user;
    window.firebaseUser = user;

    if (user) {
        currentUser = user;
        console.log(`[Auth] User authenticated: ${user.email} (${user.uid})`);

        // Close auth modal if active on successful sign-in
        const authModal = document.getElementById("auth-modal");
        if (authModal) authModal.classList.remove("active");

        // Fetch user data from Firestore or initialize if new
        await getOrCreateUserDoc(user);

        // Unsubscribe from any previous listener
        if (activeUserDocListener) {
            activeUserDocListener();
            activeUserDocListener = null;
        }

        // Setup real-time listener on the Firestore users/{userId} doc
        activeUserDocListener = onSnapshot(doc(db, "users", user.uid), (docSnap) => {
            if (docSnap.exists()) {
                const userDoc = docSnap.data();
                console.log("[Firestore] Real-time user doc update received:", userDoc);

                // Update local game state with fetched database stats
                updateLocalGameState(userDoc, user);

                // Toggle UI widgets to Logged In state
                if (loggedOutSection) loggedOutSection.style.display = "none";
                if (loggedInSection) loggedInSection.style.display = "flex";

                const finalPhotoURL = userDoc.photoURL || user.photoURL;
                window.UI_STATE.photoURL = finalPhotoURL;

                if (userPhoto) userPhoto.src = finalPhotoURL || "https://placehold.co/32";
                if (userName) userName.innerText = userDoc.displayName || user.displayName || "Google User";
                if (userEmail) userEmail.innerText = userDoc.email || user.email || "";

                // Update mini and large profile avatars with actual profile picture
                updateUIAvatars(finalPhotoURL);
            }
        }, (error) => {
            console.error("[Firestore] Snapshot listener error:", error);
        });

    } else {
        currentUser = null;
        console.log("[Auth] User logged out.");

        // Unsubscribe from active user doc snapshot listener
        if (activeUserDocListener) {
            activeUserDocListener();
            activeUserDocListener = null;
        }

        // Toggle UI widgets to Logged Out state
        if (loggedOutSection) loggedOutSection.style.display = "block";
        if (loggedInSection) loggedInSection.style.display = "none";

        // Reset in-memory values to defaults (0 coins, default map)
        if (window.UI_STATE) {
            window.UI_STATE.ploCoins = 0;
            window.UI_STATE.eloRating = 1000;
            window.UI_STATE.streakDays = 0;
            window.UI_STATE.username = "Rider_01";
            window.UI_STATE.uid = "--------";
            window.UI_STATE.bio = "";
            window.UI_STATE.youtube = "";
            window.UI_STATE.instagram = "";
            window.UI_STATE.twitter = "";
            window.UI_STATE.twitch = "";
            window.UI_STATE.followersCount = 0;
            window.UI_STATE.followingCount = 0;
            window.UI_STATE.unlockedLevels = { 1: 0 };
            window.UI_STATE.equippedSkin = "classic";
            window.UI_STATE.ownedSkins = ["classic"];
            window.UI_STATE.totalCrashes = 0;
            window.UI_STATE.totalPerfectRuns = 0;
            window.UI_STATE.highScore = 0;
            window.UI_STATE.raceWins = 0;
            window.UI_STATE.photoURL = null;
        }

        // Close profile screen if user logged out
        const profileScreen = document.getElementById("profile-screen");
        if (profileScreen) profileScreen.classList.add("hidden");

        // Reset avatars to default emoji 👤
        updateUIAvatars(null);

        // Immediately repaint all widgets to defaults
        if (typeof window.renderHeaderWidgets === "function") {
            window.renderHeaderWidgets();
        }
        if (typeof window.renderProfileDetails === "function") {
            window.renderProfileDetails();
        }
        if (typeof window.renderLevelSelector === "function") {
            window.renderLevelSelector();
        }
        if (typeof window.renderShopSkins === "function") {
            window.renderShopSkins();
        }
    }

    // Refresh restricted/unrestricted UI elements based on current auth state
    if (typeof updateAuthUI === "function") {
        updateAuthUI();
    }
});

/**
 * Updates the visibility and enabled states of restricted features
 * depending on whether a user is currently logged in.
 */
export function updateAuthUI() {
    // Always check firebase.auth().currentUser
    const user = window.firebase ? window.firebase.auth().currentUser : null;

    const shopBtn = document.getElementById("menu-shop-btn");
    const profileBtn = document.getElementById("menu-profile-btn");
    const searchBtn = document.getElementById("menu-search-btn");
    const leaderboardBtn = document.getElementById("menu-leaderboard-btn");
    const loginIndicator = document.getElementById("login-save-progress-indicator");

    if (!user) {
        // Guest user: Hide or Disable features
        if (shopBtn) {
            shopBtn.classList.add("restricted-feature");
        }
        if (profileBtn) {
            profileBtn.classList.add("restricted-feature");
        }
        if (searchBtn) {
            searchBtn.classList.add("restricted-feature");
        }
        if (leaderboardBtn) {
            leaderboardBtn.classList.add("restricted-feature");
        }
        if (loginIndicator) {
            loginIndicator.style.display = "flex";
        }
    } else {
        // Logged-in user: Enable all features
        if (shopBtn) {
            shopBtn.classList.remove("restricted-feature");
        }
        if (profileBtn) {
            profileBtn.classList.remove("restricted-feature");
        }
        if (searchBtn) {
            searchBtn.classList.remove("restricted-feature");
        }
        if (leaderboardBtn) {
            leaderboardBtn.classList.remove("restricted-feature");
        }
        if (loginIndicator) {
            loginIndicator.style.display = "none";
        }
    }
}
window.updateAuthUI = updateAuthUI;

// --- CLOUD DATABASE SYNC (FIRESTORE) ---

/**
 * Retrieves the user profile from the Firestore 'users' collection.
 * Creates a new document with +50 PLO Coins sign-up bonus if it doesn't exist.
 */
async function getOrCreateUserDoc(user) {
    const docRef = doc(db, "users", user.uid);
    try {
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            console.log("[Firestore] Found returning user profile:", docSnap.data());
            return docSnap.data();
        } else {
            console.log("[Firestore] No profile found. Initializing new user profile...");

            // Get current local coins if any, and add +50 sign-up bonus coins
            const currentLocalCoins = window.UI_STATE ? window.UI_STATE.ploCoins : 0;
            const initialCoins = currentLocalCoins + 50;

            // Generate a unique 8-digit random numeric player ID
            let isUnique = false;
            let finalUID = "";
            let safetyCheck = 0;
            while (!isUnique && safetyCheck < 10) {
                safetyCheck++;
                const candidate = Math.floor(10000000 + Math.random() * 90000000).toString();
                // Check if candidate UID exists in users collection
                const q = query(collection(db, "users"), where("uid", "==", candidate));
                const snap = await getDocs(q);
                if (snap.empty) {
                    finalUID = candidate;
                    isUnique = true;
                }
            }

            // Fallback unique fallback just in case
            if (!finalUID) {
                finalUID = Math.floor(10000000 + Math.random() * 90000000).toString();
            }

            const initialData = {
                displayName: user.displayName || "WaveRunner",
                email: user.email || "",
                photoURL: user.photoURL || "",
                plo_coins: initialCoins,
                high_score: 0,
                rating: 1000,
                active_days: 1,
                bio: "Riding the geometry waves!",
                youtube: "",
                instagram: "",
                twitter: "",
                twitch: "",
                followersCount: 0,
                followingCount: 0,
                uid: finalUID,
                unlockedLevels: { 1: 0 },
                equippedSkin: "classic",
                ownedSkins: ["classic"],
                totalCrashes: 0,
                totalPerfectRuns: 0,
                highScore: 0,
                raceWins: 0,
                createdAt: new Date().toISOString()
            };

            if (user) {
                await setDoc(docRef, initialData, { merge: true });
            }
            console.log("[Firestore] Successfully created new user record with +50 Coins signup bonus.");

            // Show alert/notification about the bonus coins
            alert("Welcome! You've received a +50 Speedy Coins signup bonus!");
            return initialData;
        }
    } catch (e) {
        console.error("[Firestore] Error fetching/creating user document:", e);
        return null;
    }
}

/**
 * Loads values fetched from Firestore directly into the running game state.
 */
function updateLocalGameState(cloudData, user) {
    if (!window.UI_STATE || !window.KEYS) return;

    console.log("[Game State] Merging cloud database stats into local state...");

    // 1. Update stats
    window.UI_STATE.ploCoins = cloudData.plo_coins || 0;
    window.UI_STATE.eloRating = cloudData.rating || 1000;
    window.UI_STATE.streakDays = cloudData.active_days || 1;
    window.UI_STATE.username = cloudData.displayName || user.displayName || "WaveRunner";
    window.UI_STATE.uid = cloudData.uid || "--------";

    // Custom Enhancements UI state sync
    window.UI_STATE.bio = cloudData.bio || "";
    window.UI_STATE.youtube = cloudData.youtube || "";
    window.UI_STATE.instagram = cloudData.instagram || "";
    window.UI_STATE.twitter = cloudData.twitter || "";
    window.UI_STATE.twitch = cloudData.twitch || "";
    window.UI_STATE.followersCount = cloudData.followersCount || 0;
    window.UI_STATE.followingCount = cloudData.followingCount || 0;

    // Load additional fields strictly from Firestore
    window.UI_STATE.unlockedLevels = cloudData.unlockedLevels || { 1: 0 };
    window.UI_STATE.equippedSkin = cloudData.equippedSkin || "classic";
    window.UI_STATE.ownedSkins = cloudData.ownedSkins || ["classic"];
    window.UI_STATE.totalCrashes = cloudData.totalCrashes || 0;
    window.UI_STATE.totalPerfectRuns = cloudData.totalPerfectRuns || 0;
    window.UI_STATE.highScore = cloudData.highScore || 0;
    window.UI_STATE.raceWins = cloudData.raceWins || 0;

    if (cloudData.highScore) {
        if (typeof window.updateEngineMenuTags === "function") {
            window.updateEngineMenuTags();
        }
    }

    // 3. Trigger UI Repaint to update HUD and modals
    if (typeof window.renderHeaderWidgets === "function") {
        window.renderHeaderWidgets();
    }
    if (typeof window.renderProfileDetails === "function") {
        window.renderProfileDetails();
    }
    if (typeof window.renderLevelSelector === "function") {
        window.renderLevelSelector();
    }
    if (typeof window.renderShopSkins === "function") {
        window.renderShopSkins();
    }
}

/**
 * Updates UI profile picture element icons with user photoURL image.
 */
function updateUIAvatars(photoURL) {
    const avatarMini = document.querySelector(".profile-avatar");
    if (avatarMini) {
        if (photoURL) {
            avatarMini.innerHTML = `<img src="${photoURL}" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover;">`;
        } else {
            avatarMini.innerHTML = "👤";
        }
    }
    const avatarLarge = document.querySelector(".profile-avatar-large");
    if (avatarLarge) {
        if (photoURL) {
            avatarLarge.innerHTML = `<img src="${photoURL}" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover;">`;
        } else {
            avatarLarge.innerHTML = "👤";
        }
    }
}

/**
 * Real-time state syncing to cloud Firestore.
 */
export async function syncUIStateToCloud() {
    if (!currentUser) return;
    const userDocRef = doc(db, "users", currentUser.uid);
    try {
        const syncData = {
            plo_coins: window.UI_STATE.ploCoins || 0,
            rating: window.UI_STATE.eloRating || 1000,
            active_days: window.UI_STATE.streakDays || 1,
            displayName: window.UI_STATE.username || "WaveRunner",
            bio: window.UI_STATE.bio || "",
            youtube: window.UI_STATE.youtube || "",
            instagram: window.UI_STATE.instagram || "",
            twitter: window.UI_STATE.twitter || "",
            twitch: window.UI_STATE.twitch || "",
            followersCount: window.UI_STATE.followersCount || 0,
            followingCount: window.UI_STATE.followingCount || 0,
            unlockedLevels: window.UI_STATE.unlockedLevels || { 1: 0 },
            equippedSkin: window.UI_STATE.equippedSkin || "classic",
            ownedSkins: window.UI_STATE.ownedSkins || ["classic"],
            totalCrashes: window.UI_STATE.totalCrashes || 0,
            totalPerfectRuns: window.UI_STATE.totalPerfectRuns || 0,
            highScore: window.UI_STATE.highScore || 0,
            raceWins: window.UI_STATE.raceWins || 0
        };

        if (currentUser) {
            await setDoc(userDocRef, syncData, { merge: true });
        }
        console.log("[Cloud Sync] Synced entire UI_STATE to Firestore users collection.");
    } catch (err) {
        console.error("[Cloud Sync] Error syncing UI_STATE to Cloud:", err);
    }
}
window.syncUIStateToCloud = syncUIStateToCloud;

// --- ADDITIONAL MULTIPLAYER, REALTIME & SOCIAL APIS ---

/**
 * Compresses an image file client-side using Canvas and uploads it to Firebase Storage.
 */
export async function uploadProfilePicture(fileInput) {
    if (!currentUser) return;
    const file = fileInput.files[0];
    if (!file) return;

    try {
        console.log("[Storage] Starting custom profile picture processing and upload...");
        const dataUrl = await new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => resolve(e.target.result);
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });

        const img = new Image();
        img.src = dataUrl;
        await new Promise((resolve) => (img.onload = resolve));

        // Client-side visual compression down to max 128x128
        const maxDim = 128;
        let w = img.width;
        let h = img.height;
        if (w > maxDim || h > maxDim) {
            if (w > h) {
                h = (maxDim / w) * h;
                w = maxDim;
            } else {
                w = (maxDim / h) * w;
                h = maxDim;
            }
        }

        const cvs = document.createElement("canvas");
        cvs.width = w;
        cvs.height = h;
        const ctx = cvs.getContext("2d");
        ctx.drawImage(img, 0, 0, w, h);

        const compressedDataUrl = cvs.toDataURL("image/jpeg", 0.7);

        // Upload to Firebase Storage under a secure path (profile_images/{userId}/avatar.jpg)
        const storageRef = ref(storage, `profile_images/${currentUser.uid}/avatar.jpg`);
        await uploadString(storageRef, compressedDataUrl, "data_url");
        const downloadUrl = await getDownloadURL(storageRef);

        console.log("[Storage] PFP upload complete. Received direct URL:", downloadUrl);

        // Save this download URL to the user's Firestore document (users/{userId}/photoURL)
        const userDocRef = doc(db, "users", currentUser.uid);
        if (currentUser) {
            await setDoc(userDocRef, { photoURL: downloadUrl }, { merge: true });
        }

        // Update UI state and refresh UI avatars immediately without page reload
        window.UI_STATE.photoURL = downloadUrl;
        updateUIAvatars(downloadUrl);

        // Also update the google-user-photo element on the profile screen
        const userPhoto = document.getElementById("google-user-photo");
        if (userPhoto) {
            userPhoto.src = downloadUrl;
        }

        alert("Profile picture uploaded successfully!");
    } catch (error) {
        console.error("[Storage] Error during PFP upload:", error);
        alert(`Failed to upload avatar: ${error.message}`);
    }
}

/**
 * Updates user custom bio status section in Firestore.
 */
export async function updateProfileBio(newBio) {
    if (!currentUser) return;
    try {
        const userDocRef = doc(db, "users", currentUser.uid);
        if (currentUser) {
            await updateDoc(userDocRef, { bio: newBio });
        }
        window.UI_STATE.bio = newBio;
        console.log("[Firestore] Bio updated successfully.");
    } catch (e) {
        console.error("[Firestore] Error updating bio:", e);
    }
}

/**
 * Updates a specific social account link on the profile record.
 */
export async function updateSocialLink(network, url) {
    if (!currentUser) return;
    try {
        const userDocRef = doc(db, "users", currentUser.uid);
        const updateData = {};
        updateData[network] = url;
        if (currentUser) {
            await updateDoc(userDocRef, updateData);
        }
        window.UI_STATE[network] = url;
        console.log(`[Firestore] Social link for '${network}' updated.`);
    } catch (e) {
        console.error("[Firestore] Error updating social link:", e);
    }
}

/**
 * Queries database specifically for players by their unique 8-Digit UID.
 */
export async function searchPlayersByUID(searchQuery) {
    if (!searchQuery || searchQuery.trim() === "") return;
    const containers = [
        document.getElementById("social-search-results"),
        document.getElementById("settings-search-results")
    ].filter(el => el !== null);

    if (containers.length === 0) return;

    const setHTML = (html) => {
        containers.forEach(c => c.innerHTML = html);
    };

    setHTML(`<div style="text-align: center; color: var(--neon-cyan);">Querying Player ID...</div>`);

    try {
        const qByUID = query(
            collection(db, "users"),
            where("uid", "==", searchQuery.trim())
        );
        const snapshot = await getDocs(qByUID);
        let resultsHTML = "";

        const foundDocs = [];
        snapshot.forEach((doc) => {
            foundDocs.push({ id: doc.id, ...doc.data() });
        });

        if (foundDocs.length === 0) {
            setHTML(`<div style="text-align: center; color: var(--neon-pink); font-size: 14px; font-weight: bold; text-transform: uppercase; letter-spacing: 1px;">Player Not Found</div>`);
            return;
        }

        foundDocs.forEach((player) => {
            resultsHTML += `
                <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px; background: rgba(0,243,255,0.03); border: 1.5px solid var(--neon-cyan); border-radius: 10px; width: 100%; box-shadow: 0 0 10px rgba(0, 243, 255, 0.1);">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <img src="${player.photoURL || 'https://placehold.co/36'}" style="width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid var(--neon-cyan); box-shadow: 0 0 8px rgba(0, 243, 255, 0.2);">
                        <div style="text-align: left;">
                            <div style="font-weight: bold; color: #fff; font-size: 16px; font-family: 'Orbitron', sans-serif;">${player.displayName}</div>
                            <div style="font-size: 12px; color: var(--neon-gold); font-weight: bold; font-family: 'Orbitron', sans-serif; margin-top: 2px;">UID: ${player.uid}</div>
                        </div>
                    </div>
                    <button class="settings-btn" style="padding: 6px 12px; font-size: 12px; border-color: var(--neon-pink); font-family: 'Orbitron', sans-serif;" onclick="window.viewPublicProfile('${player.id}')">View Profile</button>
                </div>
            `;
        });

        setHTML(resultsHTML);
    } catch (e) {
        console.error("[Firestore] Player search by UID failed:", e);
        setHTML(`<div style="text-align: center; color: var(--neon-pink); font-size: 13px;">Search error occurred.</div>`);
    }
}

// Global active viewed public profile target uid
let activePublicProfileUid = null;

/**
 * Loads a specified user's public info card modal layout.
 */
export async function viewPublicProfile(uid) {
    activePublicProfileUid = uid;
    const publicModal = document.getElementById("public-profile-modal");
    if (!publicModal) return;

    try {
        const docRef = doc(db, "users", uid);
        const docSnap = await getDoc(docRef);

        if (!docSnap.exists()) return;
        const player = docSnap.data();

        document.getElementById("public-profile-avatar").innerHTML = player.photoURL
            ? `<img src="${player.photoURL}" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover;">`
            : "👤";
        document.getElementById("public-profile-username").innerText = player.displayName || "WaveRunner";
        document.getElementById("public-profile-country").innerText = player.country || "USA";
        document.getElementById("public-profile-bio").innerText = player.bio || "No bio description provided.";
        document.getElementById("public-profile-rating").innerText = player.rating || 1000;
        document.getElementById("public-profile-highscore").innerText = `${player.highScore || player.high_score || 0}m`;
        document.getElementById("public-profile-followers").innerText = player.followersCount || 0;
        document.getElementById("public-profile-following").innerText = player.followingCount || 0;
        document.getElementById("public-profile-uid-display").innerText = `UID: ${player.uid || "--------"}`;

        // Render Clickable Social Icons
        const socialsRow = document.getElementById("public-social-links");
        socialsRow.innerHTML = "";
        const networks = ["youtube", "instagram", "twitter", "twitch"];
        networks.forEach(net => {
            if (player[net] && player[net].trim() !== "") {
                const link = document.createElement("a");
                link.href = player[net];
                link.target = "_blank";
                link.className = `social-btn`;
                link.style.borderColor = "var(--neon-pink)";
                link.innerHTML = `<span>🔗</span>`;
                link.title = net.toUpperCase();
                socialsRow.appendChild(link);
            }
        });

        // Set Follow / Unfollow text based on active relations
        const followBtn = document.getElementById("public-follow-btn");
        if (currentUser) {
            const checkRef = doc(db, "users", currentUser.uid, "following", uid);
            const checkSnap = await getDoc(checkRef);
            followBtn.innerText = checkSnap.exists() ? "UNFOLLOW" : "FOLLOW";
        }

        // Switch to the public profile SPA Screen smoothly
        window.showScreen("public-profile-screen");
    } catch (e) {
        console.error("[Firestore] Error viewing public profile:", e);
    }
}

/**
 * Handles transactional Firestore updates for Following / Unfollowing relations.
 */
export async function toggleFollowPublicUser() {
    if (!currentUser || !activePublicProfileUid) {
        alert("Please log in to follow other players!");
        return;
    }
    if (currentUser.uid === activePublicProfileUid) {
        alert("You cannot follow your own shadow profile!");
        return;
    }

    const followBtn = document.getElementById("public-follow-btn");
    const isCurrentlyFollowing = followBtn.innerText === "UNFOLLOW";

    try {
        const followerDocRef = doc(db, "users", activePublicProfileUid, "followers", currentUser.uid);
        const followingDocRef = doc(db, "users", currentUser.uid, "following", activePublicProfileUid);
        const targetUserRef = doc(db, "users", activePublicProfileUid);
        const currentUserRef = doc(db, "users", currentUser.uid);

        if (currentUser) {
            await runTransaction(db, async (transaction) => {
                const targetSnap = await transaction.get(targetUserRef);
                const currentSnap = await transaction.get(currentUserRef);

                if (!targetSnap.exists() || !currentSnap.exists()) return;

                const targetData = targetSnap.data();
                const currentData = currentSnap.data();

                let targetFollowers = targetData.followersCount || 0;
                let currentFollowing = currentData.followingCount || 0;

                if (isCurrentlyFollowing) {
                    // Perform Unfollow
                    transaction.delete(followerDocRef);
                    transaction.delete(followingDocRef);
                    transaction.update(targetUserRef, { followersCount: Math.max(0, targetFollowers - 1) });
                    transaction.update(currentUserRef, { followingCount: Math.max(0, currentFollowing - 1) });
                } else {
                    // Perform Follow
                    transaction.set(followerDocRef, { followedAt: new Date().toISOString() });
                    transaction.set(followingDocRef, { followedAt: new Date().toISOString() });
                    transaction.update(targetUserRef, { followersCount: targetFollowers + 1 });
                    transaction.update(currentUserRef, { followingCount: currentFollowing + 1 });
                }
            });
        }

        console.log("[Firestore] Transaction follow updated successfully.");
        followBtn.innerText = isCurrentlyFollowing ? "FOLLOW" : "UNFOLLOW";

        // Instantly refresh counts
        const followersCountEl = document.getElementById("public-profile-followers");
        const currCount = parseInt(followersCountEl.innerText) || 0;
        followersCountEl.innerText = isCurrentlyFollowing ? Math.max(0, currCount - 1) : currCount + 1;
    } catch (e) {
        console.error("[Firestore] Error updating follow connection:", e);
    }
}

// --- MULTIPLAYER ROOMS & CHALLENGE ROUTING (REALTIME DB) ---

let activeRoomId = null;

/**
 * Creates a unique Lobby Room on the Realtime Database and joins it automatically.
 */
export async function createMultiplayerRoom() {
    if (!currentUser) {
        alert("Please sign in to host real-time tournament lobbies!");
        return;
    }

    try {
        const lobbyRef = push(rtdbRef(rtdb, "rooms"));
        const roomId = lobbyRef.key;
        activeRoomId = roomId;

        const initialRoomState = {
            host: currentUser.uid,
            status: "waiting", // waiting, racing
            players: {
                [currentUser.uid]: {
                    name: window.UI_STATE.username || "Rider_01",
                    pfp: window.UI_STATE.photoURL || currentUser.photoURL || "",
                    rating: window.UI_STATE.eloRating || 1000,
                    x: 150,
                    y: 337.5,
                    vy: 0,
                    angle: 0,
                    skin: window.UI_STATE.equippedSkin || "classic",
                    isDead: false
                }
            }
        };

        await set(rtdbRef(rtdb, `rooms/${roomId}`), initialRoomState);
        console.log(`[RTDB] Created multiplayer room: ${roomId}`);

        // Close search & open matchmaking lobby panel
        document.getElementById("social-modal").classList.remove("active");
        setupLobbyListener(roomId);
    } catch (e) {
        console.error("[RTDB] Lobby room generation failed:", e);
    }
}

/**
 * Subscribes to changes in a Realtime DB room to sync joining players.
 */
function setupLobbyListener(roomId) {
    const roomRef = rtdbRef(rtdb, `rooms/${roomId}`);
    onValue(roomRef, (snapshot) => {
        const data = snapshot.val();
        if (!data) return;

        // Render members
        const listContainer = document.getElementById("lobby-players-list");
        if (listContainer) {
            listContainer.innerHTML = "";
            Object.keys(data.players).forEach(pId => {
                const playerObj = data.players[pId];
                listContainer.innerHTML += `
                    <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px; background: rgba(255,255,255,0.03); border: 1.5px solid var(--neon-green); border-radius: 8px;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <img src="${playerObj.pfp || 'https://placehold.co/32'}" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover;">
                            <div>
                                <span style="font-weight: bold; color: #fff;">${playerObj.name}</span>
                                <span style="font-size: 11px; color: var(--neon-green); margin-left: 5px;">Rating: ${playerObj.rating}</span>
                            </div>
                        </div>
                        <span style="font-size: 12px; color: var(--neon-green);">READY</span>
                    </div>
                `;
            });
        }

        // Show START button if host and multiple players
        const startBtn = document.getElementById("lobby-start-btn");
        if (startBtn) {
            const pCount = Object.keys(data.players).length;
            if (data.host === currentUser.uid && pCount >= 1) {
                startBtn.style.display = "block";
            } else {
                startBtn.style.display = "none";
            }
        }

        document.getElementById("lobby-room-id").innerText = roomId;
        document.getElementById("multiplayer-lobby-panel").classList.add("active");

        // If host started the race, trigger game-engine initialization
        if (data.status === "racing" && window.currentGameMode !== "race") {
            window.launchMultiplayerMatch(roomId);
        }
    });
}

/**
 * Challenges another player directly by placing a direct invite on the RTDB.
 */
export async function challengePublicUser() {
    if (!currentUser || !activePublicProfileUid) return;

    try {
        const inviteRef = rtdbRef(rtdb, `challenges/${activePublicProfileUid}/${currentUser.uid}`);
        await set(inviteRef, {
            challengerName: window.UI_STATE.username || "Rider_01",
            challengerPfp: window.UI_STATE.photoURL || currentUser.photoURL || "",
            challengerRating: window.UI_STATE.eloRating || 1000,
            timestamp: Date.now()
        });

        alert("Challenge Invite sent successfully!");
        document.getElementById("public-profile-modal").classList.remove("active");
    } catch (e) {
        console.error("[RTDB] Error sending direct challenge:", e);
    }
}

/**
 * Triggers state change inside RTDB to initialize matching gameplay scene.
 */
export async function startMultiplayerMatch() {
    if (!activeRoomId) return;
    try {
        await set(rtdbRef(rtdb, `rooms/${activeRoomId}/status`), "racing");
    } catch (e) {
        console.error("[RTDB] Failed to start tournament:", e);
    }
}

/**
 * Gracefully detaches and destroys matching lobbies on departure.
 */
export async function leaveMultiplayerLobby() {
    if (!activeRoomId || !currentUser) return;
    try {
        const roomRef = rtdbRef(rtdb, `rooms/${activeRoomId}`);
        const snapshot = await rtdbGet(roomRef);
        if (snapshot.exists()) {
            const data = snapshot.val();
            if (data.host === currentUser.uid) {
                await remove(roomRef);
            } else {
                await remove(rtdbRef(rtdb, `rooms/${activeRoomId}/players/${currentUser.uid}`));
            }
        }
    } catch (e) {
        console.error("[RTDB] Error leaving lobby:", e);
    } finally {
        activeRoomId = null;
        document.getElementById("multiplayer-lobby-panel").classList.remove("active");
    }
}

// Expose handlers globally to the window object so inline HTML onclicks can invoke them
window.loginWithGoogle = loginWithGoogle;
window.logoutUser = logoutUser;
window.uploadProfilePicture = uploadProfilePicture;
window.updateProfileBio = updateProfileBio;
window.updateSocialLink = updateSocialLink;
window.searchPlayersByUID = searchPlayersByUID;
window.viewPublicProfile = viewPublicProfile;
window.toggleFollowPublicUser = toggleFollowPublicUser;
window.challengePublicUser = challengePublicUser;
window.createMultiplayerRoom = createMultiplayerRoom;
window.startMultiplayerMatch = startMultiplayerMatch;
window.leaveMultiplayerLobby = leaveMultiplayerLobby;

export { db, rtdb, storage, currentUser };
