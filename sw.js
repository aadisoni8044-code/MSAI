const CACHE_NAME = "plo-io-neon-cache-v2";
const ASSETS = [
    "./",
    "index.html",
    "style.css",
    "ui.js",
    "game-engine.js",
    "google.js",
    "manifest.json",
    "icon-192.png",
    "icon-512.png"
];

// Standard PWA Service Worker install event
self.addEventListener("install", (event) => {
    console.log("[Service Worker] Install event...");
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log("[Service Worker] Caching application assets...");
            return cache.addAll(ASSETS);
        })
    );
    self.skipWaiting();
});

// Standard PWA Service Worker activate event
self.addEventListener("activate", (event) => {
    console.log("[Service Worker] Activate event...");
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.map((key) => {
                    if (key !== CACHE_NAME) {
                        console.log(`[Service Worker] Removing old cache: ${key}`);
                        return caches.delete(key);
                    }
                })
            );
        })
    );
    self.clients.claim();
});

// Standard PWA Service Worker fetch event to satisfy Chromium PWA criteria
self.addEventListener("fetch", (event) => {
    // Exclude Firebase API endpoints or foreign CDNs from local static caching
    if (event.request.url.includes("firestore.googleapis.com") || event.request.url.includes("identitytoolkit")) {
        return;
    }

    event.respondWith(
        caches.match(event.request).then((cachedResponse) => {
            if (cachedResponse) {
                return cachedResponse;
            }
            return fetch(event.request).then((networkResponse) => {
                // Cache dynamic static assets on-the-fly where appropriate
                if (networkResponse.status === 200 && event.request.url.startsWith(self.location.origin)) {
                    return caches.open(CACHE_NAME).then((cache) => {
                        cache.put(event.request, networkResponse.clone());
                        return networkResponse;
                    });
                }
                return networkResponse;
            }).catch(() => {
                // Offline fallback if fetch fails
                console.log("[Service Worker] Fetch failed, device is likely offline.");
            });
        })
    );
});
