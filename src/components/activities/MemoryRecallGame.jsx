import React, { useState } from 'react';
import { ArrowLeft, CheckCircle2, HelpCircle, Sparkles, Volume2 } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { ActivityCompletionModal } from './ActivityCompletionModal';

export function MemoryRecallGame({ activityData, onBack }) {
  const { currentUser } = useAuth();
  const { recordActivityResult } = useData();
  const { playGentleChime } = useAccessibility();

  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState(null);
  const [isAnswered, setIsAnswered] = useState(false);
  const [showHint, setShowHint] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);
  const [showCompletion, setShowCompletion] = useState(false);

  const questions = activityData.questions;
  const currentQ = questions[currentIndex];

  const handleSelect = (index) => {
    if (isAnswered) return;
    setSelectedOption(index);
    setIsAnswered(true);
    playGentleChime();

    const isCorrect = index === currentQ.correctIndex;
    if (isCorrect) {
      setCorrectCount(prev => prev + 1);
    }
  };

  const handleNext = () => {
    if (currentIndex < questions.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setSelectedOption(null);
      setIsAnswered(false);
      setShowHint(false);
    } else {
      // Complete activity
      const finalScore = Math.round(((correctCount + (selectedOption === currentQ.correctIndex ? 1 : 0)) / questions.length) * 100);
      recordActivityResult({
        patientId: currentUser.id,
        activityId: activityData.id,
        activityTitle: activityData.title,
        category: activityData.category,
        score: finalScore,
        totalQuestions: questions.length,
        correctCount: correctCount + (selectedOption === currentQ.correctIndex ? 1 : 0),
        feedback: finalScore >= 80
          ? 'Splendid recall! You remembered the stories and places of our beautiful hills.'
          : 'A peaceful effort! Remembering familiar scenes helps keep our mind refreshed.'
      });
      setShowCompletion(true);
    }
  };

  const handlePlayAgain = () => {
    setCurrentIndex(0);
    setSelectedOption(null);
    setIsAnswered(false);
    setShowHint(false);
    setCorrectCount(0);
    setShowCompletion(false);
  };

  return (
    <div className="container-narrow mt-6 mb-8">
      {/* Top bar with back button and progress indicator */}
      <div className="flex items-center justify-between mb-4">
        <button className="btn btn-outline" onClick={onBack}>
          <ArrowLeft size={18} />
          <span>Exit Activity</span>
        </button>
        <div className="badge badge-blue">
          Question {currentIndex + 1} of {questions.length}
        </div>
      </div>

      {/* Main Game Card */}
      <div className="card" style={{ padding: '2rem' }}>
        {/* Progress Bar */}
        <div
          style={{
            height: '8px',
            backgroundColor: 'var(--border-subtle)',
            borderRadius: '4px',
            marginBottom: '1.75rem',
            overflow: 'hidden'
          }}
        >
          <div
            style={{
              height: '100%',
              width: `${((currentIndex + 1) / questions.length) * 100}%`,
              backgroundColor: 'var(--primary-600)',
              transition: 'width 300ms ease'
            }}
          />
        </div>

        {/* Visual Scene Illustration / Emoji Photo */}
        <div
          style={{
            backgroundColor: 'var(--primary-50)',
            border: '2px solid var(--primary-200)',
            borderRadius: 'var(--radius-lg)',
            padding: '2rem 1.5rem',
            textAlign: 'center',
            marginBottom: '1.75rem'
          }}
        >
          <div style={{ fontSize: '4.5rem', marginBottom: '0.75rem', lineHeight: 1 }}>
            {currentQ.imageEmoji}
          </div>
          <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.25rem' }}>
            {currentQ.imagePlaceholderText}
          </h3>
          <p style={{ color: 'var(--primary-700)', fontSize: 'var(--font-size-sm)', margin: 0 }}>
            📍 {currentQ.imageLocation}
          </p>
        </div>

        {/* Question Prompt */}
        <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--text-main)', marginBottom: '1.5rem', textAlign: 'center' }}>
          {currentQ.title}
        </h2>

        {/* Hint toggle */}
        <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
          {!showHint ? (
            <button
              className="btn btn-outline"
              style={{ minHeight: '40px', padding: '0.4rem 1rem', fontSize: 'var(--font-size-sm)' }}
              onClick={() => setShowHint(true)}
            >
              <HelpCircle size={16} />
              <span>Need a gentle hint?</span>
            </button>
          ) : (
            <div
              style={{
                backgroundColor: '#FEF3C7',
                border: '1.5px solid #FCD34D',
                borderRadius: 'var(--radius-md)',
                padding: '0.75rem 1rem',
                color: '#92400E',
                fontSize: 'var(--font-size-base)'
              }}
            >
              💡 <strong>Hint:</strong> {currentQ.hint}
            </div>
          )}
        </div>

        {/* Options (Large Touch Targets) */}
        <div className="flex flex-col gap-3 mb-6">
          {currentQ.options.map((option, idx) => {
            const isSelected = selectedOption === idx;
            const isCorrect = idx === currentQ.correctIndex;
            let btnClass = 'btn-outline';

            if (isAnswered) {
              if (isCorrect) btnClass = 'btn-success';
              else if (isSelected && !isCorrect) btnClass = 'btn-secondary';
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
                <span>{option}</span>
                {isAnswered && isCorrect && <CheckCircle2 size={24} color="#FFFFFF" />}
              </button>
            );
          })}
        </div>

        {/* Feedback Banner */}
        {isAnswered && (
          <div
            style={{
              backgroundColor: selectedOption === currentQ.correctIndex ? '#DCFCE7' : '#EFF6FF',
              border: `1.5px solid ${selectedOption === currentQ.correctIndex ? '#86EFAC' : 'var(--primary-200)'}`,
              borderRadius: 'var(--radius-md)',
              padding: '1rem 1.25rem',
              marginBottom: '1.5rem',
              color: selectedOption === currentQ.correctIndex ? '#14532D' : 'var(--primary-900)'
            }}
          >
            <div style={{ fontWeight: 700, marginBottom: '0.25rem' }}>
              {selectedOption === currentQ.correctIndex ? '🌸 Wonderful!' : '🌿 Gentle Practice'}
            </div>
            <div>{currentQ.explanation}</div>
          </div>
        )}

        {/* Next Question / Finish Action */}
        {isAnswered && (
          <button className="btn btn-primary btn-lg btn-block" onClick={handleNext}>
            <span>{currentIndex < questions.length - 1 ? 'Continue to Next Picture' : 'See Activity Results'}</span>
          </button>
        )}
      </div>

      <ActivityCompletionModal
        isOpen={showCompletion}
        activityTitle={activityData.title}
        score={Math.round((correctCount / questions.length) * 100)}
        feedback={correctCount === questions.length ? 'Outstanding! Your memory is clear and serene.' : 'Great effort! Reconnecting with familiar scenes warms the mind.'}
        onPlayAgain={handlePlayAgain}
        onBackToCatalog={onBack}
      />
    </div>
  );
}
