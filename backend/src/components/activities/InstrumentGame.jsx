import React, { useState } from 'react';
import { ArrowLeft, CheckCircle2, Volume2, Music, Sparkles } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { ActivityCompletionModal } from './ActivityCompletionModal';

export function InstrumentGame({ activityData, onBack }) {
  const { currentUser } = useAuth();
  const { recordActivityResult } = useData();
  const { playGentleChime } = useAccessibility();

  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedIdx, setSelectedIdx] = useState(null);
  const [isAnswered, setIsAnswered] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);
  const [showCompletion, setShowCompletion] = useState(false);

  const items = activityData.items;
  const currentItem = items[currentIndex];

  const handleOptionSelect = (idx, opt) => {
    if (isAnswered) return;
    playGentleChime();
    setSelectedIdx(idx);
    setIsAnswered(true);

    if (opt.isCorrect) {
      setCorrectCount(prev => prev + 1);
    }
  };

  const handleNext = () => {
    if (currentIndex < items.length - 1) {
      setCurrentIndex(prev => prev + 1);
      setSelectedIdx(null);
      setIsAnswered(false);
    } else {
      // Complete
      const score = Math.round(((correctCount + (currentItem.options[selectedIdx]?.isCorrect ? 1 : 0)) / items.length) * 100);
      recordActivityResult({
        patientId: currentUser.id,
        activityId: activityData.id,
        activityTitle: activityData.title,
        category: activityData.category,
        score,
        totalQuestions: items.length,
        correctCount: correctCount + (currentItem.options[selectedIdx]?.isCorrect ? 1 : 0),
        feedback: 'Wonderful musical appreciation! Traditional melodies bring joy and nostalgia to the soul.'
      });
      setShowCompletion(true);
    }
  };

  const handlePlayAgain = () => {
    setCurrentIndex(0);
    setSelectedIdx(null);
    setIsAnswered(false);
    setCorrectCount(0);
    setShowCompletion(false);
  };

  return (
    <div className="container-narrow mt-6 mb-8">
      {/* Top Header */}
      <div className="flex items-center justify-between mb-4">
        <button className="btn btn-outline" onClick={onBack}>
          <ArrowLeft size={18} />
          <span>Exit Activity</span>
        </button>
        <div className="badge badge-amber">
          Instrument {currentIndex + 1} of {items.length}
        </div>
      </div>

      <div className="card" style={{ padding: '2rem' }}>
        <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--text-main)', marginBottom: '0.4rem', textAlign: 'center' }}>
          {activityData.title}
        </h2>
        <p style={{ color: 'var(--text-muted)', textAlign: 'center', marginBottom: '1.5rem' }}>
          Listen to the description of the musical melody and identify the traditional instrument.
        </p>

        {/* Audio Melodic Simulation Box */}
        <div
          style={{
            backgroundColor: '#FFFBEB',
            border: '2px solid #FCD34D',
            borderRadius: 'var(--radius-lg)',
            padding: '1.5rem',
            textAlign: 'center',
            marginBottom: '1.75rem'
          }}
        >
          <div className="flex items-center justify-center gap-2 mb-2" style={{ color: '#B45309' }}>
            <Volume2 size={24} />
            <span style={{ fontWeight: 700, fontSize: 'var(--font-size-sm)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              Sound of the Instrument
            </span>
          </div>

          <div style={{ fontSize: 'var(--font-size-lg)', fontStyle: 'italic', color: '#78350F', marginBottom: '0.75rem', lineHeight: 1.4 }}>
            &ldquo;{currentItem.audioSimulationText}&rdquo;
          </div>

          <div style={{ fontSize: 'var(--font-size-sm)', color: '#92400E', fontWeight: 600 }}>
            ✨ {currentItem.clue}
          </div>
        </div>

        {/* Question Prompt */}
        <h3 style={{ fontSize: 'var(--font-size-lg)', color: 'var(--text-main)', marginBottom: '1.25rem', textAlign: 'center' }}>
          {currentItem.title}
        </h3>

        {/* 3 Large Touch Choice Cards */}
        <div className="grid grid-cols-3 md-grid-cols-1 gap-3 mb-6">
          {currentItem.options.map((opt, idx) => {
            const isSelected = selectedIdx === idx;
            let borderCol = 'var(--border-color)';
            let bgCol = '#FFFFFF';

            if (isAnswered) {
              if (opt.isCorrect) {
                borderCol = 'var(--accent-emerald)';
                bgCol = '#DCFCE7';
              } else if (isSelected) {
                borderCol = 'var(--primary-300)';
                bgCol = 'var(--primary-50)';
              }
            }

            return (
              <button
                key={idx}
                className="card card-interactive"
                style={{
                  padding: '1.5rem 1rem',
                  textAlign: 'center',
                  border: `2.5px solid ${borderCol}`,
                  backgroundColor: bgCol,
                  borderRadius: 'var(--radius-lg)'
                }}
                disabled={isAnswered}
                onClick={() => handleOptionSelect(idx, opt)}
              >
                <div style={{ fontSize: '3rem', lineHeight: 1, marginBottom: '0.5rem' }}>
                  {opt.emoji}
                </div>
                <div style={{ fontWeight: 700, fontSize: 'var(--font-size-base)', color: 'var(--text-main)' }}>
                  {opt.name}
                </div>
                {isAnswered && opt.isCorrect && (
                  <div style={{ color: '#16A34A', fontSize: 'var(--font-size-xs)', fontWeight: 700, marginTop: '4px' }}>
                    Correct Choice!
                  </div>
                )}
              </button>
            );
          })}
        </div>

        {/* Explanation */}
        {isAnswered && (
          <div
            style={{
              backgroundColor: '#EFF6FF',
              border: '1.5px solid var(--primary-200)',
              borderRadius: 'var(--radius-md)',
              padding: '1rem 1.25rem',
              marginBottom: '1.5rem',
              color: 'var(--primary-900)'
            }}
          >
            {currentItem.explanation}
          </div>
        )}

        {isAnswered && (
          <button className="btn btn-primary btn-lg btn-block" onClick={handleNext}>
            <span>{currentIndex < items.length - 1 ? 'Next Instrument' : 'View Results'}</span>
          </button>
        )}
      </div>

      <ActivityCompletionModal
        isOpen={showCompletion}
        activityTitle={activityData.title}
        score={Math.round((correctCount / items.length) * 100)}
        feedback="Marvelous! Traditional musical heritage keeps our spirits uplifted and peaceful."
        onPlayAgain={handlePlayAgain}
        onBackToCatalog={onBack}
      />
    </div>
  );
}
