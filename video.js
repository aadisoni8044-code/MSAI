/**
 * VIDEO.JS - Hero Video Autoplay, Sound Control, & Modal Video Player Logic
 */

document.addEventListener('DOMContentLoaded', () => {
  const heroVideo = document.getElementById('heroVideo');
  const soundToggleBtn = document.getElementById('soundToggleBtn');
  const unmuteBadge = document.getElementById('unmuteBadge');
  const videoModal = document.getElementById('videoModal');
  const modalVideoPlayer = document.getElementById('modalVideoPlayer');
  const modalCloseBtn = document.getElementById('modalCloseBtn');
  const modalTitle = document.getElementById('modalTitle');
  const modalDesc = document.getElementById('modalDesc');

  // Hero Video Autoplay Execution (Muted Autoplay)
  if (heroVideo) {
    heroVideo.muted = true;
    heroVideo.playsInline = true;

    const playPromise = heroVideo.play();
    if (playPromise !== undefined) {
      playPromise.catch(error => {
        console.warn('Hero video autoplay blocked or muted fallback required:', error);
      });
    }
  }

  // Toggle Sound for Hero Video
  function toggleHeroSound() {
    if (!heroVideo) return;

    heroVideo.muted = !heroVideo.muted;
    const isMuted = heroVideo.muted;

    if (soundToggleBtn) {
      soundToggleBtn.innerHTML = isMuted ? '🔇' : '🔊';
      soundToggleBtn.setAttribute('title', isMuted ? 'Unmute Sound' : 'Mute Sound');
    }

    if (unmuteBadge) {
      unmuteBadge.innerHTML = isMuted ? '🔊 Click to Enable Sound' : '🔇 Mute Sound';
    }
  }

  if (soundToggleBtn) {
    soundToggleBtn.addEventListener('click', toggleHeroSound);
  }
  if (unmuteBadge) {
    unmuteBadge.addEventListener('click', toggleHeroSound);
  }

  // Modal Video Player Logic
  function openVideoModal(videoSrc, title, description) {
    if (!videoModal || !modalVideoPlayer) return;

    // Pause hero background video when watching a modal video
    if (heroVideo && !heroVideo.paused) {
      heroVideo.pause();
    }

    modalVideoPlayer.src = videoSrc || 'a.mp4';
    modalVideoPlayer.muted = false; // Enable sound inside modal
    if (modalTitle) modalTitle.textContent = title || 'Game Trailer';
    if (modalDesc) modalDesc.textContent = description || '';

    videoModal.classList.add('active');
    document.body.style.overflow = 'hidden';

    const playPromise = modalVideoPlayer.play();
    if (playPromise !== undefined) {
      playPromise.catch(err => {
        console.warn('Modal video playback failed:', err);
      });
    }
  }

  function closeVideoModal() {
    if (!videoModal || !modalVideoPlayer) return;

    modalVideoPlayer.pause();
    modalVideoPlayer.src = ''; // Stop buffering video stream
    videoModal.classList.remove('active');
    document.body.style.overflow = '';

    // Resume hero video if on homepage
    if (heroVideo) {
      heroVideo.play().catch(() => {});
    }
  }

  // Attach event triggers for video cards
  document.addEventListener('click', (e) => {
    const trigger = e.target.closest('.video-card-trigger');
    if (trigger) {
      e.preventDefault();
      const videoSrc = trigger.getAttribute('data-video-src') || 'a.mp4';
      const videoTitle = trigger.getAttribute('data-video-title') || 'Game Trailer';
      const videoDesc = trigger.getAttribute('data-video-desc') || '';
      openVideoModal(videoSrc, videoTitle, videoDesc);
    }
  });

  if (modalCloseBtn) {
    modalCloseBtn.addEventListener('click', closeVideoModal);
  }

  if (videoModal) {
    videoModal.addEventListener('click', (e) => {
      if (e.target === videoModal) {
        closeVideoModal();
      }
    });
  }

  // ESC Key listener to close video modal
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && videoModal && videoModal.classList.contains('active')) {
      closeVideoModal();
    }
  });
});
