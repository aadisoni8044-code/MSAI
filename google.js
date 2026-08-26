/**
 * Speedy Arrow - Google Authentication & Cloud Sync
 * Safe module with offline-first fallbacks.
 */

export async function loginWithGoogle() {
    if (typeof window.showToast === 'function') {
        window.showToast("Signed in as Guest Rider (Offline Cloud Emulation Active)", "success");
    }
    const authModal = document.getElementById('auth-modal');
    if (authModal) authModal.classList.remove('active');
}
window.loginWithGoogle = loginWithGoogle;

export async function logoutUser() {
    if (typeof window.showToast === 'function') {
        window.showToast("Signed out", "info");
    }
}
window.logoutUser = logoutUser;

export async function syncUIStateToCloud() {
    // Cloud sync stub for persistence
}
window.syncUIStateToCloud = syncUIStateToCloud;

export async function uploadProfilePicture(fileInput) {
    if (!fileInput || !fileInput.files || !fileInput.files[0]) return;
    const file = fileInput.files[0];

    try {
        const reader = new FileReader();
        reader.onload = (e) => {
            const dataUrl = e.target.result;
            if (window.UI_STATE) {
                window.UI_STATE.photoURL = dataUrl;
                if (typeof window.saveStateItem === 'function') {
                    window.saveStateItem(window.KEYS.PHOTO_URL, dataUrl);
                }
                if (typeof window.updateUIAvatars === 'function') {
                    window.updateUIAvatars(dataUrl);
                }
            }
            if (typeof window.showToast === 'function') {
                window.showToast("Profile avatar updated successfully!", "success");
            }
        };
        reader.readAsDataURL(file);
    } catch (err) {
        console.warn("Avatar upload error:", err);
    }
}
window.uploadProfilePicture = uploadProfilePicture;

export async function updateProfileBio(newBio) {
    if (window.UI_STATE) {
        window.UI_STATE.bio = newBio;
        if (typeof window.saveStateItem === 'function') {
            window.saveStateItem(window.KEYS.BIO, newBio);
        }
    }
}
window.updateProfileBio = updateProfileBio;

export async function updateSocialLink(network, url) {
    if (window.UI_STATE) {
        window.UI_STATE[network] = url;
    }
}
window.updateSocialLink = updateSocialLink;
