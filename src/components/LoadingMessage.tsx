import React from 'react';

export const LoadingMessage: React.FC = () => {
  return (
    <div className="message-wrapper assistant">
      <div className="message-avatar">M</div>
      <div className="message-content-box">
        <div className="message-header-row">
          <span className="message-author">MSAI</span>
        </div>
        <div className="loading-indicator">
          <div className="loading-dot" />
          <div className="loading-dot" />
          <div className="loading-dot" />
        </div>
      </div>
    </div>
  );
};
