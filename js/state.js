/**
 * MSAI Application State Store
 */
window.MSAI = window.MSAI || {};

window.MSAI.State = {
  activeConversationId: null,
  conversations: [],
  currentModel: 'msai-flash',
  savedPrompts: [],
  serverOnline: false,

  init() {
    this.conversations = window.MSAI.Storage.get('msai_conversations_v1') || [];
    this.activeConversationId = window.MSAI.Storage.get('msai_active_conv_id_v1') || null;
    this.savedPrompts = window.MSAI.Storage.get('msai_saved_prompts_v1') || [];
  },

  saveConversations() {
    window.MSAI.Storage.set('msai_conversations_v1', this.conversations);
  },

  setActiveConversation(id) {
    this.activeConversationId = id;
    window.MSAI.Storage.set('msai_active_conv_id_v1', id);
  },

  getActiveConversation() {
    return this.conversations.find(c => c.id === this.activeConversationId);
  }
};
