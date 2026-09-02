/**
 * MSAI Chat View Controller
 */
window.MSAI = window.MSAI || {};

window.MSAI.Chat = {
  showHero() {
    const hero = document.getElementById('chat-hero');
    const list = document.getElementById('messages-list');
    if (hero) hero.style.display = 'flex';
    if (list) list.innerHTML = '';
  },

  hideHero() {
    const hero = document.getElementById('chat-hero');
    if (hero) hero.style.display = 'none';
  },

  loadConversation(id) {
    window.MSAI.State.setActiveConversation(id);
    const conv = window.MSAI.State.getActiveConversation();
    if (!conv) {
      this.showHero();
      return;
    }

    this.hideHero();
    this.renderMessages(conv.messages);
    window.MSAI.History.render();
  },

  renderMessages(messages) {
    const list = document.getElementById('messages-list');
    if (!list) return;

    list.innerHTML = '';
    messages.forEach(msg => {
      list.appendChild(window.MSAI.Messages.createMessageNode(msg));
    });

    const container = document.getElementById('chat-container');
    if (container) container.scrollTop = container.scrollHeight;
  },

  async handleUserMessage(content) {
    let conv = window.MSAI.State.getActiveConversation();
    if (!conv) {
      conv = {
        id: 'conv_' + Date.now(),
        title: content.substring(0, 30) + '...',
        messages: [],
        createdAt: new Date().toISOString()
      };
      window.MSAI.State.conversations.unshift(conv);
      window.MSAI.State.setActiveConversation(conv.id);
    } else if (conv.messages.length === 0) {
      conv.title = content.substring(0, 30) + '...';
    }

    this.hideHero();

    const userMsg = {
      id: 'msg_' + Date.now(),
      sender: 'user',
      content: content,
      timestamp: new Date().toISOString()
    };

    conv.messages.push(userMsg);
    window.MSAI.State.saveConversations();
    this.renderMessages(conv.messages);

    // Show AI typing indicator
    const list = document.getElementById('messages-list');
    const typingNode = window.MSAI.Messages.createTypingNode();
    list.appendChild(typingNode);

    const container = document.getElementById('chat-container');
    if (container) container.scrollTop = container.scrollHeight;

    // Send to API
    try {
      const responseText = await window.MSAI.API.sendMessage(content, window.MSAI.State.currentModel);
      typingNode.remove();

      const aiMsg = {
        id: 'msg_' + (Date.now() + 1),
        sender: 'ai',
        content: responseText,
        timestamp: new Date().toISOString()
      };

      conv.messages.push(aiMsg);
      window.MSAI.State.saveConversations();
      this.renderMessages(conv.messages);
    } catch (err) {
      typingNode.remove();
      window.MSAI.Notifications.show('Error generating response');
    }
  }
};
