import React, { useState, useEffect } from 'react';
import { ArrowLeft, CheckCircle2, RotateCcw, HelpCircle } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { ActivityCompletionModal } from './ActivityCompletionModal';

export function DailySequenceGame({ activityData, onBack }) {
  const { currentUser } = useAuth();
  const { recordActivityResult } = useData();
  const { playGentleChime } = useAccessibility();

  const [availableSteps, setAvailableSteps] = useState([]);
  const [placedSteps, setPlacedSteps] = useState([]);
  const [feedbackMessage, setFeedbackMessage] = useState('');
  const [showCompletion, setShowCompletion] = useState(false);

  const initGame = () => {
    // Shuffle available steps
    const shuffled = [...activityData.steps].sort(() => Math.random() - 0.5);
    setAvailableSteps(shuffled);
    setPlacedSteps([]);
    setFeedbackMessage('Tap the very first step to begin making your warm morning tea.');
    setShowCompletion(false);
  };

  useEffect(() => {
    initGame();
  }, [activityData]);

  const handleStepClick = (step) => {
    const nextRequiredOrder = placedSteps.length + 1;
    playGentleChime();

    if (step.order === nextRequiredOrder) {
      // Correct sequence step!
      const newPlaced = [...placedSteps, step];
      setPlacedSteps(newPlaced);
      setAvailableSteps(prev => prev.filter(s => s.id !== step.id));

      if (newPlaced.length === activityData.steps.length) {
        setFeedbackMessage('Perfect! Your morning tea is ready to enjoy.');
        recordActivityResult({
          patientId: currentUser.id,
          activityId: activityData.id,
          activityTitle: activityData.title,
          category: activityData.category,
          score: 100,
          totalQuestions: activityData.steps.length,
          correctCount: activityData.steps.length,
          feedback: 'Seamless procedural recall! You followed the exact daily steps of making tea.'
        });
        setTimeout(() => {
          setShowCompletion(true);
        }, 800);
      } else {
        setFeedbackMessage(`Step ${nextRequiredOrder} placed! Now tap what you would do next.`);
      }
    } else {
      // Friendly encouraging guidance
      setFeedbackMessage(`Almost! Think about what comes before that step. Take a gentle look.`);
    }
  };

  return (
    <div className="container-narrow mt-6 mb-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <button className="btn btn-outline" onClick={onBack}>
          <ArrowLeft size={18} />
          <span>Exit Activity</span>
        </button>
        <div className="badge badge-blue">
          Step {placedSteps.length} of {activityData.steps.length}
        </div>
      </div>

      <div className="card" style={{ padding: '2rem' }}>
        <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--text-main)', marginBottom: '0.5rem', textAlign: 'center' }}>
          {activityData.title}
        </h2>
        <p style={{ color: 'var(--text-muted)', textAlign: 'center', marginBottom: '1.5rem' }}>
          {activityData.instructions}
        </p>

        {/* Guidance Prompt */}
        <div
          style={{
            backgroundColor: 'var(--primary-50)',
            border: '1.5px solid var(--primary-200)',
            borderRadius: 'var(--radius-md)',
            padding: '0.85rem 1.25rem',
            textAlign: 'center',
            marginBottom: '1.75rem',
            color: 'var(--primary-900)',
            fontWeight: 600
          }}
        >
          {feedbackMessage}
        </div>

        {/* Placed Sequence Slots */}
        <div style={{ marginBottom: '2rem' }}>
          <div style={{ fontSize: 'var(--font-size-sm)', fontWeight: 700, color: 'var(--text-subtle)', marginBottom: '0.75rem' }}>
            Tea Preparation Flow:
          </div>

          <div className="flex flex-col gap-3">
            {[1, 2, 3, 4].map((slotNumber) => {
              const placed = placedSteps[slotNumber - 1];
              return (
                <div
                  key={slotNumber}
                  style={{
                    minHeight: '64px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '1rem',
                    padding: '0.75rem 1.25rem',
                    borderRadius: 'var(--radius-md)',
                    border: placed ? '2px solid var(--accent-emerald)' : '2px dashed var(--border-color)',
                    backgroundColor: placed ? '#ECFDF5' : 'var(--bg-app)',
                    transition: 'all 200ms ease'
                  }}
                >
                  <div
                    style={{
                      width: '36px',
                      height: '36px',
                      borderRadius: '50%',
                      backgroundColor: placed ? 'var(--accent-emerald)' : 'var(--border-subtle)',
                      color: placed ? '#FFFFFF' : 'var(--text-subtle)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: 700
                    }}
                  >
                    {placed ? <CheckCircle2 size={20} /> : slotNumber}
                  </div>

                  {placed ? (
                    <div className="flex items-center gap-3">
                      <span style={{ fontSize: '1.8rem' }}>{placed.icon}</span>
                      <span style={{ fontWeight: 600, color: '#064E3B', fontSize: 'var(--font-size-base)' }}>
                        {placed.text}
                      </span>
                    </div>
                  ) : (
                    <span style={{ color: 'var(--text-subtle)', fontStyle: 'italic' }}>
                      Step {slotNumber}: Waiting for your choice...
                    </span>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Available Steps to Tap */}
        {availableSteps.length > 0 && (
          <div>
            <div style={{ fontSize: 'var(--font-size-sm)', fontWeight: 700, color: 'var(--primary-800)', marginBottom: '0.75rem' }}>
              Tap the next step:
            </div>
            <div className="flex flex-col gap-3">
              {availableSteps.map((step) => (
                <button
                  key={step.id}
                  className="btn btn-outline btn-lg btn-block"
                  style={{
                    justifyContent: 'flex-start',
                    textAlign: 'left',
                    padding: '1rem 1.25rem',
                    borderColor: 'var(--border-color)'
                  }}
                  onClick={() => handleStepClick(step)}
                >
                  <span style={{ fontSize: '1.8rem', marginRight: '0.5rem' }}>{step.icon}</span>
                  <span>{step.text}</span>
                </button>
              ))}
            </div>
          </div>
        )}

        <div className="flex justify-center mt-6">
          <button className="btn btn-secondary" onClick={initGame}>
            <RotateCcw size={16} />
            <span>Reset Steps</span>
          </button>
        </div>
      </div>

      <ActivityCompletionModal
        isOpen={showCompletion}
        activityTitle={activityData.title}
        score={100}
        feedback="Splendid! Practicing everyday routines keeps procedural memory flourishing."
        onPlayAgain={initGame}
        onBackToCatalog={onBack}
      />
    </div>
  );
}
