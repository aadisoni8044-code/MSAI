/* ==========================================================================
   SYLVAN WHISPERS - GAME DOWNLOAD PAGE JAVASCRIPT
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
    // ----------------------------------------------------------------------
    // 1. Video Autoplay & Mute/Unmute Audio Control
    // ----------------------------------------------------------------------
    const bgVideo = document.getElementById('bgVideo');
    const soundToggleBtn = document.getElementById('soundToggleBtn');
    const soundIcon = document.getElementById('soundIcon');
    const soundText = document.getElementById('soundText');

    if (bgVideo) {
        // Ensure initial mute & inline play for strict browser autoplay policies
        bgVideo.muted = true;
        bgVideo.playsInline = true;

        const attemptPlay = () => {
            const playPromise = bgVideo.play();
            if (playPromise !== undefined) {
                playPromise.then(() => {
                    // Video playback started successfully
                }).catch(error => {
                    console.log('Autoplay deferred or paused by browser policies:', error);
                    // Add single-click listener to retry play on user interaction if blocked
                    const enableVideoOnTouch = () => {
                        bgVideo.play();
                        document.removeEventListener('click', enableVideoOnTouch);
                        document.removeEventListener('touchstart', enableVideoOnTouch);
                    };
                    document.addEventListener('click', enableVideoOnTouch, { once: true });
                    document.addEventListener('touchstart', enableVideoOnTouch, { once: true });
                });
            }
        };

        attemptPlay();

        // Sound Toggle Interaction
        if (soundToggleBtn) {
            soundToggleBtn.addEventListener('click', () => {
                if (bgVideo.muted) {
                    bgVideo.muted = false;
                    soundIcon.textContent = '🔊';
                    soundText.textContent = 'Sound On';
                    soundToggleBtn.classList.add('sound-active');

                    // Ensure video is playing when unmuted
                    if (bgVideo.paused) {
                        bgVideo.play().catch(e => console.log('Error playing video:', e));
                    }
                } else {
                    bgVideo.muted = true;
                    soundIcon.textContent = '🔇';
                    soundText.textContent = 'Sound Off';
                    soundToggleBtn.classList.remove('sound-active');
                }
            });
        }
    }

    // ----------------------------------------------------------------------
    // 2. Mobile Drawer Navigation & Menu Toggle
    // ----------------------------------------------------------------------
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const navLinks = document.getElementById('navLinks');
    const mobileNavOverlay = document.getElementById('mobileNavOverlay');
    const allNavLinks = document.querySelectorAll('.nav-link');

    const toggleMobileMenu = (forceClose = false) => {
        const isOpen = forceClose ? false : !navLinks.classList.contains('mobile-active');
        if (isOpen) {
            navLinks.classList.add('mobile-active');
            mobileMenuBtn.classList.add('active');
            mobileNavOverlay.classList.add('active');
            document.body.style.overflow = 'hidden';
        } else {
            navLinks.classList.remove('mobile-active');
            mobileMenuBtn.classList.remove('active');
            mobileNavOverlay.classList.remove('active');
            document.body.style.overflow = '';
        }
    };

    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', () => toggleMobileMenu());
    }

    if (mobileNavOverlay) {
        mobileNavOverlay.addEventListener('click', () => toggleMobileMenu(true));
    }

    // Close menu when clicking any nav link
    allNavLinks.forEach(link => {
        link.addEventListener('click', () => toggleMobileMenu(true));
    });

    // ----------------------------------------------------------------------
    // 3. Header Scroll Effect & Active Section Highlighting
    // ----------------------------------------------------------------------
    const navbar = document.getElementById('navbar');
    const sections = document.querySelectorAll('section[id]');

    const handleScroll = () => {
        const scrollY = window.scrollY;

        // Navbar background contrast on scroll
        if (navbar) {
            if (scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }

        // Active nav link highlight based on scroll position
        sections.forEach(current => {
            const sectionHeight = current.offsetHeight;
            const sectionTop = current.offsetTop - 100;
            const sectionId = current.getAttribute('id');
            const targetLink = document.querySelector(`.nav-links a[href*="${sectionId}"]`);

            if (targetLink) {
                if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
                    allNavLinks.forEach(l => l.classList.remove('active'));
                    targetLink.classList.add('active');
                }
            }
        });
    };

    window.addEventListener('scroll', handleScroll);
    handleScroll(); // Initial invocation
});
