/**
 * SHADOW REALM 2D - OFFICIAL GAME WEBSITE JAVASCRIPT
 * Features:
 * - Seamless background video playlist cycling (a.mp4 -> b.mp4 -> a.mp4)
 * - Robust unmuted autoplay fallback handler
 * - Mobile navigation drawer menu toggle
 * - Active section navigation highlight on scroll
 * - Lightbox modal popup for game screenshot preview
 * - Footer Privacy Policy & Contact Us dialog modals
 */

document.addEventListener('DOMContentLoaded', () => {
  // Initialize all core website interactive modules
  initHeroVideoPlaylist();
  initMobileNavigation();
  initScrollEffectsAndActiveNav();
  initScreenshotLightbox();
  initFooterModals();
});

/* ==========================================================================
   1. HERO BACKGROUND VIDEO PLAYLIST & AUTOPLAY FALLBACK
   ========================================================================== */
function initHeroVideoPlaylist() {
  const videoElement = document.getElementById('heroVideo');
  const fallbackContainer = document.getElementById('videoPlayFallback');
  const tapToPlayBtn = document.getElementById('tapToPlayBtn');

  if (!videoElement) return;

  // Video Playlist Sequence
  const videoSources = ['a.mp4', 'b.mp4'];
  let currentVideoIndex = 0;

  // Function to switch video source smoothly
  function loadAndPlayVideo(index) {
    currentVideoIndex = index % videoSources.length;
    videoElement.src = videoSources[currentVideoIndex];
    videoElement.load();
    attemptPlayVideo();
  }

  // Handle video completion -> seamless loop to next video in sequence
  videoElement.addEventListener('ended', () => {
    const nextIndex = (currentVideoIndex + 1) % videoSources.length;
    loadAndPlayVideo(nextIndex);
  });

  // Handle video loading or error graceful fallback
  videoElement.addEventListener('error', (e) => {
    console.warn(`Video playback error on file: ${videoSources[currentVideoIndex]}. Attempting next source.`, e);
    const nextIndex = (currentVideoIndex + 1) % videoSources.length;
    setTimeout(() => loadAndPlayVideo(nextIndex), 1000);
  });

  // Attempt video playback programmatically
  function attemptPlayVideo() {
    videoElement.muted = true; // Ensure muted to conform with browser autoplay policies
    const playPromise = videoElement.play();

    if (playPromise !== undefined) {
      playPromise
        .then(() => {
          // Playback started successfully
          if (fallbackContainer) {
            fallbackContainer.classList.add('hidden');
          }
        })
        .catch((error) => {
          console.warn('Autoplay restricted by browser policy:', error);
          // Show unobtrusive tap to play fallback overlay if autoplay is restricted
          if (fallbackContainer) {
            fallbackContainer.classList.remove('hidden');
          }
        });
    }
  }

  // Tap/Click handler for user gesture fallback button
  if (tapToPlayBtn) {
    tapToPlayBtn.addEventListener('click', () => {
      videoElement.play().then(() => {
        if (fallbackContainer) {
          fallbackContainer.classList.add('hidden');
        }
      });
    });
  }

  // Trigger initial playback start
  attemptPlayVideo();
}

/* ==========================================================================
   2. MOBILE NAVIGATION DRAWER & HAMBURGER MENU
   ========================================================================== */
function initMobileNavigation() {
  const hamburgerBtn = document.getElementById('hamburgerBtn');
  const mobileMenu = document.getElementById('mobileMenu');
  const mobileNavLinks = document.querySelectorAll('.mobile-nav-item');

  if (!hamburgerBtn || !mobileMenu) return;

  function toggleMobileMenu() {
    hamburgerBtn.classList.toggle('active');
    mobileMenu.classList.toggle('active');
  }

  function closeMobileMenu() {
    hamburgerBtn.classList.remove('active');
    mobileMenu.classList.remove('active');
  }

  hamburgerBtn.addEventListener('click', toggleMobileMenu);

  // Close menu when clicking any mobile navigation link
  mobileNavLinks.forEach(link => {
    link.addEventListener('click', closeMobileMenu);
  });

  // Close drawer if user clicks outside mobile menu
  document.addEventListener('click', (e) => {
    if (
      mobileMenu.classList.contains('active') &&
      !mobileMenu.contains(e.target) &&
      !hamburgerBtn.contains(e.target)
    ) {
      closeMobileMenu();
    }
  });
}

/* ==========================================================================
   3. SCROLL EFFECTS & ACTIVE NAV ITEM HIGHLIGHTING
   ========================================================================== */
function initScrollEffectsAndActiveNav() {
  const navbar = document.getElementById('navbar');
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav-links .nav-item');

  function handleScroll() {
    // Add shadow styling to sticky header on scroll
    if (window.scrollY > 50) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }

    // Determine current active section on viewport scroll
    let currentSectionId = '';
    const scrollPosition = window.scrollY + 120;

    sections.forEach(section => {
      const sectionTop = section.offsetTop;
      const sectionHeight = section.offsetHeight;

      if (scrollPosition >= sectionTop && scrollPosition < sectionTop + sectionHeight) {
        currentSectionId = section.getAttribute('id');
      }
    });

    // Update active nav link indicator
    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${currentSectionId}`) {
        link.classList.add('active');
      }
    });
  }

  window.addEventListener('scroll', handleScroll);
  handleScroll(); // Trigger once on page load
}

/* ==========================================================================
   4. SCREENSHOT LIGHTBOX MODAL
   ========================================================================== */
function initScreenshotLightbox() {
  const galleryItems = document.querySelectorAll('.gallery-item');
  const lightboxModal = document.getElementById('lightboxModal');
  const lightboxImage = document.getElementById('lightboxImage');
  const lightboxCaption = document.getElementById('lightboxCaption');
  const lightboxClose = document.getElementById('lightboxClose');

  if (!lightboxModal || !lightboxImage) return;

  function openLightbox(imageSrc, captionTitle) {
    lightboxImage.src = imageSrc;
    lightboxCaption.textContent = captionTitle || '';
    lightboxModal.classList.add('active');
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
  }

  function closeLightbox() {
    lightboxModal.classList.remove('active');
    document.body.style.overflow = '';
  }

  galleryItems.forEach(item => {
    item.addEventListener('click', () => {
      const src = item.getAttribute('data-src') || item.querySelector('img').src;
      const title = item.querySelector('h3') ? item.querySelector('h3').textContent : '';
      openLightbox(src, title);
    });
  });

  if (lightboxClose) {
    lightboxClose.addEventListener('click', closeLightbox);
  }

  // Close lightbox on backdrop click
  lightboxModal.addEventListener('click', (e) => {
    if (e.target === lightboxModal) {
      closeLightbox();
    }
  });

  // Close lightbox on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && lightboxModal.classList.contains('active')) {
      closeLightbox();
    }
  });
}

/* ==========================================================================
   5. FOOTER INFO MODALS (PRIVACY POLICY & CONTACT US)
   ========================================================================== */
function initFooterModals() {
  const privacyBtn = document.getElementById('privacyLinkBtn');
  const contactBtn = document.getElementById('contactLinkBtn');
  const privacyModal = document.getElementById('privacyModal');
  const contactModal = document.getElementById('contactModal');
  const privacyClose = document.getElementById('privacyClose');
  const contactClose = document.getElementById('contactClose');

  function openModal(modal) {
    if (modal) {
      modal.classList.add('active');
      document.body.style.overflow = 'hidden';
    }
  }

  function closeModal(modal) {
    if (modal) {
      modal.classList.remove('active');
      document.body.style.overflow = '';
    }
  }

  if (privacyBtn && privacyModal) {
    privacyBtn.addEventListener('click', () => openModal(privacyModal));
  }

  if (contactBtn && contactModal) {
    contactBtn.addEventListener('click', () => openModal(contactModal));
  }

  if (privacyClose && privacyModal) {
    privacyClose.addEventListener('click', () => closeModal(privacyModal));
  }

  if (contactClose && contactModal) {
    contactClose.addEventListener('click', () => closeModal(contactModal));
  }

  // Close modal when clicking outside content card
  [privacyModal, contactModal].forEach(modal => {
    if (modal) {
      modal.addEventListener('click', (e) => {
        if (e.target === modal) {
          closeModal(modal);
        }
      });
    }
  });

  // Close modal on Escape key press
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (privacyModal && privacyModal.classList.contains('active')) closeModal(privacyModal);
      if (contactModal && contactModal.classList.contains('active')) closeModal(contactModal);
    }
  });
}
