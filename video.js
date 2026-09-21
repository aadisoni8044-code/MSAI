/**
 * VIDEO MODULE
 * Hero video background autoplay / sound toggle, Video gallery grid, Cinematic Video Modal Player
 */

document.addEventListener('DOMContentLoaded', () => {
  initHeroVideo();
  initVideoGallery();
  initVideoModal();
});

/**
 * Hero Video Autoplay & Mute / Unmute Toggle
 */
function initHeroVideo() {
  const heroVideo = document.getElementById('heroBgVideo');
  const soundToggleBtn = document.getElementById('heroSoundToggle');
  const soundIcon = document.getElementById('soundIcon');
  const soundLabel = document.getElementById('soundLabel');

  if (!heroVideo) return;

  // Modern browser autoplay rule: muted, loop, playsinline
  heroVideo.muted = true;
  heroVideo.play().catch(err => {
    console.warn("Autoplay was prevented or postponed:", err);
  });

  if (soundToggleBtn) {
    soundToggleBtn.addEventListener('click', () => {
      heroVideo.muted = !heroVideo.muted;
      updateSoundButtonUI(heroVideo.muted);
    });
  }

  function updateSoundButtonUI(isMuted) {
    if (!soundToggleBtn) return;
    if (isMuted) {
      soundToggleBtn.classList.remove('unmuted');
      if (soundLabel) soundLabel.textContent = "Unmute Audio";
      if (soundIcon) {
        soundIcon.innerHTML = `
          <path d="M11 5L6 9H2v6h4l5 4V5z"/>
          <line x1="23" y1="9" x2="17" y2="15"/>
          <line x1="17" y1="9" x2="23" y2="15"/>
        `;
      }
    } else {
      soundToggleBtn.classList.add('unmuted');
      if (soundLabel) soundLabel.textContent = "Sound On";
      if (soundIcon) {
        soundIcon.innerHTML = `
          <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
          <path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"></path>
        `;
      }
    }
  }
}

/**
 * Render Video Gallery Grid
 */
function initVideoGallery() {
  const videoGrid = document.getElementById('videoGrid');
  if (!videoGrid) return;

  const videosList = GAME_DATA.videos || [];

  videoGrid.innerHTML = videosList.map(v => `
    <div class="video-card scroll-reveal" data-video-id="${v.id}">
      <div class="video-thumbnail-wrapper">
        <img
          src="${v.poster}"
          onerror="this.onerror=null; this.src='${v.altPoster}';"
          alt="${v.title}"
          class="video-thumbnail"
          loading="lazy"
        />
        <div class="video-card-overlay">
          <button class="video-play-btn" aria-label="Play Video ${v.title}">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="currentColor">
              <polygon points="5 3 19 12 5 21 5 3"></polygon>
            </svg>
          </button>
          <span class="video-badge-duration">${v.duration}</span>
        </div>
      </div>
      <div class="video-card-body">
        <span class="video-tag-badge">${v.tag}</span>
        <h3 class="video-card-title">${v.title}</h3>
        <p class="video-card-desc">${v.description}</p>
      </div>
    </div>
  `).join('');

  // Add click listeners to open modal player
  const videoCards = videoGrid.querySelectorAll('.video-card');
  videoCards.forEach(card => {
    card.addEventListener('click', () => {
      const vidId = card.getAttribute('data-video-id');
      const videoData = GAME_DATA.videos.find(item => item.id === vidId);
      if (videoData) {
        openVideoModal(videoData);
      }
    });
  });
}

/**
 * Video Modal Player Setup & Lifecycle Management
 */
function initVideoModal() {
  const videoModal = document.getElementById('videoModal');
  if (!videoModal) return;

  const closeBtn = videoModal.querySelector('.video-modal-close');
  closeBtn?.addEventListener('click', closeVideoModal);

  // Close when clicking overlay backdrop
  videoModal.addEventListener('click', (e) => {
    if (e.target === videoModal || e.target.classList.contains('video-modal-backdrop')) {
      closeVideoModal();
    }
  });

  document.addEventListener('keydown', (e) => {
    if (videoModal.classList.contains('active') && e.key === 'Escape') {
      closeVideoModal();
    }
  });
}

function openVideoModal(videoData) {
  const videoModal = document.getElementById('videoModal');
  const modalVideo = document.getElementById('modalVideoPlayer');
  const modalTitle = document.getElementById('modalVideoTitle');
  const modalDesc = document.getElementById('modalVideoDesc');

  if (!videoModal || !modalVideo) return;

  // Pause hero video if playing to avoid multiple videos playing simultaneously
  const heroBgVideo = document.getElementById('heroBgVideo');
  if (heroBgVideo) {
    heroBgVideo.pause();
  }

  // Set modal video sources
  modalVideo.src = videoData.src;
  modalVideo.poster = videoData.poster;

  if (modalTitle) modalTitle.textContent = videoData.title;
  if (modalDesc) modalDesc.textContent = videoData.description;

  videoModal.classList.add('active');
  videoModal.setAttribute('aria-hidden', 'false');
  document.body.style.overflow = 'hidden';

  // Play modal video
  modalVideo.play().catch(err => {
    console.warn("Modal video play error fallback:", err);
  });
}

function closeVideoModal() {
  const videoModal = document.getElementById('videoModal');
  const modalVideo = document.getElementById('modalVideoPlayer');

  if (!videoModal) return;

  // STOP modal video playback completely
  if (modalVideo) {
    modalVideo.pause();
    modalVideo.currentTime = 0;
    modalVideo.removeAttribute('src'); // clear source to release memory/buffer
    modalVideo.load();
  }

  videoModal.classList.remove('active');
  videoModal.setAttribute('aria-hidden', 'true');
  document.body.style.overflow = '';

  // Resume hero background video if present
  const heroBgVideo = document.getElementById('heroBgVideo');
  if (heroBgVideo) {
    heroBgVideo.play().catch(() => {});
  }
}
