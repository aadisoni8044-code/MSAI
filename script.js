/**
 * ZIPGRAM - Main Application Script
 * Vanilla JavaScript SPA Controller with LocalStorage Persistence
 */

(function () {
  'use strict';

  // LOCAL STORAGE KEYS
  const STORAGE_KEYS = {
    POSTS: 'zipgram_posts_v1',
    USER: 'zipgram_user_v1',
    THEME: 'zipgram_theme_v1',
    NOTIFS: 'zipgram_notifs_v1',
    CONVERSATIONS: 'zipgram_conversations_v1',
    FOLLOWING: 'zipgram_following_v1'
  };

  // INITIAL DEMO DATA
  const DEFAULT_USER = {
    name: 'Alex Rivers',
    handle: '@alexrivers',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
    cover: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&auto=format&fit=crop&q=80',
    bio: 'Product Designer & Frontend Engineer building clean digital experiences. Coffee enthusiast ☕ | Crafting Zipgram ⚡',
    location: 'San Francisco, CA',
    website: 'https://alexrivers.dev',
    followingCount: 342,
    followersCount: 1280
  };

  const DEFAULT_POSTS = [
    {
      id: 'p1',
      author: 'Aria Chen',
      handle: '@ariachen',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=120&auto=format&fit=crop&q=80',
      verified: true,
      text: 'Just launched Zipgram v2.0! Built entirely with zero framework overhead — lightning fast, ultra smooth responsive animations, and full dark/light mode support. What do you think? ⚡🚀 #buildinpublic #webdev',
      image: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&auto=format&fit=crop&q=80',
      timestamp: '15m',
      likes: 142,
      reposts: 38,
      commentsCount: 12,
      isLiked: false,
      isReposted: false,
      category: 'tech',
      comments: [
        { id: 'c1', author: 'Liam Vance', text: 'This UI is super slick and responsive!', timestamp: '10m' },
        { id: 'c2', author: 'Elena Rostova', text: 'Love the purple accent color palette!', timestamp: '5m' }
      ]
    },
    {
      id: 'p2',
      author: 'Marcus Vance',
      handle: '@marcusvance',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop&q=80',
      verified: true,
      text: 'Morning coffee & clean code setup. Nothing beats starting the day with zero open bug tickets. ☕💻',
      image: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&auto=format&fit=crop&q=80',
      timestamp: '1h',
      likes: 89,
      reposts: 14,
      commentsCount: 4,
      isLiked: false,
      isReposted: false,
      category: 'tech',
      comments: [
        { id: 'c3', author: 'Sophie Taylor', text: 'Dream setup right there!', timestamp: '45m' }
      ]
    },
    {
      id: 'p3',
      author: 'Elena Rostova',
      handle: '@elena_ui',
      avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120&auto=format&fit=crop&q=80',
      verified: false,
      text: 'Design Tip: Micro-interactions are what separate good apps from extraordinary products. Smooth hover transitions and heart animations instantly boost user delight. ✨🎨',
      image: 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&auto=format&fit=crop&q=80',
      timestamp: '3h',
      likes: 310,
      reposts: 95,
      commentsCount: 28,
      isLiked: true,
      isReposted: false,
      category: 'design',
      comments: []
    },
    {
      id: 'p4',
      author: 'Cyber Pulse',
      handle: '@cyberpulse',
      avatar: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=120&auto=format&fit=crop&q=80',
      verified: true,
      text: 'BREAKING: Next-gen AI models are now capable of real-time web UI rendering in under 12ms. The future of dynamic web experiences is here! 🤖⚡',
      image: '',
      timestamp: '5h',
      likes: 520,
      reposts: 180,
      commentsCount: 64,
      isLiked: false,
      isReposted: true,
      category: 'ai',
      comments: []
    }
  ];

  const DEFAULT_TRENDS = [
    { category: 'Technology · Trending', topic: '#ZipgramLaunch', postsCount: '48.2K Zips' },
    { category: 'Design · Trending', topic: 'Material 3 & Neo-Brutalism', postsCount: '19.5K Zips' },
    { category: 'Artificial Intelligence', topic: 'Quantum Neural Nets', postsCount: '84.1K Zips' },
    { category: 'Gaming · Worldwide', topic: 'Unreal Engine 5.4', postsCount: '32.6K Zips' },
    { category: 'Web Development', topic: '#VanillaJS', postsCount: '15.9K Zips' }
  ];

  const DEFAULT_SUGGESTED = [
    { name: 'Sarah Jenkins', handle: '@sarahj_dev', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80', verified: true },
    { name: 'Devon Knight', handle: '@dknight', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80', verified: false },
    { name: 'Maya Lin', handle: '@mayacodes', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80', verified: true }
  ];

  const DEFAULT_NOTIFICATIONS = [
    { id: 'n1', type: 'like', user: 'Aria Chen', avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80', text: 'liked your Zip post', snippet: 'Product Designer & Frontend Engineer building clean digital experiences...', timestamp: '12m ago', unread: true },
    { id: 'n2', type: 'comment', user: 'Liam Vance', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80', text: 'replied: "This UI is super slick and responsive!"', snippet: 'Zipgram v2.0 Launch', timestamp: '45m ago', unread: true },
    { id: 'n3', type: 'follow', user: 'Sarah Jenkins', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80', text: 'started following you', snippet: '', timestamp: '2h ago', unread: false },
    { id: 'n4', type: 'repost', user: 'Elena Rostova', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&auto=format&fit=crop&q=80', text: 'reposted your Zip', snippet: 'Just launched Zipgram v2.0!', timestamp: '5h ago', unread: false }
  ];

  const DEFAULT_CONVERSATIONS = [
    {
      id: 'conv1',
      user: 'Aria Chen',
      handle: '@ariachen',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
      online: true,
      messages: [
        { sender: 'them', text: 'Hey Alex! Loved the new Zipgram design update.', time: '10:30 AM' },
        { sender: 'me', text: 'Thanks Aria! Appreciate the feedback. Spent lots of time refining CSS transitions.', time: '10:32 AM' },
        { sender: 'them', text: 'The dark mode palette is crisp. Let’s collaborate on the upcoming component library!', time: '10:35 AM' }
      ]
    },
    {
      id: 'conv2',
      user: 'Marcus Vance',
      handle: '@marcusvance',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
      online: false,
      messages: [
        { sender: 'them', text: 'Did you check out the new Web API specs?', time: 'Yesterday' },
        { sender: 'me', text: 'Yes! Super excited for native CSS container queries.', time: 'Yesterday' }
      ]
    }
  ];

  const PRESET_SAMPLE_IMAGES = [
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=80'
  ];

  // APP STATE
  let state = {
    user: JSON.parse(localStorage.getItem(STORAGE_KEYS.USER)) || DEFAULT_USER,
    posts: JSON.parse(localStorage.getItem(STORAGE_KEYS.POSTS)) || DEFAULT_POSTS,
    theme: localStorage.getItem(STORAGE_KEYS.THEME) || 'dark',
    notifs: JSON.parse(localStorage.getItem(STORAGE_KEYS.NOTIFS)) || DEFAULT_NOTIFICATIONS,
    conversations: JSON.parse(localStorage.getItem(STORAGE_KEYS.CONVERSATIONS)) || DEFAULT_CONVERSATIONS,
    followingUsers: JSON.parse(localStorage.getItem(STORAGE_KEYS.FOLLOWING)) || ['@ariachen', '@marcusvance', '@cyberpulse'],
    currentView: 'home',
    feedType: 'for-you',
    activeChatId: 'conv1',
    profileTab: 'posts',
    commentTargetPostId: null,
    composerImage: ''
  };

  // DOM ELEMENTS CACHE
  const DOM = {};

  function cacheDomElements() {
    DOM.html = document.documentElement;
    DOM.viewSections = document.querySelectorAll('.view-section');
    DOM.navItems = document.querySelectorAll('[data-view]');

    // Composer
    DOM.composerText = document.getElementById('composerText');
    DOM.composerCharCounter = document.getElementById('composerCharCounter');
    DOM.submitPostBtn = document.getElementById('submitPostBtn');
    DOM.addComposerImageBtn = document.getElementById('addComposerImageBtn');
    DOM.composerImagePreview = document.getElementById('composerImagePreview');
    DOM.previewImg = document.getElementById('previewImg');
    DOM.removeMediaBtn = document.getElementById('removeMediaBtn');

    // Feed Stream Container
    DOM.homeFeedStream = document.getElementById('homeFeedStream');
    DOM.explorePostsStream = document.getElementById('explorePostsStream');
    DOM.profilePostsStream = document.getElementById('profilePostsStream');

    // Sidebar Widgets
    DOM.sidebarTrendingList = document.getElementById('sidebarTrendingList');
    DOM.sidebarSuggestedList = document.getElementById('sidebarSuggestedList');
    DOM.exploreTrendingList = document.getElementById('exploreTrendingList');

    // Search
    DOM.globalSearchInput = document.getElementById('globalSearchInput');
    DOM.exploreSearchInput = document.getElementById('exploreSearchInput');
    DOM.globalSearchClear = document.getElementById('globalSearchClear');
    DOM.closeSearchBtn = document.getElementById('closeSearchBtn');
    DOM.searchQueryTitle = document.getElementById('searchQueryTitle');
    DOM.peopleResultsSection = document.getElementById('peopleResultsSection');
    DOM.peopleResultsList = document.getElementById('peopleResultsList');
    DOM.postsResultsStream = document.getElementById('postsResultsStream');

    // Modals
    DOM.createPostModal = document.getElementById('createPostModal');
    DOM.openCreatePostBtn = document.getElementById('openCreatePostBtn');
    DOM.mobileFabBtn = document.getElementById('mobileFabBtn');
    DOM.closeCreatePostModal = document.getElementById('closeCreatePostModal');
    DOM.modalComposerText = document.getElementById('modalComposerText');
    DOM.modalCharCounter = document.getElementById('modalCharCounter');
    DOM.modalSubmitPostBtn = document.getElementById('modalSubmitPostBtn');
    DOM.modalAddImageBtn = document.getElementById('modalAddImageBtn');
    DOM.modalImageInputWrap = document.getElementById('modalImageInputWrap');
    DOM.modalImageUrlInput = document.getElementById('modalImageUrlInput');
    DOM.modalApplyImageBtn = document.getElementById('modalApplyImageBtn');
    DOM.modalImagePreview = document.getElementById('modalImagePreview');
    DOM.modalPreviewImg = document.getElementById('modalPreviewImg');
    DOM.modalRemoveMediaBtn = document.getElementById('modalRemoveMediaBtn');
    DOM.modalPresetImageBtn = document.getElementById('modalPresetImageBtn');

    // Edit Profile Modal
    DOM.editProfileModal = document.getElementById('editProfileModal');
    DOM.editProfileBtn = document.getElementById('editProfileBtn');
    DOM.closeEditProfileModal = document.getElementById('closeEditProfileModal');
    DOM.saveProfileBtn = document.getElementById('saveProfileBtn');
    DOM.editCoverInput = document.getElementById('editCoverInput');
    DOM.editAvatarInput = document.getElementById('editAvatarInput');
    DOM.editNameInput = document.getElementById('editNameInput');
    DOM.editBioInput = document.getElementById('editBioInput');
    DOM.editLocationInput = document.getElementById('editLocationInput');
    DOM.editWebsiteInput = document.getElementById('editWebsiteInput');

    // Comments Modal
    DOM.commentsModal = document.getElementById('commentsModal');
    DOM.closeCommentsModal = document.getElementById('closeCommentsModal');
    DOM.modalTargetPost = document.getElementById('modalTargetPost');
    DOM.modalCommentsList = document.getElementById('modalCommentsList');
    DOM.commentTextInput = document.getElementById('commentTextInput');
    DOM.submitCommentBtn = document.getElementById('submitCommentBtn');

    // Messages / Chat
    DOM.conversationsList = document.getElementById('conversationsList');
    DOM.chatPane = document.getElementById('chatPane');
    DOM.chatEmptyState = document.getElementById('chatEmptyState');
    DOM.chatActiveWrap = document.getElementById('chatActiveWrap');
    DOM.chatHeaderAvatar = document.getElementById('chatHeaderAvatar');
    DOM.chatHeaderName = document.getElementById('chatHeaderName');
    DOM.chatHeaderStatus = document.getElementById('chatHeaderStatus');
    DOM.chatMessagesThread = document.getElementById('chatMessagesThread');
    DOM.chatTextInput = document.getElementById('chatTextInput');
    DOM.sendChatMessageBtn = document.getElementById('sendChatMessageBtn');
    DOM.backToChatsBtn = document.getElementById('backToChatsBtn');

    // Notifications
    DOM.notificationsList = document.getElementById('notificationsList');

    // User Badge Elements
    DOM.sidebarUserAvatar = document.getElementById('sidebarUserAvatar');
    DOM.sidebarUserName = document.getElementById('sidebarUserName');
    DOM.sidebarUserHandle = document.getElementById('sidebarUserHandle');
    DOM.mobileHeaderAvatar = document.getElementById('mobileHeaderAvatar');
    DOM.composerUserAvatar = document.getElementById('composerUserAvatar');
    DOM.modalComposerAvatar = document.getElementById('modalComposerAvatar');

    // Profile Page Elements
    DOM.profileCoverImg = document.getElementById('profileCoverImg');
    DOM.profileAvatarImg = document.getElementById('profileAvatarImg');
    DOM.profileName = document.getElementById('profileName');
    DOM.profileHandle = document.getElementById('profileHandle');
    DOM.profileBio = document.getElementById('profileBio');
    DOM.profileLocation = document.getElementById('profileLocation');
    DOM.profileWebsite = document.getElementById('profileWebsite');
    DOM.profileFollowingCount = document.getElementById('profileFollowingCount');
    DOM.profileFollowersCount = document.getElementById('profileFollowersCount');
    DOM.profilePostCount = document.getElementById('profilePostCount');

    // Theme Switch Cards
    DOM.themeDarkCard = document.getElementById('themeDarkCard');
    DOM.themeLightCard = document.getElementById('themeLightCard');
    DOM.mobileThemeToggleBtn = document.getElementById('mobileThemeToggleBtn');
    DOM.resetDataBtn = document.getElementById('resetDataBtn');
    DOM.toastContainer = document.getElementById('toastContainer');
  }

  // SAVE STATE TO LOCAL STORAGE
  function saveState() {
    localStorage.setItem(STORAGE_KEYS.POSTS, JSON.stringify(state.posts));
    localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(state.user));
    localStorage.setItem(STORAGE_KEYS.THEME, state.theme);
    localStorage.setItem(STORAGE_KEYS.NOTIFS, JSON.stringify(state.notifs));
    localStorage.setItem(STORAGE_KEYS.CONVERSATIONS, JSON.stringify(state.conversations));
    localStorage.setItem(STORAGE_KEYS.FOLLOWING, JSON.stringify(state.followingUsers));
  }

  // TOAST NOTIFICATIONS
  function showToast(message, icon = 'fa-circle-check') {
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `<i class="fa-solid ${icon}"></i> <span>${message}</span>`;
    DOM.toastContainer.appendChild(toast);
    setTimeout(() => {
      if (toast.parentNode) toast.parentNode.removeChild(toast);
    }, 3000);
  }

  // ROUTER & VIEW SWITCHING
  function switchView(viewName) {
    state.currentView = viewName;

    // Update active nav links
    DOM.navItems.forEach(item => {
      if (item.getAttribute('data-view') === viewName) {
        item.classList.add('active');
      } else {
        item.classList.remove('active');
      }
    });

    // Update view sections visibility
    DOM.viewSections.forEach(section => {
      const sectionId = section.id.replace('view', '').toLowerCase();
      if (sectionId === viewName.toLowerCase()) {
        section.classList.remove('hidden');
        section.classList.add('active');
      } else {
        section.classList.add('hidden');
        section.classList.remove('active');
      }
    });

    // Render view contents dynamically
    if (viewName === 'home') renderHomeFeed();
    else if (viewName === 'explore') renderExploreView();
    else if (viewName === 'notifications') renderNotificationsView();
    else if (viewName === 'messages') renderMessagesView();
    else if (viewName === 'profile') renderProfileView();

    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  // THEME MANAGEMENT
  function setTheme(theme) {
    state.theme = theme;
    DOM.html.setAttribute('data-theme', theme);
    localStorage.setItem(STORAGE_KEYS.THEME, theme);

    if (theme === 'dark') {
      DOM.themeDarkCard?.classList.add('active');
      DOM.themeLightCard?.classList.remove('active');
      if (DOM.mobileThemeToggleBtn) DOM.mobileThemeToggleBtn.innerHTML = '<i class="fa-solid fa-sun"></i>';
    } else {
      DOM.themeLightCard?.classList.add('active');
      DOM.themeDarkCard?.classList.remove('active');
      if (DOM.mobileThemeToggleBtn) DOM.mobileThemeToggleBtn.innerHTML = '<i class="fa-solid fa-moon"></i>';
    }
  }

  // USER PROFILE & HEADERS UPDATE
  function updateProfileUI() {
    const u = state.user;
    if (DOM.sidebarUserAvatar) DOM.sidebarUserAvatar.src = u.avatar;
    if (DOM.sidebarUserName) DOM.sidebarUserName.textContent = u.name;
    if (DOM.sidebarUserHandle) DOM.sidebarUserHandle.textContent = u.handle;

    if (DOM.mobileHeaderAvatar) DOM.mobileHeaderAvatar.src = u.avatar;
    if (DOM.composerUserAvatar) DOM.composerUserAvatar.src = u.avatar;
    if (DOM.modalComposerAvatar) DOM.modalComposerAvatar.src = u.avatar;

    if (DOM.profileCoverImg) DOM.profileCoverImg.src = u.cover;
    if (DOM.profileAvatarImg) DOM.profileAvatarImg.src = u.avatar;
    if (DOM.profileName) DOM.profileName.textContent = u.name;
    if (DOM.profileHandle) DOM.profileHandle.textContent = u.handle;
    if (DOM.profileBio) DOM.profileBio.textContent = u.bio;
    if (DOM.profileLocation) DOM.profileLocation.textContent = u.location;
    if (DOM.profileWebsite) {
      DOM.profileWebsite.textContent = u.website.replace('https://', '').replace('http://', '');
      DOM.profileWebsite.href = u.website;
    }
    if (DOM.profileFollowingCount) DOM.profileFollowingCount.textContent = u.followingCount;
    if (DOM.profileFollowersCount) DOM.profileFollowersCount.textContent = u.followersCount;

    const myPostsCount = state.posts.filter(p => p.handle === u.handle).length;
    if (DOM.profilePostCount) DOM.profilePostCount.textContent = myPostsCount;
  }

  // RENDER SINGLE POST CARD HTML
  function createPostCardElement(post) {
    const card = document.createElement('div');
    card.className = 'post-card';
    card.dataset.postId = post.id;

    const isOwnPost = post.handle === state.user.handle;

    card.innerHTML = `
      <div class="post-avatar-wrap">
        <img src="${post.avatar}" alt="${post.author}" class="avatar-md">
      </div>
      <div class="post-main">
        <div class="post-header">
          <div class="post-user-info">
            <span class="post-author-name">${post.author}</span>
            ${post.verified ? '<i class="fa-solid fa-circle-check verified-badge"></i>' : ''}
            <span class="post-author-handle">${post.handle}</span>
            <span class="post-timestamp">· ${post.timestamp}</span>
          </div>
          ${isOwnPost ? `<button class="icon-btn btn-delete-post" title="Delete Zip"><i class="fa-regular fa-trash-can text-danger"></i></button>` : `<button class="icon-btn post-menu-btn"><i class="fa-solid fa-ellipsis"></i></button>`}
        </div>

        <div class="post-text">${escapeHtml(post.text)}</div>

        ${post.image ? `<div class="post-media-grid"><img src="${post.image}" alt="Zip media" loading="lazy"></div>` : ''}

        <div class="post-actions-bar">
          <button class="post-action-btn btn-comment">
            <i class="fa-regular fa-comment"></i>
            <span>${post.commentsCount || 0}</span>
          </button>

          <button class="post-action-btn btn-repost ${post.isReposted ? 'reposted' : ''}">
            <i class="fa-solid fa-repeat"></i>
            <span>${post.reposts || 0}</span>
          </button>

          <button class="post-action-btn btn-like ${post.isLiked ? 'liked' : ''}">
            <i class="${post.isLiked ? 'fa-solid' : 'fa-regular'} fa-heart"></i>
            <span>${post.likes || 0}</span>
          </button>

          <button class="post-action-btn btn-share" title="Share Zip">
            <i class="fa-regular fa-paper-plane"></i>
          </button>
        </div>
      </div>
    `;

    // Event Listeners for Post Actions
    const likeBtn = card.querySelector('.btn-like');
    likeBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      saveState();

      likeBtn.classList.toggle('liked', post.isLiked);
      const heartIcon = likeBtn.querySelector('i');
      heartIcon.className = `${post.isLiked ? 'fa-solid' : 'fa-regular'} fa-heart like-pop`;
      likeBtn.querySelector('span').textContent = post.likes;

      setTimeout(() => heartIcon.classList.remove('like-pop'), 400);
    });

    const repostBtn = card.querySelector('.btn-repost');
    repostBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      post.isReposted = !post.isReposted;
      post.reposts += post.isReposted ? 1 : -1;
      saveState();

      repostBtn.classList.toggle('reposted', post.isReposted);
      repostBtn.querySelector('span').textContent = post.reposts;
      showToast(post.isReposted ? 'Zip reposted to your profile!' : 'Repost removed');
    });

    const commentBtn = card.querySelector('.btn-comment');
    commentBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      openCommentsModal(post.id);
    });

    const shareBtn = card.querySelector('.btn-share');
    shareBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      showToast('Zip link copied to clipboard!', 'fa-link');
    });

    if (isOwnPost) {
      const deleteBtn = card.querySelector('.btn-delete-post');
      deleteBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        if (confirm('Are you sure you want to delete this Zip post?')) {
          state.posts = state.posts.filter(p => p.id !== post.id);
          saveState();
          showToast('Zip post deleted');
          renderHomeFeed();
          if (state.currentView === 'profile') renderProfileView();
        }
      });
    }

    return card;
  }

  // RENDER HOME FEED
  function renderHomeFeed() {
    if (!DOM.homeFeedStream) return;
    DOM.homeFeedStream.innerHTML = '';

    let postsToDisplay = [...state.posts];

    if (state.feedType === 'following') {
      postsToDisplay = postsToDisplay.filter(p => state.followingUsers.includes(p.handle) || p.handle === state.user.handle);
    }

    if (postsToDisplay.length === 0) {
      DOM.homeFeedStream.innerHTML = `
        <div class="empty-state">
          <i class="fa-solid fa-wind empty-state-icon"></i>
          <h3>No Zips Yet</h3>
          <p>Follow users or publish your first Zip post to see content here!</p>
        </div>
      `;
      return;
    }

    postsToDisplay.forEach(post => {
      DOM.homeFeedStream.appendChild(createPostCardElement(post));
    });
  }

  // RENDER EXPLORE VIEW
  function renderExploreView() {
    if (DOM.exploreTrendingList) {
      DOM.exploreTrendingList.innerHTML = '';
      DEFAULT_TRENDS.forEach(t => {
        const item = document.createElement('div');
        item.className = 'trending-item';
        item.innerHTML = `
          <div>
            <div class="trend-category">${t.category}</div>
            <div class="trend-topic">${t.topic}</div>
            <div class="trend-count">${t.postsCount}</div>
          </div>
          <i class="fa-solid fa-ellipsis text-subtle"></i>
        `;
        item.addEventListener('click', () => handleSearch(t.topic));
        DOM.exploreTrendingList.appendChild(item);
      });
    }

    if (DOM.explorePostsStream) {
      DOM.explorePostsStream.innerHTML = '';
      state.posts.slice(0, 4).forEach(post => {
        DOM.explorePostsStream.appendChild(createPostCardElement(post));
      });
    }
  }

  // RENDER NOTIFICATIONS
  function renderNotificationsView() {
    if (!DOM.notificationsList) return;
    DOM.notificationsList.innerHTML = '';

    if (state.notifs.length === 0) {
      DOM.notificationsList.innerHTML = `
        <div class="empty-state">
          <i class="fa-regular fa-bell empty-state-icon"></i>
          <h3>No Notifications</h3>
          <p>You're all caught up!</p>
        </div>
      `;
      return;
    }

    state.notifs.forEach(n => {
      const card = document.createElement('div');
      card.className = `notification-card ${n.unread ? 'unread' : ''}`;

      let iconClass = 'fa-heart like';
      if (n.type === 'repost') iconClass = 'fa-repeat repost';
      else if (n.type === 'follow') iconClass = 'fa-user-plus follow';
      else if (n.type === 'comment') iconClass = 'fa-comment comment';

      card.innerHTML = `
        <div class="notif-type-icon ${n.type}">
          <i class="fa-solid ${iconClass}"></i>
        </div>
        <div class="notif-body">
          <div class="notif-user-row">
            <img src="${n.avatar}" alt="${n.user}" class="avatar-sm">
            <span class="notif-text"><strong>${n.user}</strong> ${n.text}</span>
          </div>
          ${n.snippet ? `<div class="notif-snippet">${escapeHtml(n.snippet)}</div>` : ''}
          <div class="notif-time">${n.timestamp}</div>
        </div>
      `;
      DOM.notificationsList.appendChild(card);
    });
  }

  // RENDER MESSAGES / CHAT VIEW
  function renderMessagesView() {
    if (!DOM.conversationsList) return;
    DOM.conversationsList.innerHTML = '';

    state.conversations.forEach(conv => {
      const item = document.createElement('div');
      item.className = `conversation-item ${conv.id === state.activeChatId ? 'active' : ''}`;
      const lastMsg = conv.messages[conv.messages.length - 1];

      item.innerHTML = `
        <img src="${conv.avatar}" alt="${conv.user}" class="avatar-md">
        <div class="conv-info">
          <div class="conv-top">
            <span class="conv-name">${conv.user}</span>
            <span class="conv-time">${lastMsg ? lastMsg.time : ''}</span>
          </div>
          <div class="conv-last-msg">${lastMsg ? escapeHtml(lastMsg.text) : 'Start conversation...'}</div>
        </div>
      `;

      item.addEventListener('click', () => {
        state.activeChatId = conv.id;
        renderMessagesView();
        openChatThread(conv);
      });

      DOM.conversationsList.appendChild(item);
    });

    const activeConv = state.conversations.find(c => c.id === state.activeChatId);
    if (activeConv) openChatThread(activeConv);
  }

  function openChatThread(conv) {
    if (window.innerWidth < 768) {
      DOM.chatPane?.classList.remove('hidden-mobile');
    }

    DOM.chatEmptyState?.classList.add('hidden');
    DOM.chatActiveWrap?.classList.remove('hidden');

    if (DOM.chatHeaderAvatar) DOM.chatHeaderAvatar.src = conv.avatar;
    if (DOM.chatHeaderName) DOM.chatHeaderName.textContent = conv.user;
    if (DOM.chatHeaderStatus) {
      DOM.chatHeaderStatus.textContent = conv.online ? 'Online' : 'Offline';
      DOM.chatHeaderStatus.style.color = conv.online ? 'var(--color-success)' : 'var(--text-subtle)';
    }

    renderChatThreadMessages(conv);
  }

  function renderChatThreadMessages(conv) {
    if (!DOM.chatMessagesThread) return;
    DOM.chatMessagesThread.innerHTML = '';

    conv.messages.forEach(msg => {
      const bubble = document.createElement('div');
      bubble.className = `message-bubble ${msg.sender === 'me' ? 'outgoing' : 'incoming'}`;
      bubble.innerHTML = `
        <div class="message-text">${escapeHtml(msg.text)}</div>
        <div class="message-time">${msg.time}</div>
      `;
      DOM.chatMessagesThread.appendChild(bubble);
    });

    DOM.chatMessagesThread.scrollTop = DOM.chatMessagesThread.scrollHeight;
  }

  function sendChatMessage() {
    const text = DOM.chatTextInput.value.trim();
    if (!text) return;

    const conv = state.conversations.find(c => c.id === state.activeChatId);
    if (!conv) return;

    const timeStr = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    conv.messages.push({ sender: 'me', text, time: timeStr });

    DOM.chatTextInput.value = '';
    saveState();
    renderChatThreadMessages(conv);

    // Auto-reply simulation
    setTimeout(() => {
      const replies = [
        "That's awesome! Let's build it out.",
        "Got it! Thanks for letting me know.",
        "Zipgram is super fast!",
        "Catch you later!"
      ];
      const randomReply = replies[Math.floor(Math.random() * replies.length)];
      conv.messages.push({ sender: 'them', text: randomReply, time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) });
      saveState();
      renderChatThreadMessages(conv);
    }, 1200);
  }

  // RENDER PROFILE VIEW
  function renderProfileView() {
    updateProfileUI();
    if (!DOM.profilePostsStream) return;
    DOM.profilePostsStream.innerHTML = '';

    let userPosts = state.posts.filter(p => p.handle === state.user.handle);

    if (state.profileTab === 'likes') {
      userPosts = state.posts.filter(p => p.isLiked);
    } else if (state.profileTab === 'media') {
      userPosts = userPosts.filter(p => p.image);
    }

    if (userPosts.length === 0) {
      DOM.profilePostsStream.innerHTML = `
        <div class="empty-state">
          <i class="fa-regular fa-folder-open empty-state-icon"></i>
          <h3>No Zips in ${state.profileTab}</h3>
          <p>Published content will appear here.</p>
        </div>
      `;
      return;
    }

    userPosts.forEach(post => {
      DOM.profilePostsStream.appendChild(createPostCardElement(post));
    });
  }

  // SIDEBAR WIDGETS
  function renderSidebarWidgets() {
    if (DOM.sidebarTrendingList) {
      DOM.sidebarTrendingList.innerHTML = '';
      DEFAULT_TRENDS.slice(0, 3).forEach(t => {
        const item = document.createElement('div');
        item.className = 'trending-item';
        item.innerHTML = `
          <div>
            <div class="trend-category">${t.category}</div>
            <div class="trend-topic">${t.topic}</div>
            <div class="trend-count">${t.postsCount}</div>
          </div>
        `;
        item.addEventListener('click', () => handleSearch(t.topic));
        DOM.sidebarTrendingList.appendChild(item);
      });
    }

    if (DOM.sidebarSuggestedList) {
      DOM.sidebarSuggestedList.innerHTML = '';
      DEFAULT_SUGGESTED.forEach(s => {
        const isFollowing = state.followingUsers.includes(s.handle);
        const item = document.createElement('div');
        item.className = 'widget-user-item';
        item.innerHTML = `
          <div class="widget-user-info">
            <img src="${s.avatar}" alt="${s.name}" class="avatar-sm">
            <div class="widget-user-text">
              <span class="widget-user-name">${s.name}</span>
              <span class="widget-user-handle">${s.handle}</span>
            </div>
          </div>
          <button class="btn ${isFollowing ? 'btn-secondary' : 'btn-primary'} btn-sm btn-follow">${isFollowing ? 'Following' : 'Follow'}</button>
        `;

        const followBtn = item.querySelector('.btn-follow');
        followBtn.addEventListener('click', () => {
          if (state.followingUsers.includes(s.handle)) {
            state.followingUsers = state.followingUsers.filter(h => h !== s.handle);
            followBtn.className = 'btn btn-primary btn-sm btn-follow';
            followBtn.textContent = 'Follow';
            showToast(`Unfollowed ${s.handle}`);
          } else {
            state.followingUsers.push(s.handle);
            followBtn.className = 'btn btn-secondary btn-sm btn-follow';
            followBtn.textContent = 'Following';
            showToast(`Started following ${s.handle}!`);
          }
          saveState();
        });

        DOM.sidebarSuggestedList.appendChild(item);
      });
    }
  }

  // SEARCH FUNCTIONALITY
  function handleSearch(query) {
    if (!query || !query.trim()) return;
    const term = query.trim().toLowerCase();

    DOM.searchQueryTitle.textContent = `"${query}"`;
    switchView('search');

    const matchingPosts = state.posts.filter(p => p.text.toLowerCase().includes(term) || p.author.toLowerCase().includes(term) || p.handle.toLowerCase().includes(term));
    const matchingUsers = DEFAULT_SUGGESTED.filter(s => s.name.toLowerCase().includes(term) || s.handle.toLowerCase().includes(term));

    if (DOM.peopleResultsSection) {
      if (matchingUsers.length > 0) {
        DOM.peopleResultsSection.classList.remove('hidden');
        DOM.peopleResultsList.innerHTML = '';
        matchingUsers.forEach(u => {
          const item = document.createElement('div');
          item.className = 'widget-user-item';
          item.style.padding = '10px 0';
          item.innerHTML = `
            <div class="widget-user-info">
              <img src="${u.avatar}" alt="${u.name}" class="avatar-md">
              <div class="widget-user-text">
                <span class="widget-user-name">${u.name}</span>
                <span class="widget-user-handle">${u.handle}</span>
              </div>
            </div>
            <button class="btn btn-primary btn-sm">Follow</button>
          `;
          DOM.peopleResultsList.appendChild(item);
        });
      } else {
        DOM.peopleResultsSection.classList.add('hidden');
      }
    }

    if (DOM.postsResultsStream) {
      DOM.postsResultsStream.innerHTML = '';
      if (matchingPosts.length === 0) {
        DOM.postsResultsStream.innerHTML = `
          <div class="empty-state">
            <i class="fa-solid fa-magnifying-glass empty-state-icon"></i>
            <h3>No results found</h3>
            <p>Try searching for another keyword or username.</p>
          </div>
        `;
      } else {
        matchingPosts.forEach(p => {
          DOM.postsResultsStream.appendChild(createPostCardElement(p));
        });
      }
    }
  }

  // POST CREATION LOGIC
  function createNewPost(text, imageUrl = '') {
    if (!text.trim()) return;

    const newPost = {
      id: 'p_' + Date.now(),
      author: state.user.name,
      handle: state.user.handle,
      avatar: state.user.avatar,
      verified: true,
      text: text.trim(),
      image: imageUrl,
      timestamp: 'Just now',
      likes: 0,
      reposts: 0,
      commentsCount: 0,
      isLiked: false,
      isReposted: false,
      comments: []
    };

    state.posts.unshift(newPost);
    saveState();
    showToast('Your Zip has been posted!', 'fa-bolt-lightning');

    if (state.currentView === 'home') renderHomeFeed();
    else switchView('home');
  }

  // COMMENTS MODAL LOGIC
  function openCommentsModal(postId) {
    state.commentTargetPostId = postId;
    const post = state.posts.find(p => p.id === postId);
    if (!post) return;

    DOM.modalTargetPost.innerHTML = '';
    DOM.modalTargetPost.appendChild(createPostCardElement(post));

    renderModalCommentsList(post);
    DOM.commentsModal.classList.remove('hidden');
  }

  function renderModalCommentsList(post) {
    DOM.modalCommentsList.innerHTML = '';
    if (!post.comments || post.comments.length === 0) {
      DOM.modalCommentsList.innerHTML = `<p class="text-subtle text-center py-3">No comments yet. Be the first to reply!</p>`;
      return;
    }

    post.comments.forEach(c => {
      const item = document.createElement('div');
      item.className = 'comment-item';
      item.innerHTML = `
        <div>
          <div class="comment-author">${escapeHtml(c.author)} <span class="text-subtle">· ${c.timestamp}</span></div>
          <div class="comment-text">${escapeHtml(c.text)}</div>
        </div>
      `;
      DOM.modalCommentsList.appendChild(item);
    });
  }

  function submitComment() {
    const text = DOM.commentTextInput.value.trim();
    if (!text || !state.commentTargetPostId) return;

    const post = state.posts.find(p => p.id === state.commentTargetPostId);
    if (!post) return;

    if (!post.comments) post.comments = [];
    post.comments.push({
      id: 'c_' + Date.now(),
      author: state.user.name,
      text,
      timestamp: 'Just now'
    });

    post.commentsCount = post.comments.length;
    saveState();

    DOM.commentTextInput.value = '';
    renderModalCommentsList(post);
    renderHomeFeed();
    showToast('Reply published!');
  }

  // HELPER UTIL: ESCAPE HTML
  function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/[&<>"']/g, function (m) {
      return {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
      }[m];
    });
  }

  // BIND ALL EVENT LISTENERS
  function setupEventListeners() {
    // Navigation Routing
    DOM.navItems.forEach(item => {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        const view = item.getAttribute('data-view');
        if (view) switchView(view);
      });
    });

    // Mobile Header User Button -> Profile
    document.getElementById('mobileHeaderUserBtn')?.addEventListener('click', () => switchView('profile'));
    document.getElementById('mobileThemeToggleBtn')?.addEventListener('click', () => {
      setTheme(state.theme === 'dark' ? 'light' : 'dark');
    });

    // Feed Tabs (For You / Following)
    document.querySelectorAll('.feed-tab').forEach(tab => {
      tab.addEventListener('click', () => {
        document.querySelectorAll('.feed-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        state.feedType = tab.getAttribute('data-feed-type');
        renderHomeFeed();
      });
    });

    // Profile Tabs
    document.querySelectorAll('.prof-tab').forEach(tab => {
      tab.addEventListener('click', () => {
        document.querySelectorAll('.prof-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        state.profileTab = tab.getAttribute('data-prof-tab');
        renderProfileView();
      });
    });

    // Inline Composer Character Count & Submit
    DOM.composerText?.addEventListener('input', () => {
      const len = DOM.composerText.value.length;
      DOM.composerCharCounter.textContent = 280 - len;
      DOM.submitPostBtn.disabled = len === 0;
    });

    DOM.submitPostBtn?.addEventListener('click', () => {
      createNewPost(DOM.composerText.value, state.composerImage);
      DOM.composerText.value = '';
      DOM.composerCharCounter.textContent = 280;
      DOM.submitPostBtn.disabled = true;
      state.composerImage = '';
      DOM.composerImagePreview.classList.add('hidden');
    });

    DOM.addComposerImageBtn?.addEventListener('click', () => {
      const url = prompt('Enter image URL for attachment:', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80');
      if (url) {
        state.composerImage = url;
        DOM.previewImg.src = url;
        DOM.composerImagePreview.classList.remove('hidden');
      }
    });

    DOM.removeMediaBtn?.addEventListener('click', () => {
      state.composerImage = '';
      DOM.composerImagePreview.classList.add('hidden');
    });

    // Create Post Modal Controls
    const openModalHandler = () => {
      DOM.createPostModal.classList.remove('hidden');
      DOM.modalComposerText.focus();
    };

    DOM.openCreatePostBtn?.addEventListener('click', openModalHandler);
    DOM.mobileFabBtn?.addEventListener('click', openModalHandler);
    DOM.closeCreatePostModal?.addEventListener('click', () => DOM.createPostModal.classList.add('hidden'));

    DOM.modalComposerText?.addEventListener('input', () => {
      const len = DOM.modalComposerText.value.length;
      DOM.modalCharCounter.textContent = 280 - len;
      DOM.modalSubmitPostBtn.disabled = len === 0;
    });

    DOM.modalAddImageBtn?.addEventListener('click', () => {
      DOM.modalImageInputWrap.classList.toggle('hidden');
    });

    DOM.modalApplyImageBtn?.addEventListener('click', () => {
      const url = DOM.modalImageUrlInput.value.trim();
      if (url) {
        state.composerImage = url;
        DOM.modalPreviewImg.src = url;
        DOM.modalImagePreview.classList.remove('hidden');
        DOM.modalImageInputWrap.classList.add('hidden');
      }
    });

    DOM.modalRemoveMediaBtn?.addEventListener('click', () => {
      state.composerImage = '';
      DOM.modalImagePreview.classList.add('hidden');
    });

    DOM.modalPresetImageBtn?.addEventListener('click', () => {
      const randomImg = PRESET_SAMPLE_IMAGES[Math.floor(Math.random() * PRESET_SAMPLE_IMAGES.length)];
      state.composerImage = randomImg;
      DOM.modalPreviewImg.src = randomImg;
      DOM.modalImagePreview.classList.remove('hidden');
      showToast('Sample image attached!');
    });

    DOM.modalSubmitPostBtn?.addEventListener('click', () => {
      createNewPost(DOM.modalComposerText.value, state.composerImage);
      DOM.modalComposerText.value = '';
      DOM.modalCharCounter.textContent = 280;
      DOM.modalSubmitPostBtn.disabled = true;
      state.composerImage = '';
      DOM.modalImagePreview.classList.add('hidden');
      DOM.createPostModal.classList.add('hidden');
    });

    // Edit Profile Modal Controls
    DOM.editProfileBtn?.addEventListener('click', () => {
      DOM.editCoverInput.value = state.user.cover;
      DOM.editAvatarInput.value = state.user.avatar;
      DOM.editNameInput.value = state.user.name;
      DOM.editBioInput.value = state.user.bio;
      DOM.editLocationInput.value = state.user.location;
      DOM.editWebsiteInput.value = state.user.website;
      DOM.editProfileModal.classList.remove('hidden');
    });

    DOM.closeEditProfileModal?.addEventListener('click', () => DOM.editProfileModal.classList.add('hidden'));

    DOM.saveProfileBtn?.addEventListener('click', () => {
      state.user.cover = DOM.editCoverInput.value || state.user.cover;
      state.user.avatar = DOM.editAvatarInput.value || state.user.avatar;
      state.user.name = DOM.editNameInput.value || state.user.name;
      state.user.bio = DOM.editBioInput.value;
      state.user.location = DOM.editLocationInput.value;
      state.user.website = DOM.editWebsiteInput.value;

      saveState();
      updateProfileUI();
      DOM.editProfileModal.classList.add('hidden');
      showToast('Profile updated successfully!');
    });

    // Comments Modal
    DOM.closeCommentsModal?.addEventListener('click', () => DOM.commentsModal.classList.add('hidden'));
    DOM.submitCommentBtn?.addEventListener('click', submitComment);

    // Messaging
    DOM.sendChatMessageBtn?.addEventListener('click', sendChatMessage);
    DOM.chatTextInput?.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') sendChatMessage();
    });

    DOM.backToChatsBtn?.addEventListener('click', () => {
      DOM.chatPane?.classList.add('hidden-mobile');
    });

    // Global & Explore Search Inputs
    const onSearchKeyDown = (e) => {
      if (e.key === 'Enter') {
        handleSearch(e.target.value);
      }
    };

    DOM.globalSearchInput?.addEventListener('keydown', onSearchKeyDown);
    DOM.exploreSearchInput?.addEventListener('keydown', onSearchKeyDown);
    DOM.closeSearchBtn?.addEventListener('click', () => switchView('home'));

    // Theme Switch Cards in Settings
    DOM.themeDarkCard?.addEventListener('click', () => setTheme('dark'));
    DOM.themeLightCard?.addEventListener('click', () => setTheme('light'));

    // Reset Data Button
    DOM.resetDataBtn?.addEventListener('click', () => {
      if (confirm('Reset Zipgram data back to default demo state?')) {
        localStorage.clear();
        state.posts = DEFAULT_POSTS;
        state.user = DEFAULT_USER;
        state.theme = 'dark';
        state.notifs = DEFAULT_NOTIFICATIONS;
        state.conversations = DEFAULT_CONVERSATIONS;
        saveState();
        setTheme('dark');
        updateProfileUI();
        switchView('home');
        showToast('Demo data reset successfully');
      }
    });

    // Refresh Feed Button
    document.getElementById('refreshFeedBtn')?.addEventListener('click', () => {
      renderHomeFeed();
      showToast('Feed refreshed', 'fa-rotate-right');
    });
  }

  // INIT APPLICATION
  function init() {
    cacheDomElements();
    setTheme(state.theme);
    updateProfileUI();
    renderSidebarWidgets();
    setupEventListeners();

    // Default View Initialization
    switchView('home');
  }

  document.addEventListener('DOMContentLoaded', init);
})();
