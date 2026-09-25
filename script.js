/**
 * CYBER RIFT 3D — Core Application Script
 * Features:
 * 1. Mobile navigation menu toggle
 * 2. Video autoplay handling with graceful fallback (a.mp4 -> b.mp4)
 * 3. Sound / unmute button control
 * 4. Video section theater and smooth trailer switcher
 * 5. 3D card tilt & parallax mouse effect
 * 6. Interactive canvas particle background
 * 7. Download button handler & missing-file error toast system
 * 8. Scroll reveal & navbar scroll states
 */

document.addEventListener('DOMContentLoaded', () => {
    initNavigation();
    initHeroVideoAutoplay();
    initSoundToggle();
    initVideoTheater();
    init3DTiltEffects();
    initParticleCanvas();
    initDownloadHandler();
    initScrollEffects();
});

/* ==========================================================================
   1. Navigation & Mobile Drawer
   ========================================================================== */
function initNavigation() {
    const navbar = document.getElementById('navbar');
    const hamburger = document.getElementById('hamburger');
    const navMenu = document.getElementById('navMenu');
    const navLinks = document.querySelectorAll('.nav-link');

    // Sticky Navbar Background on Scroll
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // Mobile Hamburger Toggle
    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
    });

    // Close menu when clicking nav links
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            hamburger.classList.remove('active');
            navMenu.classList.remove('active');
        });
    });

    // Active link update on scroll
    const sections = document.querySelectorAll('section[id]');
    window.addEventListener('scroll', () => {
        const scrollY = window.pageYOffset;
        sections.forEach(current => {
            const sectionHeight = current.offsetHeight;
            const sectionTop = current.offsetTop - 120;
            const sectionId = current.getAttribute('id');
            const link = document.querySelector(`.nav-menu a[href*=${sectionId}]`);

            if (link) {
                if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
                    link.classList.add('active');
                } else {
                    link.classList.remove('active');
                }
            }
        });
    });
}

/* ==========================================================================
   2. Hero Video Autoplay & Fallback (a.mp4 -> b.mp4)
   ========================================================================== */
function initHeroVideoAutoplay() {
    const video = document.getElementById('heroVideo');
    if (!video) return;

    // Browser Autoplay Requirement Setup
    video.muted = true;
    video.setAttribute('playsinline', '');

    // Attempt video play
    const playPromise = video.play();
    if (playPromise !== undefined) {
        playPromise.catch(error => {
            console.warn('Hero video autoplay was restricted or prevented:', error);
            // Autoplay restricted - browser policies handled gracefully
        });
    }

    // Fallback Logic: If a.mp4 fails to load/play, try b.mp4
    video.addEventListener('error', (e) => {
        console.warn('Hero primary video (a.mp4) failed to load, attempting fallback (b.mp4)', e);
        const currentSrc = video.currentSrc;
        if (currentSrc.includes('a.mp4')) {
            video.src = 'b.mp4';
            video.load();
            video.play().catch(err => console.warn('Fallback video autoplay error:', err));
        }
    }, true);
}

/* ==========================================================================
   3. Sound / Unmute Toggle Button
   ========================================================================== */
function initSoundToggle() {
    const soundBtn = document.getElementById('soundToggleBtn');
    const soundIcon = document.getElementById('soundIcon');
    const soundText = document.getElementById('soundText');
    const heroVideo = document.getElementById('heroVideo');

    if (!soundBtn || !heroVideo) return;

    soundBtn.addEventListener('click', () => {
        if (heroVideo.muted) {
            heroVideo.muted = false;
            soundIcon.textContent = '🔊';
            soundText.textContent = 'Sound On';
            soundBtn.style.borderColor = 'var(--accent-green)';
            soundBtn.style.boxShadow = '0 0 20px rgba(16, 185, 129, 0.5)';
        } else {
            heroVideo.muted = true;
            soundIcon.textContent = '🔇';
            soundText.textContent = 'Sound Off';
            soundBtn.style.borderColor = 'var(--border-glass-bright)';
            soundBtn.style.boxShadow = '0 0 15px rgba(0, 0, 0, 0.5)';
        }
    });
}

/* ==========================================================================
   4. Video Theater & Switcher Controls
   ========================================================================== */
function initVideoTheater() {
    const theaterVideo = document.getElementById('theaterVideo');
    const theaterSource = document.getElementById('theaterVideoSource');
    const statusBadge = document.getElementById('videoStatusBadge');
    const playBtn = document.getElementById('theaterPlayBtn');
    const muteBtn = document.getElementById('theaterMuteBtn');
    const fullscreenBtn = document.getElementById('theaterFullscreenBtn');
    const trailerCards = document.querySelectorAll('.trailer-card');

    if (!theaterVideo) return;

    // Play/Pause toggle
    playBtn.addEventListener('click', () => {
        if (theaterVideo.paused) {
            theaterVideo.play();
            playBtn.querySelector('.ctrl-icon').textContent = '⏸';
            playBtn.querySelector('.ctrl-label').textContent = 'PAUSE';
        } else {
            theaterVideo.pause();
            playBtn.querySelector('.ctrl-icon').textContent = '▶';
            playBtn.querySelector('.ctrl-label').textContent = 'PLAY';
        }
    });

    // Mute toggle for theater
    muteBtn.addEventListener('click', () => {
        if (theaterVideo.muted) {
            theaterVideo.muted = false;
            muteBtn.querySelector('.ctrl-icon').textContent = '🔊';
            muteBtn.querySelector('.ctrl-label').textContent = 'MUTE';
        } else {
            theaterVideo.muted = true;
            muteBtn.querySelector('.ctrl-icon').textContent = '🔇';
            muteBtn.querySelector('.ctrl-label').textContent = 'UNMUTE';
        }
    });

    // Fullscreen toggle
    fullscreenBtn.addEventListener('click', () => {
        if (theaterVideo.requestFullscreen) {
            theaterVideo.requestFullscreen();
        } else if (theaterVideo.webkitRequestFullscreen) {
            theaterVideo.webkitRequestFullscreen();
        } else if (theaterVideo.msRequestFullscreen) {
            theaterVideo.msRequestFullscreen();
        }
    });

    // Trailer switching logic with smooth transition
    trailerCards.forEach(card => {
        card.addEventListener('click', () => {
            const newSrc = card.getAttribute('data-src');
            const newTitle = card.getAttribute('data-title');

            if (theaterVideo.src.endsWith(newSrc)) return; // Already selected

            // Update active state
            trailerCards.forEach(c => {
                c.classList.remove('active');
                c.querySelector('.trailer-badge').textContent = 'SELECT';
            });
            card.classList.add('active');
            card.querySelector('.trailer-badge').textContent = 'ACTIVE';

            // Transition effect
            theaterVideo.classList.add('transitioning');

            setTimeout(() => {
                theaterSource.src = newSrc;
                theaterVideo.src = newSrc;
                theaterVideo.load();
                theaterVideo.play().then(() => {
                    playBtn.querySelector('.ctrl-icon').textContent = '⏸';
                    playBtn.querySelector('.ctrl-label').textContent = 'PAUSE';
                }).catch(err => console.warn('Theater play blocked:', err));

                statusBadge.textContent = `NOW PLAYING: ${newTitle}`;
                theaterVideo.classList.remove('transitioning');
            }, 300);
        });
    });
}

/* ==========================================================================
   5. 3D Parallax Tilt Effect on Cards
   ========================================================================== */
function init3DTiltEffects() {
    const tiltCards = document.querySelectorAll('.tilt-card');

    tiltCards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left; // x position inside card
            const y = e.clientY - rect.top;  // y position inside card

            const centerX = rect.width / 2;
            const centerY = rect.height / 2;

            const rotateX = ((y - centerY) / centerY) * -10; // Max tilt 10deg
            const rotateY = ((x - centerX) / centerX) * 10;

            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
        });

        card.addEventListener('mouseleave', () => {
            card.style.transform = `perspective(1000px) rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)`;
            card.style.transition = 'transform 0.5s ease';
        });

        card.addEventListener('mouseenter', () => {
            card.style.transition = 'none';
        });
    });
}

/* ==========================================================================
   6. Particle Background Canvas Animation
   ========================================================================== */
function initParticleCanvas() {
    const canvas = document.getElementById('particleCanvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    let width = canvas.width = window.innerWidth;
    let height = canvas.height = window.innerHeight;

    window.addEventListener('resize', () => {
        width = canvas.width = window.innerWidth;
        height = canvas.height = window.innerHeight;
    });

    // Particle class
    class Particle {
        constructor() {
            this.x = Math.random() * width;
            this.y = Math.random() * height;
            this.size = Math.random() * 2 + 1;
            this.speedX = (Math.random() - 0.5) * 0.8;
            this.speedY = (Math.random() - 0.5) * 0.8;
            this.opacity = Math.random() * 0.5 + 0.2;
            this.color = Math.random() > 0.5 ? '#6366F1' : '#06B6D4';
        }

        update() {
            this.x += this.speedX;
            this.y += this.speedY;

            if (this.x < 0) this.x = width;
            if (this.x > width) this.x = 0;
            if (this.y < 0) this.y = height;
            if (this.y > height) this.y = 0;
        }

        draw() {
            ctx.fillStyle = this.color;
            ctx.globalAlpha = this.opacity;
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fill();
        }
    }

    const particleCount = Math.min(Math.floor(width / 15), 80);
    const particles = [];
    for (let i = 0; i < particleCount; i++) {
        particles.push(new Particle());
    }

    function animate() {
        ctx.clearRect(0, 0, width, height);

        for (let i = 0; i < particles.length; i++) {
            particles[i].update();
            particles[i].draw();

            // Connect nearby particles with subtle lines
            for (let j = i + 1; j < particles.length; j++) {
                const dx = particles[i].x - particles[j].x;
                const dy = particles[i].y - particles[j].y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < 100) {
                    ctx.strokeStyle = '#6366F1';
                    ctx.globalAlpha = (1 - distance / 100) * 0.15;
                    ctx.lineWidth = 0.8;
                    ctx.beginPath();
                    ctx.moveTo(particles[i].x, particles[i].y);
                    ctx.lineTo(particles[j].x, particles[j].y);
                    ctx.stroke();
                }
            }
        }
        requestAnimationFrame(animate);
    }

    animate();
}

/* ==========================================================================
   7. Download Button Logic & Missing-File Error Toast Handling
   ========================================================================== */
function initDownloadHandler() {
    const downloadBtns = document.querySelectorAll('.download-btn');

    downloadBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const targetUrl = btn.getAttribute('href');
            const fileName = btn.getAttribute('data-file') || targetUrl.replace('./', '');
            const platform = btn.getAttribute('data-platform') || 'Game';

            // Verify if file exists on server before triggering download
            fetch(fileName, { method: 'HEAD' })
                .then(response => {
                    if (response.ok) {
                        showToast(`Starting download for ${platform} (${fileName})...`, 'success', '📥');
                        // Programmatically trigger download link after verification
                        const tempAnchor = document.createElement('a');
                        tempAnchor.href = targetUrl;
                        tempAnchor.download = fileName;
                        document.body.appendChild(tempAnchor);
                        tempAnchor.click();
                        document.body.removeChild(tempAnchor);
                    } else {
                        showToast('Download file is currently unavailable.', 'error', '⚠️');
                    }
                })
                .catch(err => {
                    console.warn('File download check failed, attempting fallback download:', err);
                    // Fallback attempt: trigger download directly
                    const tempAnchor = document.createElement('a');
                    tempAnchor.href = targetUrl;
                    tempAnchor.download = fileName;
                    document.body.appendChild(tempAnchor);
                    tempAnchor.click();
                    document.body.removeChild(tempAnchor);
                });
        });
    });
}

/**
 * Custom Toast Notification System
 */
function showToast(message, type = 'info', icon = 'ℹ️') {
    const toastContainer = document.getElementById('toastContainer');
    if (!toastContainer) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <span class="toast-icon">${icon}</span>
        <span class="toast-message">${message}</span>
    `;

    toastContainer.appendChild(toast);

    setTimeout(() => {
        toast.classList.add('hiding');
        setTimeout(() => {
            toast.remove();
        }, 350);
    }, 4000);
}

/* ==========================================================================
   8. Scroll Reveal Animations
   ========================================================================== */
function initScrollEffects() {
    const revealElements = document.querySelectorAll('.glass-card, .section-header');

    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, { threshold: 0.1 });

    revealElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1), transform 0.6s cubic-bezier(0.16, 1, 0.3, 1)';
        revealObserver.observe(el);
    });
}
