import React, { useState, useEffect } from 'react';
import { Mic, MicOff, Volume2, X, Sparkles, ArrowRight } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export function VoiceCompanionModal({ isOpen, onClose, onNavigateTab }) {
  const { currentUser } = useAuth();
  const [state, setState] = useState('listening'); // 'listening' | 'processing' | 'response'
  const [recognizedText, setRecognizedText] = useState('');
  const [responseText, setResponseText] = useState('');
  const [targetTab, setTargetTab] = useState(null);

  const sampleCommands = [
    { text: "Show today's activities", action: 'activities', reply: "Certainly! Opening your gentle activities for today." },
    { text: "Show my reminders", action: 'reminders', reply: "Opening your reminders. You have a warm cup of herbal tea coming up at 11:00 AM." },
    { text: "Start a memory game", action: 'activities', reply: "Starting your familiar places memory activity. Let us look at Kaziranga and Cherrapunji together." },
    { text: "What do I have today?", action: 'home', reply: "Good day, Bhaben! Today you have 2 calming activities, your morning walk, and healthy meals scheduled." }
  ];

  useEffect(() => {
    if (isOpen) {
      setState('listening');
      setRecognizedText('');
      setResponseText('');
      setTargetTab(null);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleCommandSelect = (cmd) => {
    setRecognizedText(cmd.text);
    setState('processing');

    setTimeout(() => {
      setState('response');
      setResponseText(cmd.reply);
      setTargetTab(cmd.action);
    }, 1200);
  };

  const handleSimulateListen = () => {
    setState('processing');
    setRecognizedText("Show my reminders and medicine");

    setTimeout(() => {
      setState('response');
      setResponseText("Showing your reminders. Your morning BP vitamin has already been completed!");
      setTargetTab('reminders');
    }, 1400);
  };

  const handleActionClick = () => {
    if (targetTab && onNavigateTab) {
      onNavigateTab(targetTab);
    }
    onClose();
  };

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="voice-title">
      <div className="modal-container text-center" style={{ maxWidth: '540px' }}>
        <div className="modal-header" style={{ justifyContent: 'space-between' }}>
          <div className="flex items-center gap-2">
            <span style={{ fontSize: '1.5rem' }}>🎙️</span>
            <h3 id="voice-title" style={{ margin: 0 }}>MindSetu Voice Companion</h3>
          </div>
          <button className="modal-close-btn" onClick={onClose} aria-label="Close voice companion">
            <X size={24} />
          </button>
        </div>

        {/* Status Indicator Banner */}
        <div
          style={{
            backgroundColor: '#EFF6FF',
            border: '1.5px solid var(--primary-200)',
            borderRadius: 'var(--radius-md)',
            padding: '0.65rem 1rem',
            fontSize: 'var(--font-size-sm)',
            color: 'var(--primary-800)',
            marginBottom: '1.5rem'
          }}
        >
          <Sparkles size={16} style={{ display: 'inline', marginRight: '6px', verticalAlign: 'middle' }} />
          Voice AI Interface — Multi-lingual NER speech model will be connected in Phase 2
        </div>

        {/* Center Animated Visualizer */}
        <div style={{ padding: '1.5rem 0' }}>
          {state === 'listening' && (
            <div>
              <div
                style={{
                  width: '100px',
                  height: '100px',
                  borderRadius: '50%',
                  backgroundColor: 'var(--primary-100)',
                  border: '4px solid var(--primary-500)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 1.5rem',
                  cursor: 'pointer'
                }}
                className="animate-pulse-gentle"
                onClick={handleSimulateListen}
                title="Tap to simulate speaking"
              >
                <Mic size={48} color="var(--primary-700)" />
              </div>

              {/* Gentle Audio Wave animation */}
              <div className="flex justify-center items-center gap-2" style={{ height: '48px', marginBottom: '1rem' }}>
                <div className="wave-bar" />
                <div className="wave-bar" />
                <div className="wave-bar" />
                <div className="wave-bar" />
                <div className="wave-bar" />
              </div>

              <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
                I am listening gently...
              </h3>
              <p style={{ color: 'var(--text-muted)' }}>
                Speak in {currentUser?.language || 'Assamese or English'}. Take your time.
              </p>
            </div>
          )}

          {state === 'processing' && (
            <div>
              <div
                style={{
                  width: '80px',
                  height: '80px',
                  borderRadius: '50%',
                  backgroundColor: 'var(--primary-50)',
                  border: '3px dashed var(--primary-500)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 1.5rem'
                }}
              >
                <Sparkles size={36} color="var(--primary-600)" />
              </div>
              <h3 style={{ color: 'var(--primary-800)', marginBottom: '0.5rem' }}>
                Understanding: &ldquo;{recognizedText}&rdquo;
              </h3>
              <p style={{ color: 'var(--text-subtle)' }}>Processing your voice with care...</p>
            </div>
          )}

          {state === 'response' && (
            <div>
              <div
                style={{
                  width: '80px',
                  height: '80px',
                  borderRadius: '50%',
                  backgroundColor: '#DCFCE7',
                  border: '3px solid #16A34A',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 1.25rem'
                }}
              >
                <Volume2 size={40} color="#15803D" />
              </div>

              <div
                style={{
                  backgroundColor: 'var(--bg-card-subtle)',
                  borderRadius: 'var(--radius-lg)',
                  padding: '1.25rem',
                  fontSize: 'var(--font-size-lg)',
                  color: 'var(--text-main)',
                  fontWeight: 600,
                  marginBottom: '1.5rem',
                  border: '1.5px solid var(--border-subtle)',
                  lineHeight: 1.5
                }}
              >
                &ldquo;{responseText}&rdquo;
              </div>

              {targetTab && (
                <button
                  className="btn btn-primary btn-lg btn-block mb-4"
                  onClick={handleActionClick}
                >
                  <span>Go to {targetTab.charAt(0).toUpperCase() + targetTab.slice(1)}</span>
                  <ArrowRight size={20} />
                </button>
              )}

              <button
                className="btn btn-secondary btn-block"
                onClick={() => setState('listening')}
              >
                <Mic size={20} />
                <span>Ask Something Else</span>
              </button>
            </div>
          )}
        </div>

        {/* Quick Voice Command Chips */}
        {state === 'listening' && (
          <div style={{ marginTop: '1rem', borderTop: '1.5px solid var(--border-subtle)', paddingTop: '1.25rem' }}>
            <div style={{ fontSize: 'var(--font-size-sm)', fontWeight: 700, color: 'var(--text-subtle)', marginBottom: '0.75rem' }}>
              Or tap a common question:
            </div>
            <div className="flex flex-col gap-2">
              {sampleCommands.map((cmd, idx) => (
                <button
                  key={idx}
                  className="btn btn-outline"
                  style={{ justifyContent: 'flex-start', textAlign: 'left', minHeight: '48px', padding: '0.6rem 1rem' }}
                  onClick={() => handleCommandSelect(cmd)}
                >
                  <span style={{ color: 'var(--primary-600)' }}>💬</span>
                  <span>&ldquo;{cmd.text}&rdquo;</span>
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
