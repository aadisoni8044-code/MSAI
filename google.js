// ============================================================================
// google.js - Google Authentication & Firestore Sync System for plo.io
// ============================================================================

import { initializeApp } from "firebase/app";
import { getAuth, signInWithPopup, GoogleAuthProvider, signOut, onAuthStateChanged } from "firebase/auth";
import { getFirestore, doc, getDoc, setDoc, updateDoc, collection, query, where, getDocs, runTransaction } from "firebase/firestore";
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
const db = getFirestore(app);
const storage = getStorage(app);
const rtdb = getDatabase(app);
const provider = new GoogleAuthProvider();

// Track currently logged-in user
let currentUser = null;

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
        const playerDoc = await getOrCreatePlayerDoc(user);

        // Update local game state with fetched database stats
        if (playerDoc) {
            updateLocalGameState(playerDoc, user);
        }

        // Toggle UI widgets to Logged In state
        if (loggedOutSection) loggedOutSection.style.display = "none";
        if (loggedInSection) loggedInSection.style.display = "flex";

        if (userPhoto) userPhoto.src = user.photoURL || "https://placehold.co/32";
        if (userName) userName.innerText = user.displayName || "Google User";
        if (userEmail) userEmail.innerText = user.email || "";

        // Update mini and large profile avatars with actual Google profile picture
        updateUIAvatars(user.photoURL);

    } else {
        currentUser = null;
        console.log("[Auth] User logged out.");

        // Toggle UI widgets to Logged Out state
        if (loggedOutSection) loggedOutSection.style.display = "block";
        if (loggedInSection) loggedInSection.style.display = "none";

        // Clear UI STATE uid
        if (window.UI_STATE) {
            window.UI_STATE.uid = "--------";
        }

        // Close profile screen if user logged out
        const profileScreen = document.getElementById("profile-screen");
        if (profileScreen) profileScreen.classList.add("hidden");

        // Reset avatars to default emoji 👤
        updateUIAvatars(null);
    }
});

// --- CLOUD DATABASE SYNC (FIRESTORE) ---

/**
 * Retrieves the user profile from the Firestore 'players' collection.
 * Creates a new document with +50 PLO Coins sign-up bonus if it doesn't exist.
 */
async function getOrCreatePlayerDoc(user) {
    const docRef = doc(db, "players", user.uid);
    try {
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            console.log("[Firestore] Found returning player profile:", docSnap.data());
            return docSnap.data();
        } else {
            console.log("[Firestore] No profile found. Initializing new player profile...");

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
                // Check if candidate UID exists in players collection
                const q = query(collection(db, "players"), where("uid", "==", candidate));
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
                createdAt: new Date().toISOString()
            };

            await setDoc(docRef, initialData);
            console.log("[Firestore] Successfully created new player record with +50 Coins signup bonus.");

            // Show alert/notification about the bonus coins
            alert("Welcome! You've received a +50 Speedy Coins signup bonus!");
            return initialData;
        }
    } catch (e) {
        console.error("[Firestore] Error fetching/creating player document:", e);
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

    // 2. Persistent Save to local storage to sync across engines
    localStorage.setItem(window.KEYS.COINS, window.UI_STATE.ploCoins.toString());
    localStorage.setItem(window.KEYS.RATING, window.UI_STATE.eloRating.toString());
    localStorage.setItem(window.KEYS.STREAK, window.UI_STATE.streakDays.toString());
    localStorage.setItem(window.KEYS.USERNAME, window.UI_STATE.username);

    if (cloudData.high_score) {
        localStorage.setItem("plo_io_endless_hiscore_v2", cloudData.high_score.toString());
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

// --- INTERCEPT LOCAL STORAGE SAVES TO AUTO-SYNC TO FIRESTORE ---

/**
 * Hook into standard localStorage.setItem writes to capture rating, distance and coins
 * updates in real-time, syncing them automatically to Firestore without invasive hacks.
 */
const originalSetItem = localStorage.setItem;
localStorage.setItem = function(key, val) {
    // Invoke standard local write
    originalSetItem.apply(this, arguments);

    // If a user is logged in, sync changes instantly to Firestore
    if (currentUser) {
        syncLocalStorageKeyToCloud(key, val);
    }
};

async function syncLocalStorageKeyToCloud(key, val) {
    if (!currentUser) return;

    const userDocRef = doc(db, "players", currentUser.uid);
    try {
        const updateData = {};

        if (key === "plo_coins_balance") {
            updateData.plo_coins = parseInt(val) || 0;
        } else if (key === "plo_login_streak") {
            updateData.active_days = parseInt(val) || 0;
        } else if (key === "plo_skill_rating") {
            updateData.rating = parseInt(val) || 1000;
        } else if (key === "plo_io_endless_hiscore_v2") {
            updateData.high_score = parseInt(val) || 0;
        } else if (key === "plo_username") {
            updateData.displayName = val;
        }

        if (Object.keys(updateData).length > 0) {
            await updateDoc(userDocRef, updateData);
            console.log(`[Cloud Sync] Synced '${key}' to Firestore.`);
        }
    } catch (err) {
        console.error(`[Cloud Sync] Error syncing key '${key}':`, err);
    }
}

// --- ADDITIONAL MULTIPLAYER, REALTIME & SOCIAL APIS ---

/**
 * Compresses an image file client-side using Canvas and uploads it to Firebase Storage.
 */
export async function uploadProfilePicture(fileInput) {
    if (!currentUser) {
        alert("Please sign in to upload a profile picture!");
        return;
    }
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

        // Resize image slightly if it is too large (e.g. dimensions exceed 256px)
        const maxDim = 256;
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

        // Compress the image slightly
        const compressedDataUrl = cvs.toDataURL("image/jpeg", 0.85);

        // Upload the image file to Firebase Storage under the secure path profile_images/{userId}/avatar.jpg
        const storageRef = ref(storage, `profile_images/${currentUser.uid}/avatar.jpg`);
        await uploadString(storageRef, compressedDataUrl, "data_url");
        const downloadUrl = await getDownloadURL(storageRef);

        console.log("[Storage] PFP upload complete. Received direct URL:", downloadUrl);

        // Save this download URL to the user's Firestore document (users/{userId}/photoURL)
        const userDocRef = doc(db, "users", currentUser.uid);
        await setDoc(userDocRef, { photoURL: downloadUrl }, { merge: true });

        // Also save to standard players/{userId} collection for backwards compatibility & full game UI sync
        const playerDocRef = doc(db, "players", currentUser.uid);
        await setDoc(playerDocRef, { photoURL: downloadUrl }, { merge: true });

        // Immediately update the profile picture displayed across the game UI without requiring a full page reload
        if (window.UI_STATE) {
            window.UI_STATE.photoURL = downloadUrl;
        }
        updateUIAvatars(downloadUrl);
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
        const playerDocRef = doc(db, "players", currentUser.uid);
        await updateDoc(playerDocRef, { bio: newBio });
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
        const playerDocRef = doc(db, "players", currentUser.uid);
        const updateData = {};
        updateData[network] = url;
        await updateDoc(playerDocRef, updateData);
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
    const container = document.getElementById("social-search-results");
    if (!container) return;

    container.innerHTML = `<div style="text-align: center; color: var(--neon-cyan);">Querying Player ID...</div>`;

    try {
        const qByUID = query(
            collection(db, "players"),
            where("uid", "==", searchQuery.trim())
        );
        const snapshot = await getDocs(qByUID);
        let resultsHTML = "";

        const foundDocs = [];
        snapshot.forEach((doc) => {
            foundDocs.push({ id: doc.id, ...doc.data() });
        });

        if (foundDocs.length === 0) {
            container.innerHTML = `<div style="text-align: center; color: var(--neon-pink); font-size: 14px; font-weight: bold; text-transform: uppercase; letter-spacing: 1px;">Player Not Found</div>`;
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

        container.innerHTML = resultsHTML;
    } catch (e) {
        console.error("[Firestore] Player search by UID failed:", e);
        container.innerHTML = `<div style="text-align: center; color: var(--neon-pink); font-size: 13px;">Search error occurred.</div>`;
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
        const docRef = doc(db, "players", uid);
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
        document.getElementById("public-profile-highscore").innerText = `${player.high_score || 0}m`;
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
            const checkRef = doc(db, "players", currentUser.uid, "following", uid);
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
        const followerDocRef = doc(db, "players", activePublicProfileUid, "followers", currentUser.uid);
        const followingDocRef = doc(db, "players", currentUser.uid, "following", activePublicProfileUid);
        const targetUserRef = doc(db, "players", activePublicProfileUid);
        const currentUserRef = doc(db, "players", currentUser.uid);

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
                    pfp: currentUser.photoURL || "",
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
            challengerPfp: currentUser.photoURL || "",
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
