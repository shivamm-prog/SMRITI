import React, { useState } from 'react';
import {
  Brain,
  Sparkles,
  ListOrdered,
  Eye,
  Music,
  BookOpen,
  Play,
  Clock,
  CheckCircle2,
  Award
} from 'lucide-react';
import { ACTIVITIES } from '../../data/activitiesData';
import { MemoryRecallGame } from './MemoryRecallGame';
import { ObjectMatchingGame } from './ObjectMatchingGame';
import { DailySequenceGame } from './DailySequenceGame';
import { NatureAttentionGame } from './NatureAttentionGame';
import { InstrumentGame } from './InstrumentGame';
import { LanguageWordGame } from './LanguageWordGame';
import { useData } from '../../context/DataContext';

export function ActivityRunner({ initialActivityId = null }) {
  const [activeActivityId, setActiveActivityId] = useState(initialActivityId);
  const { activityResults } = useData();

  const selectedActivity = ACTIVITIES.find(a => a.id === activeActivityId);

  const renderIcon = (name, size = 24, color = 'currentColor') => {
    switch (name) {
      case 'Brain': return <Brain size={size} color={color} />;
      case 'Sparkles': return <Sparkles size={size} color={color} />;
      case 'ListOrdered': return <ListOrdered size={size} color={color} />;
      case 'Eye': return <Eye size={size} color={color} />;
      case 'Music': return <Music size={size} color={color} />;
      case 'BookOpen': return <BookOpen size={size} color={color} />;
      default: return <Brain size={size} color={color} />;
    }
  };

  // If an activity is selected, render its playable interface
  if (selectedActivity) {
    const handleBack = () => setActiveActivityId(null);

    switch (selectedActivity.id) {
      case 'act-memory-recall':
        return <MemoryRecallGame activityData={selectedActivity} onBack={handleBack} />;
      case 'act-matching':
        return <ObjectMatchingGame activityData={selectedActivity} onBack={handleBack} />;
      case 'act-sequence':
        return <DailySequenceGame activityData={selectedActivity} onBack={handleBack} />;
      case 'act-attention':
        return <NatureAttentionGame activityData={selectedActivity} onBack={handleBack} />;
      case 'act-recognition':
        return <InstrumentGame activityData={selectedActivity} onBack={handleBack} />;
      case 'act-language':
        return <LanguageWordGame activityData={selectedActivity} onBack={handleBack} />;
      default:
        return <MemoryRecallGame activityData={selectedActivity} onBack={handleBack} />;
    }
  }

  // Otherwise, render the Activities Catalog
  return (
    <div className="container mt-6 mb-8">
      {/* Title & Introduction */}
      <div className="mb-6 text-center" style={{ maxWidth: '700px', margin: '0 auto 2rem' }}>
        <h1 style={{ marginBottom: '0.5rem', color: 'var(--primary-900)' }}>
          Gentle Cognitive Activities
        </h1>
        <p style={{ fontSize: 'var(--font-size-lg)', color: 'var(--text-muted)' }}>
          Relaxed, culturally familiar games designed to exercise memory, attention, and routine sequencing without pressure.
        </p>
      </div>

      {/* Activities Grid */}
      <div className="grid grid-cols-2 md-grid-cols-1 gap-6">
        {ACTIVITIES.map((act) => {
          // Check if this activity was completed previously in session
          const previousResult = activityResults.find(r => r.activityId === act.id);

          return (
            <div
              key={act.id}
              className="card card-interactive"
              style={{
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
                padding: '1.75rem',
                borderLeft: `6px solid ${act.color}`
              }}
              onClick={() => setActiveActivityId(act.id)}
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <div
                    style={{
                      width: '52px',
                      height: '52px',
                      borderRadius: 'var(--radius-md)',
                      backgroundColor: act.bgLight,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    {renderIcon(act.icon, 28, act.color)}
                  </div>

                  <div className="flex items-center gap-2">
                    <span className="badge badge-blue">
                      <Clock size={13} /> {act.estimatedMinutes}
                    </span>
                    {previousResult && (
                      <span className="badge badge-green">
                        <CheckCircle2 size={13} /> Practiced
                      </span>
                    )}
                  </div>
                </div>

                <h3 style={{ marginBottom: '0.4rem', color: 'var(--text-main)' }}>
                  {act.title}
                </h3>
                <p style={{ color: 'var(--text-muted)', marginBottom: '1.25rem', fontSize: 'var(--font-size-base)' }}>
                  {act.description}
                </p>
              </div>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  paddingTop: '1rem',
                  borderTop: '1.5px solid var(--border-subtle)'
                }}
              >
                <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                  Difficulty: <strong style={{ color: 'var(--text-main)' }}>{act.difficulty}</strong>
                </div>

                <button
                  className="btn btn-primary"
                  style={{ minHeight: '46px', padding: '0.5rem 1.25rem' }}
                  onClick={(e) => {
                    e.stopPropagation();
                    setActiveActivityId(act.id);
                  }}
                >
                  <Play size={18} fill="#FFFFFF" />
                  <span>Begin</span>
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
