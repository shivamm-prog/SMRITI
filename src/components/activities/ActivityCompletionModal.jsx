import React, { useEffect } from 'react';
import { Sparkles, Trophy, RotateCcw, ArrowLeft, Heart } from 'lucide-react';
import confetti from 'canvas-confetti';
import { useAccessibility } from '../../context/AccessibilityContext';

export function ActivityCompletionModal({
  isOpen,
  activityTitle,
  score,
  feedback,
  timeTaken,
  onPlayAgain,
  onBackToCatalog
}) {
  const { playGentleChime } = useAccessibility();

  useEffect(() => {
    if (isOpen) {
      playGentleChime();
      try {
        confetti({
          particleCount: 50,
          spread: 60,
          origin: { y: 0.6 },
          colors: ['#2563EB', '#0D9488', '#F59E0B', '#10B981']
        });
      } catch {
        // Safe fallback
      }
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true">
      <div className="modal-container text-center" style={{ maxWidth: '520px', padding: '2.5rem 2rem' }}>
        {/* Calming Emblem */}
        <div
          style={{
            width: '88px',
            height: '88px',
            borderRadius: '50%',
            backgroundColor: 'var(--primary-50)',
            border: '3px solid var(--primary-500)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 1.25rem',
            color: 'var(--primary-700)'
          }}
        >
          <Trophy size={48} />
        </div>

        <span className="badge badge-green" style={{ marginBottom: '0.75rem', fontSize: 'var(--font-size-sm)' }}>
          <Heart size={14} /> Activity Completed Peacefully
        </span>

        <h2 style={{ color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
          Wonderful Effort!
        </h2>
        <p style={{ color: 'var(--text-subtle)', fontSize: 'var(--font-size-base)', marginBottom: '1.5rem' }}>
          {activityTitle}
        </p>

        {/* Score & Encouragement Card */}
        <div
          style={{
            backgroundColor: 'var(--bg-app)',
            border: '1.5px solid var(--border-subtle)',
            borderRadius: 'var(--radius-lg)',
            padding: '1.25rem',
            marginBottom: '1.75rem'
          }}
        >
          <div style={{ fontSize: '2.25rem', fontWeight: 800, color: 'var(--primary-700)', marginBottom: '0.25rem' }}>
            {score}%
          </div>
          <div style={{ fontWeight: 600, color: 'var(--text-main)', fontSize: 'var(--font-size-base)', marginBottom: '0.5rem' }}>
            {feedback || 'You exercised your mind with great calmness and care.'}
          </div>
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
            Recorded in your personal progress journal
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex flex-col gap-3">
          <button
            className="btn btn-primary btn-lg btn-block"
            onClick={onBackToCatalog}
          >
            <ArrowLeft size={20} />
            <span>Return to Activities</span>
          </button>

          <button
            className="btn btn-secondary btn-block"
            onClick={onPlayAgain}
          >
            <RotateCcw size={18} />
            <span>Play Again</span>
          </button>
        </div>
      </div>
    </div>
  );
}
