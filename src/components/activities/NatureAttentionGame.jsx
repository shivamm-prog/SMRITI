import React, { useState } from 'react';
import { ArrowLeft, CheckCircle2, Eye, Sparkles } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { ActivityCompletionModal } from './ActivityCompletionModal';

export function NatureAttentionGame({ activityData, onBack }) {
  const { currentUser } = useAuth();
  const { recordActivityResult } = useData();
  const { playGentleChime } = useAccessibility();

  const [roundIndex, setRoundIndex] = useState(0);
  const [selectedItemId, setSelectedItemId] = useState(null);
  const [roundComplete, setRoundComplete] = useState(false);
  const [showCompletion, setShowCompletion] = useState(false);

  const rounds = activityData.rounds;
  const currentRound = rounds[roundIndex];

  const handleItemClick = (item) => {
    if (roundComplete) return;
    playGentleChime();
    setSelectedItemId(item.id);

    if (item.isTarget) {
      setRoundComplete(true);
      setTimeout(() => {
        if (roundIndex < rounds.length - 1) {
          setRoundIndex(prev => prev + 1);
          setSelectedItemId(null);
          setRoundComplete(false);
        } else {
          // Completed all rounds
          recordActivityResult({
            patientId: currentUser.id,
            activityId: activityData.id,
            activityTitle: activityData.title,
            category: activityData.category,
            score: 100,
            totalQuestions: rounds.length,
            correctCount: rounds.length,
            feedback: 'Wonderful visual attention! You spotted all the peaceful flora and fauna.'
          });
          setShowCompletion(true);
        }
      }, 900);
    }
  };

  const handlePlayAgain = () => {
    setRoundIndex(0);
    setSelectedItemId(null);
    setRoundComplete(false);
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
        <div className="badge badge-blue">
          Round {roundIndex + 1} of {rounds.length}
        </div>
      </div>

      <div className="card" style={{ padding: '2rem' }}>
        <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--text-main)', marginBottom: '0.25rem', textAlign: 'center' }}>
          {activityData.title}
        </h2>
        <p style={{ color: 'var(--text-muted)', textAlign: 'center', marginBottom: '1.5rem' }}>
          Look at the target item below and find it gently in the garden.
        </p>

        {/* Target Item Spotlight */}
        <div
          style={{
            backgroundColor: '#EFF6FF',
            border: '2px solid var(--primary-400)',
            borderRadius: 'var(--radius-lg)',
            padding: '1.25rem 1.5rem',
            textAlign: 'center',
            marginBottom: '1.75rem'
          }}
        >
          <div style={{ fontSize: 'var(--font-size-xs)', fontWeight: 700, color: 'var(--primary-800)', textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: '0.25rem' }}>
            🎯 Find This Item in the Garden
          </div>
          <div style={{ fontSize: '3.5rem', lineHeight: 1, margin: '0.5rem 0' }}>
            {currentRound.targetEmoji}
          </div>
          <h3 style={{ color: 'var(--primary-900)', margin: '0 0 0.25rem' }}>
            {currentRound.target}
          </h3>
          <p style={{ color: 'var(--primary-700)', fontSize: 'var(--font-size-sm)', margin: 0 }}>
            {currentRound.targetDescription}
          </p>
        </div>

        {/* 6 Grid Items */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '1rem',
            marginBottom: '1.5rem'
          }}
        >
          {currentRound.grid.map((item) => {
            const isSelected = selectedItemId === item.id;
            const isTarget = item.isTarget;
            const isFound = isSelected && isTarget;

            return (
              <button
                key={item.id}
                className="card card-interactive"
                style={{
                  minHeight: '110px',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  padding: '1rem',
                  backgroundColor: isFound ? '#DCFCE7' : '#FFFFFF',
                  borderColor: isFound ? '#16A34A' : isSelected ? 'var(--primary-400)' : 'var(--border-color)',
                  borderWidth: isFound ? '3px' : '2px',
                  borderRadius: 'var(--radius-lg)',
                  transition: 'all 200ms ease'
                }}
                onClick={() => handleItemClick(item)}
              >
                <span style={{ fontSize: '2.75rem', lineHeight: 1, marginBottom: '0.4rem' }}>
                  {item.emoji}
                </span>
                <span style={{ fontSize: '0.9rem', fontWeight: 600, color: isFound ? '#14532D' : 'var(--text-main)', textAlign: 'center' }}>
                  {item.label}
                </span>
                {isFound && (
                  <span style={{ fontSize: '0.75rem', color: '#16A34A', fontWeight: 700, marginTop: '2px' }}>
                    Spotted!
                  </span>
                )}
              </button>
            );
          })}
        </div>

        {/* Feedback message */}
        {roundComplete && (
          <div
            style={{
              backgroundColor: '#DCFCE7',
              border: '1.5px solid #86EFAC',
              borderRadius: 'var(--radius-md)',
              padding: '0.75rem 1rem',
              color: '#14532D',
              textAlign: 'center',
              fontWeight: 700
            }}
          >
            🌸 Splendid! You gently found the {currentRound.target}!
          </div>
        )}
      </div>

      <ActivityCompletionModal
        isOpen={showCompletion}
        activityTitle={activityData.title}
        score={100}
        feedback="Heartwarming! Your visual attention was steady, focused, and calm."
        onPlayAgain={handlePlayAgain}
        onBackToCatalog={onBack}
      />
    </div>
  );
}
