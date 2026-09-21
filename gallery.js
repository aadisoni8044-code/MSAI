/**
 * GALLERY.JS - Dynamic Image Rendering & Fullscreen Lightbox System
 */

document.addEventListener('DOMContentLoaded', () => {
  const photoGridContainer = document.getElementById('photoGridContainer');
  const videoGridContainer = document.getElementById('videoGridContainer');

  const photoLightbox = document.getElementById('photoLightbox');
  const lightboxImg = document.getElementById('lightboxImg');
  const lightboxTitle = document.getElementById('lightboxTitle');
  const lightboxDesc = document.getElementById('lightboxDesc');
  const lightboxCloseBtn = document.getElementById('lightboxCloseBtn');
  const lightboxPrevBtn = document.getElementById('lightboxPrevBtn');
  const lightboxNextBtn = document.getElementById('lightboxNextBtn');

  let currentPhotoIndex = 0;
  const photoDataList = (typeof GAME_DATA !== 'undefined' && GAME_DATA.photos) ? GAME_DATA.photos : [];

  // Render Photo Cards
  if (photoGridContainer && photoDataList.length > 0) {
    photoGridContainer.innerHTML = photoDataList.map((photo, index) => `
      <div class="gallery-card reveal delay-${(index % 4) + 1}" data-index="${index}">
        <img src="${photo.src}" alt="${photo.title}" loading="lazy" />
        <div class="gallery-card-overlay">
          <span class="badge gallery-card-tag">${photo.category}</span>
          <h4 class="gallery-card-title">${photo.title}</h4>
        </div>
      </div>
    `).join('');

    // Attach click listeners to photo cards
    const photoCards = photoGridContainer.querySelectorAll('.gallery-card');
    photoCards.forEach(card => {
      card.addEventListener('click', () => {
        const index = parseInt(card.getAttribute('data-index') || '0', 10);
        openLightbox(index);
      });
    });
  }

  // Render Video Cards
  if (videoGridContainer && typeof GAME_DATA !== 'undefined' && GAME_DATA.videos) {
    videoGridContainer.innerHTML = GAME_DATA.videos.map((vid, idx) => `
      <div class="video-card reveal delay-${(idx % 4) + 1}">
        <div class="video-thumb-wrapper video-card-trigger"
             data-video-src="${vid.src}"
             data-video-title="${vid.title}"
             data-video-desc="${vid.desc}">
          <img src="${vid.poster}" alt="${vid.title}" loading="lazy" />
          <div class="play-button-overlay">
            <div class="play-icon">▶</div>
          </div>
          <span class="video-duration">${vid.duration}</span>
        </div>
        <div class="video-card-body">
          <h3 class="video-card-title">${vid.title}</h3>
          <p class="video-card-desc">${vid.desc}</p>
          <button class="btn btn-primary video-card-trigger"
                  data-video-src="${vid.src}"
                  data-video-title="${vid.title}"
                  data-video-desc="${vid.desc}">
            ▶ Watch Video
          </button>
        </div>
      </div>
    `).join('');
  }

  // Open Lightbox Modal
  function openLightbox(index) {
    if (!photoLightbox || !photoDataList[index]) return;

    currentPhotoIndex = index;
    const photo = photoDataList[currentPhotoIndex];

    if (lightboxImg) lightboxImg.src = photo.src;
    if (lightboxTitle) lightboxTitle.textContent = photo.title;
    if (lightboxDesc) lightboxDesc.textContent = photo.desc;

    photoLightbox.classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  // Close Lightbox Modal
  function closeLightbox() {
    if (!photoLightbox) return;
    photoLightbox.classList.remove('active');
    document.body.style.overflow = '';
  }

  function showNextPhoto() {
    currentPhotoIndex = (currentPhotoIndex + 1) % photoDataList.length;
    openLightbox(currentPhotoIndex);
  }

  function showPrevPhoto() {
    currentPhotoIndex = (currentPhotoIndex - 1 + photoDataList.length) % photoDataList.length;
    openLightbox(currentPhotoIndex);
  }

  if (lightboxCloseBtn) lightboxCloseBtn.addEventListener('click', closeLightbox);
  if (lightboxNextBtn) lightboxNextBtn.addEventListener('click', showNextPhoto);
  if (lightboxPrevBtn) lightboxPrevBtn.addEventListener('click', showPrevPhoto);

  if (photoLightbox) {
    photoLightbox.addEventListener('click', (e) => {
      if (e.target === photoLightbox) {
        closeLightbox();
      }
    });
  }

  // Keyboard navigation for Lightbox
  document.addEventListener('keydown', (e) => {
    if (!photoLightbox || !photoLightbox.classList.contains('active')) return;

    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowRight') showNextPhoto();
    if (e.key === 'ArrowLeft') showPrevPhoto();
  });
});
