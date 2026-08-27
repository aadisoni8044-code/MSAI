import React, { useState } from 'react';
import {
  X,
  Sliders,
  MessageSquare,
  Cpu,
  Info,
  Trash2
} from 'lucide-react';
import { Settings } from '../types/chat';
import config from '../data/config.json';

interface SettingsProps {
  settings: Settings;
  onSaveSettings: (newSettings: Settings) => void;
  onClearAllConversations: () => void;
  onClose: () => void;
}

export const SettingsModal: React.FC<SettingsProps> = ({
  settings,
  onSaveSettings,
  onClearAllConversations,
  onClose,
}) => {
  const [activeTab, setActiveTab] = useState<'general' | 'chat' | 'ai' | 'about'>('general');
  const [localSettings, setLocalSettings] = useState<Settings>(settings);

  const handleChange = <K extends keyof Settings>(key: K, value: Settings[K]) => {
    const updated = { ...localSettings, [key]: value };
    setLocalSettings(updated);
    onSaveSettings(updated);
  };

  const handleClearHistory = () => {
    if (window.confirm('Are you sure you want to clear all conversation history? This action cannot be undone.')) {
      onClearAllConversations();
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-container" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2 className="modal-title">Settings</h2>
          <button className="icon-button" onClick={onClose}>
            <X size={18} />
          </button>
        </div>

        <div className="modal-body">
          <div className="settings-tabs">
            <button
              className={`tab-btn ${activeTab === 'general' ? 'active' : ''}`}
              onClick={() => setActiveTab('general')}
            >
              <Sliders size={16} />
              <span>General</span>
            </button>
            <button
              className={`tab-btn ${activeTab === 'chat' ? 'active' : ''}`}
              onClick={() => setActiveTab('chat')}
            >
              <MessageSquare size={16} />
              <span>Chat</span>
            </button>
            <button
              className={`tab-btn ${activeTab === 'ai' ? 'active' : ''}`}
              onClick={() => setActiveTab('ai')}
            >
              <Cpu size={16} />
              <span>AI Engine</span>
            </button>
            <button
              className={`tab-btn ${activeTab === 'about' ? 'active' : ''}`}
              onClick={() => setActiveTab('about')}
            >
              <Info size={16} />
              <span>About</span>
            </button>
          </div>

          <div className="settings-content">
            {activeTab === 'general' && (
              <>
                <div className="setting-group">
                  <label className="setting-label">Theme</label>
                  <span className="setting-desc">Select visual application theme</span>
                  <div className="setting-control">
                    <select
                      className="setting-select"
                      value={localSettings.theme}
                      onChange={(e) => handleChange('theme', e.target.value as any)}
                    >
                      <option value="dark">Dark Theme (Default)</option>
                      <option value="light">Light Theme</option>
                      <option value="system">System Preference</option>
                    </select>
                  </div>
                </div>

                <div className="setting-group">
                  <label className="setting-label">Language</label>
                  <span className="setting-desc">Primary assistant response language</span>
                  <div className="setting-control">
                    <select
                      className="setting-select"
                      value={localSettings.language}
                      onChange={(e) => handleChange('language', e.target.value)}
                    >
                      <option value="en">English</option>
                      <option value="es">Spanish</option>
                      <option value="fr">French</option>
                      <option value="de">German</option>
                    </select>
                  </div>
                </div>

                <div className="setting-group">
                  <div className="setting-toggle">
                    <div>
                      <div className="setting-label">Enter to Send</div>
                      <div className="setting-desc">Press Enter to send message, Shift+Enter for new line</div>
                    </div>
                    <input
                      type="checkbox"
                      className="toggle-checkbox"
                      checked={localSettings.enterToSend}
                      onChange={(e) => handleChange('enterToSend', e.target.checked)}
                    />
                  </div>
                </div>
              </>
            )}

            {activeTab === 'chat' && (
              <>
                <div className="setting-group">
                  <label className="setting-label">Clear All Conversations</label>
                  <span className="setting-desc">Permanently delete all chat history stored locally</span>
                  <div className="setting-control" style={{ marginTop: 10 }}>
                    <button
                      className="btn-new-chat"
                      onClick={handleClearHistory}
                      style={{
                        backgroundColor: 'rgba(239, 68, 68, 0.1)',
                        borderColor: 'rgba(239, 68, 68, 0.4)',
                        color: '#ef4444',
                        margin: 0,
                      }}
                    >
                      <Trash2 size={16} />
                      <span>Clear Conversations</span>
                    </button>
                  </div>
                </div>
              </>
            )}

            {activeTab === 'ai' && (
              <>
                <div className="setting-group">
                  <label className="setting-label">Default Model</label>
                  <span className="setting-desc">Select the default Google Gemini model for new chats</span>
                  <div className="setting-control">
                    <select
                      className="setting-select"
                      value={localSettings.model}
                      onChange={(e) => handleChange('model', e.target.value)}
                    >
                      {config.models.map((m) => (
                        <option key={m.id} value={m.id}>
                          {m.name} — {m.description}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="setting-group">
                  <label className="setting-label">System Instructions</label>
                  <span className="setting-desc">Custom behavior instructions for MSAI</span>
                  <div className="setting-control">
                    <textarea
                      className="setting-input"
                      rows={4}
                      value={localSettings.systemPrompt}
                      onChange={(e) => handleChange('systemPrompt', e.target.value)}
                    />
                  </div>
                </div>
              </>
            )}

            {activeTab === 'about' && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <div className="brand-icon" style={{ width: 42, height: 42, fontSize: '1.4rem' }}>
                    M
                  </div>
                  <div>
                    <h3 style={{ fontSize: '1.2rem', fontWeight: 700 }}>{config.appName}</h3>
                    <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                      Version {config.version}
                    </p>
                  </div>
                </div>

                <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  MSAI is a high-performance modern AI chat web application powered by Google Gemini API. It features a sleek dark mode identity, markdown rendering, syntax highlighting, code block management, and responsive layout across desktop and mobile devices.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
