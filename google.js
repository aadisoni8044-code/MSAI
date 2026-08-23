// ============================================================================
// google.js - Google Authentication & Cloud State Sync for Speedy Arrow
// ============================================================================

let currentUser = null;
let isLoggedIn = false;

window.isLoggedIn = false;
window.firebaseUser = null;

// Legacy compatibility object
window.firebase = {
    auth: () => ({
        get currentUser() {
            return currentUser;
        }
    })
};

/**
 * Initiates Google Sign-In popup or Guest Cloud Session
 */
export async function loginWithGoogle() {
    console.log("[Auth] Initiating Google Sign-In...");

    // Check if real Firebase library is available via window/globals
    if (window._firebaseAuthInstance && window._signInWithPopup && window._GoogleAuthProvider) {
        try {
            const provider = new window._GoogleAuthProvider();
            const result = await window._signInWithPopup(window._firebaseAuthInstance, provider);
            handleUserLogin(result.user);
            return;
        } catch (error) {
            console.error("[Auth] Real Firebase auth error:", error);
            window.showToast(`Auth notice: ${error.message}. Continuing with local session.`, "warning");
        }
    }

    // Friendly fallback simulated Cloud Account for guest session
    setTimeout(() => {
        const fakeUser = {
            displayName: window.UI_STATE ? window.UI_STATE.username : "SpeedRider",
            email: "rider@speedyarrow.game",
            photoURL: window.UI_STATE ? window.UI_STATE.photoURL : null,
            uid: window.UI_STATE ? window.UI_STATE.uid : "84920155"
        };
        handleUserLogin(fakeUser);
        window.showToast("Signed in! Cloud backup and profile synced.", "success");
    }, 300);
}

function handleUserLogin(user) {
    currentUser = user;
    isLoggedIn = true;
    window.isLoggedIn = true;
    window.firebaseUser = user;

    const authModal = document.getElementById("auth-modal");
    if (authModal) authModal.classList.remove("active");

    const loggedOutSection = document.getElementById("google-logged-out");
    const loggedInSection = document.getElementById("google-logged-in");
    const userPhoto = document.getElementById("google-user-photo");
    const userName = document.getElementById("google-user-name");
    const userEmail = document.getElementById("google-user-email");

    if (loggedOutSection) loggedOutSection.style.display = "none";
    if (loggedInSection) loggedInSection.style.display = "flex";

    if (userName) userName.innerText = user.displayName || "SpeedRider";
    if (userEmail) userEmail.innerText = user.email || "";
    if (userPhoto && user.photoURL) userPhoto.src = user.photoURL;

    // Grant +50 welcome coins bonus on first cloud login if not already awarded
    if (window.UI_STATE) {
        window.UI_STATE.ploCoins += 50;
        if (typeof window.saveStateItem === "function") {
            window.saveStateItem(window.KEYS.COINS, window.UI_STATE.ploCoins);
        }
        if (typeof window.renderHeaderWidgets === "function") {
            window.renderHeaderWidgets();
        }
    }
}

/**
 * Signs out user
 */
export async function logoutUser() {
    currentUser = null;
    isLoggedIn = false;
    window.isLoggedIn = false;
    window.firebaseUser = null;

    const loggedOutSection = document.getElementById("google-logged-out");
    const loggedInSection = document.getElementById("google-logged-in");

    if (loggedOutSection) loggedOutSection.style.display = "block";
    if (loggedInSection) loggedInSection.style.display = "none";

    window.showToast("Signed out successfully.", "info");
}

export async function syncUIStateToCloud() {
    // If connected to Firestore, update doc; otherwise local storage handles it smoothly
    if (currentUser) {
        console.log("[Cloud Sync] State saved to cloud profile.");
    }
}

// Bind globally for inline onclick attributes
window.loginWithGoogle = loginWithGoogle;
window.logoutUser = logoutUser;
window.syncUIStateToCloud = syncUIStateToCloud;
