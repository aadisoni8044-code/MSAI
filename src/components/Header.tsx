import React, { useState, useRef, useEffect } from 'react';
import {
  ChevronDown,
  Menu,
  Settings as SettingsIcon,
  Check,
  PanelLeft
} from 'lucide-react';
import config from '../data/config.json';
import { ModelOption } from '../types/chat';

interface HeaderProps {
  selectedModel: string;
  onSelectModel: (modelId: string) => void;
  serverStatus: { status: string; hasApiKey: boolean };
  sidebarCollapsed: boolean;
  onToggleSidebar: () => void;
  onOpenMobileSidebar: () => void;
  onOpenSettings: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  selectedModel,
  onSelectModel,
  serverStatus,
  sidebarCollapsed,
  onToggleSidebar,
  onOpenMobileSidebar,
  onOpenSettings,
}) => {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const models: ModelOption[] = config.models;
  const currentModelObj = models.find((m) => m.id === selectedModel) || models[0];

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setDropdownOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const isOnline = serverStatus.status === 'online';

  return (
    <header className="header">
      <div className="header-left">
        {sidebarCollapsed && (
          <button
            className="icon-button"
            title="Expand Sidebar"
            onClick={onToggleSidebar}
          >
            <PanelLeft size={18} />
          </button>
        )}

        <button
          className="icon-button mobile-only"
          title="Open Menu"
          onClick={onOpenMobileSidebar}
          style={{ display: 'none' }}
        >
          <Menu size={18} />
        </button>

        <div className="model-selector" ref={dropdownRef}>
          <button
            className="model-selector-btn"
            onClick={() => setDropdownOpen(!dropdownOpen)}
          >
            <span>{currentModelObj.name}</span>
            <ChevronDown size={14} />
          </button>

          {dropdownOpen && (
            <div className="model-dropdown">
              {models.map((m) => (
                <div
                  key={m.id}
                  className={`model-option ${
                    m.id === selectedModel ? 'selected' : ''
                  }`}
                  onClick={() => {
                    onSelectModel(m.id);
                    setDropdownOpen(false);
                  }}
                >
                  <div className="model-option-header">
                    <span className="model-option-name">{m.name}</span>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                      {m.badge && (
                        <span className="model-badge">{m.badge}</span>
                      )}
                      {m.id === selectedModel && <Check size={14} color="#6366f1" />}
                    </div>
                  </div>
                  <p className="model-option-desc">{m.description}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="header-right">
        <div
          className={`server-status-badge ${isOnline ? 'online' : 'offline'}`}
          title={
            isOnline
              ? serverStatus.hasApiKey
                ? 'Server online and Gemini API connected'
                : 'Server online (API Key missing)'
              : 'Backend server offline'
          }
        >
          <span className="status-dot" />
          <span>{isOnline ? (serverStatus.hasApiKey ? 'Server Online' : 'Key Missing') : 'Server Offline'}</span>
        </div>

        <button
          className="icon-button"
          title="Settings"
          onClick={onOpenSettings}
        >
          <SettingsIcon size={18} />
        </button>
      </div>
    </header>
  );
};
