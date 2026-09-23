import React, { useState } from 'react';
import { X, CheckCircle2, Heart, HelpCircle, ArrowRight, RotateCcw } from 'lucide-react';
import { useAccessibility } from '../../context/AccessibilityContext';

export function MemoryRecallModal({ isOpen, onClose, memories }) {
  const { playGentleChime } = useAccessibility();
  const [memoryIndex, setMemoryIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState(null);
  const [isAnswered, setIsAnswered] = useState(false);
  const [showHint, setShowHint] = useState(false);
  const [isCompleted, setIsCompleted] = useState(false);

  if (!isOpen || !memories || memories.length === 0) return null;

  const currentMem = memories[memoryIndex];

  // Construct friendly multiple choice answers
  const options = [
    currentMem.recallAnswer,
    'A distant shopkeeper in town',
    'Old school friends from 1970'
  ];

  const handleSelect = (idx) => {
    if (isAnswered) return;
    playGentleChime();
    setSelectedOption(idx);
    setIsAnswered(true);
  };

  const handleNext = () => {
    if (memoryIndex < memories.length - 1) {
      setMemoryIndex(prev => prev + 1);
      setSelectedOption(null);
      setIsAnswered(false);
      setShowHint(false);
    } else {
      setIsCompleted(true);
    }
  };

  const handleReset = () => {
    setMemoryIndex(0);
    setSelectedOption(null);
    setIsAnswered(false);
    setShowHint(false);
    setIsCompleted(false);
  };

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="recall-title">
      <div className="modal-container" style={{ maxWidth: '620px' }}>
        <div className="modal-header">
          <div className="flex items-center gap-2">
            <span style={{ fontSize: '1.75rem' }}>💭</span>
            <h3 id="recall-title" style={{ margin: 0 }}>Family Memory Recall</h3>
          </div>
          <button className="modal-close-btn" onClick={onClose} aria-label="Close recall modal">
            <X size={24} />
          </button>
        </div>

        {!isCompleted ? (
          <div>
            <div className="flex items-center justify-between mb-3">
              <span className="badge badge-blue">
                Memory {memoryIndex + 1} of {memories.length}
              </span>
              <span style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                📍 {currentMem.location}
              </span>
            </div>

            {/* Photo / Scene Display */}
            <div
              style={{
                backgroundColor: 'var(--primary-50)',
                border: '2px solid var(--primary-200)',
                borderRadius: 'var(--radius-lg)',
                padding: '2rem 1.5rem',
                textAlign: 'center',
                marginBottom: '1.5rem'
              }}
            >
              <div style={{ fontSize: '4.5rem', lineHeight: 1, marginBottom: '0.75rem' }}>
                {currentMem.emojiPhoto}
              </div>
              <h3 style={{ color: 'var(--primary-900)', margin: '0 0 0.25rem' }}>
                {currentMem.title}
              </h3>
              <p style={{ color: 'var(--text-subtle)', fontSize: 'var(--font-size-sm)', margin: 0 }}>
                {currentMem.date}
              </p>
            </div>

            {/* Question */}
            <h3 style={{ textAlign: 'center', marginBottom: '1.25rem', color: 'var(--text-main)' }}>
              {currentMem.recallQuestion}
            </h3>

            {/* Hint */}
            <div style={{ textAlign: 'center', marginBottom: '1.25rem' }}>
              {!showHint ? (
                <button
                  className="btn btn-outline"
                  style={{ minHeight: '38px', padding: '0.3rem 0.8rem', fontSize: 'var(--font-size-sm)' }}
                  onClick={() => setShowHint(true)}
                >
                  <HelpCircle size={15} />
                  <span>Gentle Hint</span>
                </button>
              ) : (
                <div
                  style={{
                    backgroundColor: '#FEF3C7',
                    border: '1.5px solid #FCD34D',
                    borderRadius: 'var(--radius-md)',
                    padding: '0.6rem 1rem',
                    color: '#92400E',
                    fontSize: 'var(--font-size-sm)'
                  }}
                >
                  💡 {currentMem.recallHint}
                </div>
              )}
            </div>

            {/* Options */}
            <div className="flex flex-col gap-3 mb-6">
              {options.map((opt, idx) => {
                const isCorrect = idx === 0;
                let btnClass = 'btn-outline';

                if (isAnswered) {
                  if (isCorrect) btnClass = 'btn-success';
                  else if (selectedOption === idx) btnClass = 'btn-secondary';
                }

                return (
                  <button
                    key={idx}
                    className={`btn ${btnClass} btn-lg btn-block`}
                    style={{ textAlign: 'left', justifyContent: 'space-between' }}
                    disabled={isAnswered}
                    onClick={() => handleSelect(idx)}
                  >
                    <span>{opt}</span>
                    {isAnswered && isCorrect && <CheckCircle2 size={22} />}
                  </button>
                );
              })}
            </div>

            {isAnswered && (
              <button className="btn btn-primary btn-lg btn-block" onClick={handleNext}>
                <span>{memoryIndex < memories.length - 1 ? 'Next Memory' : 'Complete Recall'}</span>
                <ArrowRight size={20} />
              </button>
            )}
          </div>
        ) : (
          <div className="text-center" style={{ padding: '1.5rem 0' }}>
            <div
              style={{
                width: '72px',
                height: '72px',
                backgroundColor: '#DCFCE7',
                color: '#16A34A',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 1.25rem'
              }}
            >
              <Heart size={40} />
            </div>

            <h2 style={{ color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
              Memories Warm the Heart
            </h2>
            <p style={{ color: 'var(--text-muted)', marginBottom: '1.75rem' }}>
              You reviewed your family memories with great affection. Each memory strengthens our sense of peace.
            </p>

            <div className="flex gap-3">
              <button className="btn btn-secondary flex-1" onClick={handleReset}>
                <RotateCcw size={18} />
                <span>Practice Again</span>
              </button>
              <button className="btn btn-primary flex-1" onClick={onClose}>
                Close
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
