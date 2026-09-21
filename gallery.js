/**
 * GALLERY MODULE
 * Image gallery grid rendering, filtering, lazy loading, and Lightbox modal
 */

let currentImageIndex = 0;
let galleryImagesList = [];

document.addEventListener('DOMContentLoaded', () => {
  initGallery();
});

function initGallery() {
  const galleryGrid = document.getElementById('galleryGrid');
  if (!galleryGrid) return;

  galleryImagesList = GAME_DATA.gallery || [];
  renderGalleryGrid(galleryImagesList);
  initGalleryFilters();
  initLightboxModal();
}

function renderGalleryGrid(images) {
  const galleryGrid = document.getElementById('galleryGrid');
  if (!galleryGrid) return;

  if (images.length === 0) {
    galleryGrid.innerHTML = `<div class="empty-gallery">No images found for this category.</div>`;
    return;
  }

  galleryGrid.innerHTML = images.map((img, index) => `
    <div class="gallery-card scroll-reveal" data-category="${img.category}" data-index="${index}">
      <div class="gallery-card-inner">
        <img
          src="${img.src}"
          onerror="this.onerror=null; this.src='${img.altSrc}';"
          alt="${img.title}"
          loading="lazy"
          class="gallery-img"
        />
        <div class="gallery-overlay">
          <div class="gallery-info">
            <span class="gallery-tag">${img.category.toUpperCase()}</span>
            <h3 class="gallery-title">${img.title}</h3>
            <p class="gallery-caption">${img.caption}</p>
          </div>
          <button class="gallery-view-btn" aria-label="View Fullscreen Image">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M15 3h6v6M14 10l7-7M9 21H3v-6M10 14l-7 7"/>
            </svg>
          </button>
        </div>
      </div>
    </div>
  `).join('');

  // Add click handlers for lightbox
  const cards = galleryGrid.querySelectorAll('.gallery-card');
  cards.forEach(card => {
    card.addEventListener('click', () => {
      const idx = parseInt(card.getAttribute('data-index'), 10);
      openLightbox(idx);
    });
  });
}

function initGalleryFilters() {
  const filterBtns = document.querySelectorAll('.gallery-filter-btn');
  if (!filterBtns.length) return;

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const filterValue = btn.getAttribute('data-filter');
      if (filterValue === 'all') {
        galleryImagesList = GAME_DATA.gallery;
      } else {
        galleryImagesList = GAME_DATA.gallery.filter(item => item.category === filterValue);
      }
      renderGalleryGrid(galleryImagesList);
    });
  });
}

function initLightboxModal() {
  const lightboxModal = document.getElementById('lightboxModal');
  if (!lightboxModal) return;

  const closeBtn = lightboxModal.querySelector('.lightbox-close');
  const prevBtn = lightboxModal.querySelector('.lightbox-prev');
  const nextBtn = lightboxModal.querySelector('.lightbox-next');

  closeBtn?.addEventListener('click', closeLightbox);
  prevBtn?.addEventListener('click', prevLightboxImage);
  nextBtn?.addEventListener('click', nextLightboxImage);

  // Close when clicking background overlay
  lightboxModal.addEventListener('click', (e) => {
    if (e.target === lightboxModal || e.target.classList.contains('lightbox-backdrop')) {
      closeLightbox();
    }
  });

  // Keyboard navigation
  document.addEventListener('keydown', (e) => {
    if (!lightboxModal.classList.contains('active')) return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowLeft') prevLightboxImage();
    if (e.key === 'ArrowRight') nextLightboxImage();
  });
}

function openLightbox(index) {
  const lightboxModal = document.getElementById('lightboxModal');
  if (!lightboxModal || !galleryImagesList[index]) return;

  currentImageIndex = index;
  updateLightboxContent();

  lightboxModal.classList.add('active');
  lightboxModal.setAttribute('aria-hidden', 'false');
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  const lightboxModal = document.getElementById('lightboxModal');
  if (!lightboxModal) return;

  lightboxModal.classList.remove('active');
  lightboxModal.setAttribute('aria-hidden', 'true');
  document.body.style.overflow = '';
}

function prevLightboxImage() {
  if (galleryImagesList.length === 0) return;
  currentImageIndex = (currentImageIndex - 1 + galleryImagesList.length) % galleryImagesList.length;
  updateLightboxContent();
}

function nextLightboxImage() {
  if (galleryImagesList.length === 0) return;
  currentImageIndex = (currentImageIndex + 1) % galleryImagesList.length;
  updateLightboxContent();
}

function updateLightboxContent() {
  const imgData = galleryImagesList[currentImageIndex];
  if (!imgData) return;

  const lightboxImg = document.getElementById('lightboxImg');
  const lightboxTitle = document.getElementById('lightboxTitle');
  const lightboxCaption = document.getElementById('lightboxCaption');
  const lightboxCounter = document.getElementById('lightboxCounter');

  if (lightboxImg) {
    lightboxImg.src = imgData.src;
    lightboxImg.onerror = () => { lightboxImg.src = imgData.altSrc; };
    lightboxImg.alt = imgData.title;
  }
  if (lightboxTitle) lightboxTitle.textContent = imgData.title;
  if (lightboxCaption) lightboxCaption.textContent = imgData.caption;
  if (lightboxCounter) {
    lightboxCounter.textContent = `${currentImageIndex + 1} / ${galleryImagesList.length}`;
  }
}
