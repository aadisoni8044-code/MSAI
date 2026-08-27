import React, { useState, useRef, useEffect } from 'react';
import {
  ArrowUp,
  Square,
  Paperclip,
  Mic,
  MicOff,
  Plus,
  X
} from 'lucide-react';
import { Attachment } from '../types/chat';

interface MessageInputProps {
  onSendMessage: (text: string, attachments: Attachment[]) => void;
  onStopGeneration: () => void;
  isLoading: boolean;
  enterToSend: boolean;
}

export const MessageInput: React.FC<MessageInputProps> = ({
  onSendMessage,
  onStopGeneration,
  isLoading,
  enterToSend,
}) => {
  const [input, setInput] = useState('');
  const [mode, setMode] = useState<'chat' | 'cowork'>('chat');
  const [attachments, setAttachments] = useState<Attachment[]>([]);
  const [isRecording, setIsRecording] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Auto-resize textarea
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.style.height = `${Math.min(
        textareaRef.current.scrollHeight,
        200
      )}px`;
    }
  }, [input]);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter') {
      if (enterToSend && !e.shiftKey) {
        e.preventDefault();
        handleSubmit();
      }
    }
  };

  const handleSubmit = () => {
    if ((input.trim() || attachments.length > 0) && !isLoading) {
      onSendMessage(input.trim(), attachments);
      setInput('');
      setAttachments([]);
      if (textareaRef.current) {
        textareaRef.current.style.height = 'auto';
      }
    }
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files) return;

    Array.from(files).forEach((file) => {
      const reader = new FileReader();
      reader.onload = () => {
        const attachment: Attachment = {
          id: 'att_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
          name: file.name,
          type: file.type.split('/')[0],
          mimeType: file.type || 'application/octet-stream',
          size: file.size,
          data: reader.result as string,
        };
        setAttachments((prev) => [...prev, attachment]);
      };
      reader.readAsDataURL(file);
    });

    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const removeAttachment = (id: string) => {
    setAttachments((prev) => prev.filter((a) => a.id !== id));
  };

  const toggleVoice = () => {
    if (!('webkitSpeechRecognition' in window || 'SpeechRecognition' in window)) {
      alert('Voice dictation is not supported by your browser.');
      return;
    }

    if (isRecording) {
      setIsRecording(false);
      return;
    }

    try {
      const SpeechRecognition =
        (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
      const recognition = new SpeechRecognition();
      recognition.continuous = false;
      recognition.interimResults = false;
      recognition.lang = 'en-US';

      recognition.onstart = () => setIsRecording(true);
      recognition.onend = () => setIsRecording(false);
      recognition.onerror = () => setIsRecording(false);
      recognition.onresult = (event: any) => {
        const transcript = event.results[0][0].transcript;
        setInput((prev) => (prev ? `${prev} ${transcript}` : transcript));
      };

      recognition.start();
    } catch (e) {
      console.error(e);
      setIsRecording(false);
    }
  };

  return (
    <div className="prompt-container-outer">
      <div className="prompt-input-box">
        {/* Render file attachment badges if any */}
        {attachments.length > 0 && (
          <div className="message-attachments">
            {attachments.map((att) => (
              <div key={att.id} className="attachment-chip">
                <Paperclip size={13} />
                <span>{att.name}</span>
                <button
                  onClick={() => removeAttachment(att.id)}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: 'var(--text-muted)',
                    cursor: 'pointer',
                  }}
                >
                  <X size={13} />
                </button>
              </div>
            ))}
          </div>
        )}

        <textarea
          ref={textareaRef}
          className="prompt-textarea"
          placeholder="How can I help you today?"
          rows={1}
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
        />

        <div className="prompt-bottom-controls">
          <div className="prompt-mode-pills">
            <input
              type="file"
              ref={fileInputRef}
              onChange={handleFileUpload}
              style={{ display: 'none' }}
              multiple
            />
            <button
              className="icon-button"
              title="Attach File"
              onClick={() => fileInputRef.current?.click()}
            >
              <Plus size={18} />
            </button>

            <button
              className={`mode-pill ${mode === 'chat' ? 'active' : ''}`}
              onClick={() => setMode('chat')}
            >
              Chat
            </button>
            <button
              className={`mode-pill ${mode === 'cowork' ? 'active' : ''}`}
              onClick={() => setMode('cowork')}
            >
              Cowork
            </button>
          </div>

          <div className="prompt-action-buttons">
            <button
              className={`icon-button ${isRecording ? 'active' : ''}`}
              title={isRecording ? 'Listening...' : 'Voice Input'}
              onClick={toggleVoice}
              style={{ color: isRecording ? '#ef4444' : undefined }}
            >
              {isRecording ? <MicOff size={18} /> : <Mic size={18} />}
            </button>

            {isLoading ? (
              <button
                className="btn-stop"
                title="Stop generation"
                onClick={onStopGeneration}
              >
                <Square size={14} fill="currentColor" />
              </button>
            ) : (
              <button
                className="btn-send"
                title="Send message"
                disabled={!input.trim() && attachments.length === 0}
                onClick={handleSubmit}
              >
                <ArrowUp size={18} />
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="prompt-footer-hint">
        {enterToSend ? 'PRESS ENTER TO SEND · SHIFT + ENTER FOR NEW LINE' : 'PRESS ENTER FOR NEW LINE · CLICK SEND BUTTON'}
      </div>
    </div>
  );
};
