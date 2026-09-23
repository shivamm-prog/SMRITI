import React, { useState } from 'react';
import {
  Sparkles,
  Mic,
  Clock,
  CheckCircle2,
  Circle,
  Play,
  ArrowRight,
  Heart,
  Calendar,
  AlertCircle
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { ACTIVITIES } from '../../data/activitiesData';
import { NER_STATES } from '../../data/nerRegions';
import { VoiceCompanionModal } from '../common/VoiceCompanionModal';

export function PatientHome({ onNavigateTab, onStartActivity }) {
  const { currentUser } = useAuth();
  const { reminders, toggleReminder, activityResults } = useData();
  const { playGentleChime } = useAccessibility();
  const [showVoice, setShowVoice] = useState(false);

  // Dynamic greeting based on time of day
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  };

  const userRegion = NER_STATES.find(s => s.id === currentUser?.region) || NER_STATES[0];
  const pendingReminders = reminders.filter(r => !r.completed);
  const todaysActivities = ACTIVITIES.slice(0, 2); // 2 gentle recommendations for today

  const handleToggleReminder = (id) => {
    playGentleChime();
    toggleReminder(id);
  };

  return (
    <div className="container mt-6 mb-8">
      {/* Warm Welcome Banner */}
      <div
        className="card card-highlight mb-6"
        style={{
          padding: '2rem',
          borderRadius: 'var(--radius-xl)',
          position: 'relative',
          overflow: 'hidden'
        }}
      >
        <div style={{ position: 'relative', zIndex: 2 }}>
          <div className="flex items-center gap-2 mb-2">
            <span style={{ fontSize: '1.75rem' }}>{userRegion.symbol}</span>
            <span className="badge badge-blue" style={{ fontSize: 'var(--font-size-sm)' }}>
              {userRegion.name} • {currentUser?.language || 'Assamese'}
            </span>
          </div>

          <h1 style={{ color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
            {getGreeting()}, {currentUser?.name || 'Bhaben'}
          </h1>
          <p style={{ fontSize: 'var(--font-size-lg)', color: 'var(--text-muted)', margin: '0 0 1.5rem', maxWidth: '650px' }}>
            {userRegion.culturalHighlights.gentleProverb}
          </p>

          {/* Prominent Voice Companion "Tap to Talk" Button */}
          <div className="flex items-center gap-4 flex-wrap">
            <button
              className="btn btn-voice"
              onClick={() => setShowVoice(true)}
              aria-label="Tap to talk with Voice Companion"
            >
              <Mic size={28} />
              <span>Tap to Talk</span>
            </button>

            <span style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
              Ask anything in your preferred language
            </span>
          </div>
        </div>
      </div>

      {/* Main 2-Column Layout */}
      <div className="grid grid-cols-2 md-grid-cols-1 gap-6 mb-8">
        {/* Today's Recommended Activities */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <div className="card-header">
            <div>
              <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--primary-900)', margin: 0 }}>
                Today&apos;s Activities
              </h2>
              <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                Relaxed mental exercises for today
              </p>
            </div>
            <button
              className="btn btn-outline"
              style={{ minHeight: '40px', padding: '0.4rem 1rem', fontSize: 'var(--font-size-sm)' }}
              onClick={() => onNavigateTab('activities')}
            >
              View All
            </button>
          </div>

          <div className="flex flex-col gap-3">
            {todaysActivities.map((act) => (
              <div
                key={act.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '1.25rem',
                  backgroundColor: 'var(--bg-app)',
                  borderRadius: 'var(--radius-lg)',
                  border: '1.5px solid var(--border-subtle)'
                }}
              >
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="badge badge-blue" style={{ fontSize: '0.75rem' }}>
                      {act.category}
                    </span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-subtle)' }}>
                      {act.estimatedMinutes}
                    </span>
                  </div>
                  <h3 style={{ margin: '0 0 0.25rem', fontSize: 'var(--font-size-base)', color: 'var(--text-main)' }}>
                    {act.title}
                  </h3>
                  <p style={{ margin: 0, fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                    {act.description}
                  </p>
                </div>

                <button
                  className="btn btn-primary"
                  style={{ minHeight: '46px', padding: '0.5rem 1.25rem', flexShrink: 0 }}
                  onClick={() => onStartActivity(act.id)}
                >
                  <Play size={16} fill="#FFFFFF" />
                  <span>Start</span>
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Today's Reminders */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <div className="card-header">
            <div>
              <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--primary-900)', margin: 0 }}>
                Today&apos;s Care Schedule
              </h2>
              <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                {pendingReminders.length > 0
                  ? `${pendingReminders.length} reminder${pendingReminders.length > 1 ? 's' : ''} remaining`
                  : 'All reminders completed for now!'}
              </p>
            </div>
            <button
              className="btn btn-outline"
              style={{ minHeight: '40px', padding: '0.4rem 1rem', fontSize: 'var(--font-size-sm)' }}
              onClick={() => onNavigateTab('reminders')}
            >
              See All
            </button>
          </div>

          <div className="flex flex-col gap-3">
            {reminders.slice(0, 3).map((rem) => {
              const isDone = rem.completed;

              return (
                <div
                  key={rem.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '1rem 1.25rem',
                    backgroundColor: isDone ? '#F8FAFC' : '#FFFFFF',
                    borderRadius: 'var(--radius-md)',
                    border: `1.5px solid ${isDone ? 'var(--border-subtle)' : 'var(--primary-200)'}`,
                    borderLeft: `5px solid ${isDone ? 'var(--accent-emerald)' : 'var(--primary-600)'}`
                  }}
                >
                  <div className="flex items-center gap-3">
                    <button
                      style={{
                        background: 'none',
                        border: 'none',
                        cursor: 'pointer',
                        color: isDone ? 'var(--accent-emerald)' : 'var(--border-color)',
                        padding: 0
                      }}
                      onClick={() => handleToggleReminder(rem.id)}
                      aria-label={isDone ? `Mark ${rem.title} pending` : `Mark ${rem.title} complete`}
                    >
                      {isDone ? <CheckCircle2 size={32} /> : <Circle size={32} />}
                    </button>
                    <div>
                      <div
                        style={{
                          fontWeight: 700,
                          fontSize: 'var(--font-size-base)',
                          color: isDone ? 'var(--text-subtle)' : 'var(--text-main)',
                          textDecoration: isDone ? 'line-through' : 'none'
                        }}
                      >
                        {rem.title}
                      </div>
                      <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)' }}>
                        🕒 {rem.time} • {rem.category}
                      </div>
                    </div>
                  </div>

                  <button
                    className={`btn ${isDone ? 'btn-outline' : 'btn-secondary'}`}
                    style={{ minHeight: '38px', padding: '0.3rem 0.8rem', fontSize: 'var(--font-size-sm)' }}
                    onClick={() => handleToggleReminder(rem.id)}
                  >
                    {isDone ? 'Done' : 'Check Off'}
                  </button>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Gentle Progress Snapshot */}
      <div
        className="card"
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '1.5rem 2rem',
          backgroundColor: '#FFFFFF',
          border: '1.5px solid var(--border-subtle)'
        }}
      >
        <div className="flex items-center gap-4">
          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '50%',
              backgroundColor: '#DCFCE7',
              color: '#15803D',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}
          >
            <Sparkles size={30} />
          </div>
          <div>
            <h3 style={{ margin: '0 0 0.25rem', color: 'var(--text-main)' }}>
              Weekly Consistency: Strong & Steady
            </h3>
            <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)' }}>
              You have engaged in {activityResults.length + 8} activities this week. Keep up the warm, gentle flow.
            </p>
          </div>
        </div>

        <button
          className="btn btn-outline"
          onClick={() => onNavigateTab('progress')}
        >
          <span>View Progress</span>
          <ArrowRight size={18} />
        </button>
      </div>

      {/* Voice Companion Dialog */}
      <VoiceCompanionModal
        isOpen={showVoice}
        onClose={() => setShowVoice(false)}
        onNavigateTab={(tab) => onNavigateTab(tab)}
      />
    </div>
  );
}
