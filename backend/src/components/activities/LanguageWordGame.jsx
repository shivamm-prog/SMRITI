import React, { useState } from 'react';
import { ArrowLeft, CheckCircle2, BookOpen, Sparkles } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { ActivityCompletionModal } from './ActivityCompletionModal';

export function LanguageWordGame({ activityData, onBack }) {
  const { currentUser } = useAuth();
  const { recordActivityResult } = useData();
  const { playGentleChime } = useAccessibility();

  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedIdx, setSelectedIdx] = useState(null);
  const [isAnswered, setIsAnswered] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);
  const [showCompletion, setShowCompletion] = useState(false);

  const questions = activityData.questions;
  const currentQ = questions[currentIndex];

  const handleSelect = (idx) => {
    if (isAnswered) return;
    playGentleChime();
    setSelectedIdx(idx);
    setIsAnswered(true);

    if (idx === currentQ.correctIndex) {
      setCorrectCount(prev => prev + 1);
    }
  };

  const handleNext = () => {
    if (currentIndex < questions.length - 1) {
      setCurrentIndex(prev => prev + 1);
      setSelectedIdx(null);
      setIsAnswered(false);
    } else {
      // Finish
      const score = Math.round(((correctCount + (selectedIdx === currentQ.correctIndex ? 1 : 0)) / questions.length) * 100);
      recordActivityResult({
        patientId: currentUser.id,
        activityId: activityData.id,
        activityTitle: activityData.title,
        category: activityData.category,
        score,
        totalQuestions: questions.length,
        correctCount: correctCount + (selectedIdx === currentQ.correctIndex ? 1 : 0),
        feedback: 'Wonderful linguistic connection! Gentle words and warm greetings connect us all.'
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
        <div className="badge badge-green">
          Word {currentIndex + 1} of {questions.length}
        </div>
      </div>

      <div className="card" style={{ padding: '2rem' }}>
        <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--text-main)', marginBottom: '0.4rem', textAlign: 'center' }}>
          {activityData.title}
        </h2>
        <p style={{ color: 'var(--text-muted)', textAlign: 'center', marginBottom: '1.5rem' }}>
          {activityData.instructions}
        </p>

        {/* Word Display Box */}
        <div
          style={{
            backgroundColor: '#ECFDF5',
            border: '2px solid #A7F3D0',
            borderRadius: 'var(--radius-lg)',
            padding: '1.75rem',
            textAlign: 'center',
            marginBottom: '1.75rem'
          }}
        >
          <div style={{ fontSize: 'var(--font-size-xs)', fontWeight: 700, color: '#047857', textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: '0.35rem' }}>
            🗣️ {currentQ.language}
          </div>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#064E3B', margin: '0.5rem 0' }}>
            &ldquo;{currentQ.phrase}&rdquo;
          </div>
          <p style={{ color: '#065F46', fontSize: 'var(--font-size-base)', margin: 0 }}>
            {currentQ.prompt}
          </p>
        </div>

        {/* Options */}
        <div className="flex flex-col gap-3 mb-6">
          {currentQ.options.map((opt, idx) => {
            const isSelected = selectedIdx === idx;
            const isCorrect = idx === currentQ.correctIndex;
            let btnClass = 'btn-outline';

            if (isAnswered) {
              if (isCorrect) btnClass = 'btn-success';
              else if (isSelected) btnClass = 'btn-secondary';
            }

            return (
              <button
                key={idx}
                className={`btn ${btnClass} btn-lg btn-block`}
                style={{
                  justifyContent: 'space-between',
                  paddingLeft: '1.5rem',
                  paddingRight: '1.5rem',
                  textAlign: 'left'
                }}
                disabled={isAnswered}
                onClick={() => handleSelect(idx)}
              >
                <span>{opt}</span>
                {isAnswered && isCorrect && <CheckCircle2 size={24} color="#FFFFFF" />}
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
            {currentQ.explanation}
          </div>
        )}

        {isAnswered && (
          <button className="btn btn-primary btn-lg btn-block" onClick={handleNext}>
            <span>{currentIndex < questions.length - 1 ? 'Next Familiar Word' : 'See Results'}</span>
          </button>
        )}
      </div>

      <ActivityCompletionModal
        isOpen={showCompletion}
        activityTitle={activityData.title}
        score={Math.round((correctCount / questions.length) * 100)}
        feedback="Beautiful! Preserving language connections keeps our memories warm and rooted."
        onPlayAgain={handlePlayAgain}
        onBackToCatalog={onBack}
      />
    </div>
  );
}
