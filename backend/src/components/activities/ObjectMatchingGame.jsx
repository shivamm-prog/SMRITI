import React, { useState, useEffect } from 'react';
import { ArrowLeft, Sparkles, CheckCircle2, RotateCcw } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { ActivityCompletionModal } from './ActivityCompletionModal';

export function ObjectMatchingGame({ activityData, onBack }) {
  const { currentUser } = useAuth();
  const { recordActivityResult } = useData();
  const { playGentleChime } = useAccessibility();

  const [cards, setCards] = useState([]);
  const [flippedIndices, setFlippedIndices] = useState([]);
  const [matchedIds, setMatchedIds] = useState([]);
  const [turns, setTurns] = useState(0);
  const [showCompletion, setShowCompletion] = useState(false);

  // Initialize deck (shuffle 6 pairs = 12 cards)
  const initializeGame = () => {
    const deck = [];
    activityData.pairs.forEach((pair) => {
      deck.push({ ...pair, uniqueId: `${pair.id}-a` });
      deck.push({ ...pair, uniqueId: `${pair.id}-b` });
    });
    // Friendly shuffle
    deck.sort(() => Math.random() - 0.5);
    setCards(deck);
    setFlippedIndices([]);
    setMatchedIds([]);
    setTurns(0);
    setShowCompletion(false);
  };

  useEffect(() => {
    initializeGame();
  }, [activityData]);

  const handleCardClick = (index) => {
    // Prevent clicking already flipped or matched cards
    if (
      flippedIndices.length === 2 ||
      flippedIndices.includes(index) ||
      matchedIds.includes(cards[index].id)
    ) {
      return;
    }

    playGentleChime();
    const newFlipped = [...flippedIndices, index];
    setFlippedIndices(newFlipped);

    if (newFlipped.length === 2) {
      setTurns(prev => prev + 1);
      const firstCard = cards[newFlipped[0]];
      const secondCard = cards[newFlipped[1]];

      if (firstCard.id === secondCard.id) {
        // Matched!
        setTimeout(() => {
          const nextMatched = [...matchedIds, firstCard.id];
          setMatchedIds(nextMatched);
          setFlippedIndices([]);

          if (nextMatched.length === activityData.pairs.length) {
            // Finished!
            const score = 100;
            recordActivityResult({
              patientId: currentUser.id,
              activityId: activityData.id,
              activityTitle: activityData.title,
              category: activityData.category,
              score,
              totalQuestions: activityData.pairs.length,
              correctCount: activityData.pairs.length,
              feedback: 'Bravo! You gently matched all 6 pairs of traditional treasures.'
            });
            setShowCompletion(true);
          }
        }, 500);
      } else {
        // Reset after gentle glance
        setTimeout(() => {
          setFlippedIndices([]);
        }, 1200);
      }
    }
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
          Matched {matchedIds.length} of {activityData.pairs.length} pairs
        </div>
      </div>

      <div className="card" style={{ padding: '1.75rem' }}>
        <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--text-main)', marginBottom: '0.4rem', textAlign: 'center' }}>
          {activityData.title}
        </h2>
        <p style={{ color: 'var(--text-muted)', textAlign: 'center', marginBottom: '1.5rem' }}>
          Tap two cards to find matching traditional treasures. Take all the time you need!
        </p>

        {/* 12 Cards Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '1rem',
            marginBottom: '1.75rem'
          }}
        >
          {cards.map((card, idx) => {
            const isFlipped = flippedIndices.includes(idx) || matchedIds.includes(card.id);
            const isMatched = matchedIds.includes(card.id);

            return (
              <button
                key={card.uniqueId}
                className="card card-interactive"
                style={{
                  minHeight: '120px',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  padding: '1rem 0.5rem',
                  backgroundColor: isMatched
                    ? '#DCFCE7'
                    : isFlipped
                    ? 'var(--primary-50)'
                    : '#FFFFFF',
                  borderColor: isMatched
                    ? '#86EFAC'
                    : isFlipped
                    ? 'var(--primary-500)'
                    : 'var(--border-color)',
                  borderWidth: '2.5px',
                  borderRadius: 'var(--radius-lg)',
                  cursor: isMatched ? 'default' : 'pointer',
                  transition: 'all 200ms ease'
                }}
                onClick={() => handleCardClick(idx)}
                aria-label={isFlipped ? card.name : 'Hidden card, tap to reveal'}
              >
                {isFlipped ? (
                  <>
                    <span style={{ fontSize: '2.5rem', lineHeight: 1, marginBottom: '0.35rem' }}>
                      {card.emoji}
                    </span>
                    <span style={{ fontWeight: 700, fontSize: '0.9rem', color: isMatched ? '#14532D' : 'var(--primary-900)', textAlign: 'center' }}>
                      {card.name}
                    </span>
                  </>
                ) : (
                  <div style={{ textAlign: 'center', color: 'var(--primary-400)' }}>
                    <Sparkles size={28} />
                    <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)', marginTop: '4px', fontWeight: 600 }}>
                      Tap to view
                    </div>
                  </div>
                )}
              </button>
            );
          })}
        </div>

        {/* Reset button */}
        <div className="flex justify-center">
          <button className="btn btn-secondary" onClick={initializeGame}>
            <RotateCcw size={16} />
            <span>Shuffle Cards</span>
          </button>
        </div>
      </div>

      <ActivityCompletionModal
        isOpen={showCompletion}
        activityTitle={activityData.title}
        score={100}
        feedback="Warm congratulations! Matching traditional cultural items keeps memory sharp and heart full."
        onPlayAgain={initializeGame}
        onBackToCatalog={onBack}
      />
    </div>
  );
}
