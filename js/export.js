/**
 * Export Conversations Module (JSON & Markdown)
 */
import { conversations } from './conversations.js';

export function exportConversationsJSON() {
  const allChats = conversations.getAll();
  const exportPayload = {
    app: 'MSAI',
    version: '1.0.0',
    exportedAt: new Date().toISOString(),
    conversations: allChats
  };

  const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(exportPayload, null, 2));
  const downloadAnchor = document.createElement('a');
  downloadAnchor.setAttribute('href', dataStr);
  downloadAnchor.setAttribute('download', `msai-conversations-${Date.now()}.json`);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  document.body.removeChild(downloadAnchor);
}

export function exportActiveChatMarkdown() {
  const activeChat = conversations.getActive();
  if (!activeChat) return;

  let md = `# ${activeChat.title}\n\n`;
  md += `*Exported from MSAI on ${new Date().toLocaleString()}*\n\n---\n\n`;

  activeChat.messages.forEach(msg => {
    const role = msg.role === 'user' ? '### User' : '### MSAI';
    md += `${role}\n\n${msg.content}\n\n---\n\n`;
  });

  const dataStr = 'data:text/markdown;charset=utf-8,' + encodeURIComponent(md);
  const downloadAnchor = document.createElement('a');
  downloadAnchor.setAttribute('href', dataStr);
  downloadAnchor.setAttribute('download', `${activeChat.title.replace(/[^a-z0-9]/gi, '_').toLowerCase()}.md`);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  document.body.removeChild(downloadAnchor);
}
