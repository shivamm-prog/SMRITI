import React, { useState } from 'react';
import { CheckCircle2, Circle, Clock, Pill, Coffee, Utensils, Footprints, Moon, Plus } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAccessibility } from '../../context/AccessibilityContext';

export function PatientReminders({ onOpenAddReminder }) {
  const { reminders, toggleReminder } = useData();
  const { playGentleChime } = useAccessibility();
  const [filter, setFilter] = useState('all'); // 'all' | 'pending' | 'completed'

  const handleToggle = (id) => {
    playGentleChime();
    toggleReminder(id);
  };

  const filteredReminders = reminders.filter(r => {
    if (filter === 'pending') return !r.completed;
    if (filter === 'completed') return r.completed;
    return true;
  });

  const renderCategoryIcon = (category) => {
    switch (category) {
      case 'Medicine': return <Pill size={22} color="var(--primary-700)" />;
      case 'Hydration': return <Coffee size={22} color="var(--accent-teal)" />;
      case 'Meal': return <Utensils size={22} color="var(--accent-amber)" />;
      case 'Daily Activity': return <Footprints size={22} color="var(--accent-emerald)" />;
      default: return <Clock size={22} color="var(--primary-600)" />;
    }
  };

  return (
    <div className="container mt-6 mb-8">
      {/* Title & Filter Tabs */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
            Daily Reminders & Care
          </h1>
          <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
            Simple reminders for medicines, warm tea, meals, and garden walks.
          </p>
        </div>

        {onOpenAddReminder && (
          <button className="btn btn-primary" onClick={onOpenAddReminder}>
            <Plus size={18} />
            <span>Add Reminder</span>
          </button>
        )}
      </div>

      {/* Filter Pills */}
      <div className="flex gap-2 mb-6">
        <button
          className={`btn ${filter === 'all' ? 'btn-primary' : 'btn-outline'}`}
          style={{ minHeight: '44px', padding: '0.4rem 1.25rem' }}
          onClick={() => setFilter('all')}
        >
          All ({reminders.length})
        </button>
        <button
          className={`btn ${filter === 'pending' ? 'btn-primary' : 'btn-outline'}`}
          style={{ minHeight: '44px', padding: '0.4rem 1.25rem' }}
          onClick={() => setFilter('pending')}
        >
          Pending ({reminders.filter(r => !r.completed).length})
        </button>
        <button
          className={`btn ${filter === 'completed' ? 'btn-primary' : 'btn-outline'}`}
          style={{ minHeight: '44px', padding: '0.4rem 1.25rem' }}
          onClick={() => setFilter('completed')}
        >
          Done ({reminders.filter(r => r.completed).length})
        </button>
      </div>

      {/* Reminders List */}
      {filteredReminders.length === 0 ? (
        <div
          className="card text-center"
          style={{ padding: '3rem 1.5rem', maxWidth: '500px', margin: '2rem auto' }}
        >
          <div style={{ fontSize: '3rem', marginBottom: '0.5rem' }}>✨</div>
          <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.25rem' }}>
            No Reminders in this list
          </h3>
          <p style={{ color: 'var(--text-muted)', margin: 0 }}>
            Everything is calm and up to date!
          </p>
        </div>
      ) : (
        <div className="flex flex-col gap-4">
          {filteredReminders.map((rem) => {
            const isDone = rem.completed;

            return (
              <div
                key={rem.id}
                className="card"
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '1.25rem 1.5rem',
                  backgroundColor: isDone ? '#F8FAFC' : '#FFFFFF',
                  borderColor: isDone ? 'var(--border-subtle)' : 'var(--primary-300)',
                  borderLeft: `6px solid ${isDone ? 'var(--accent-emerald)' : 'var(--primary-600)'}`,
                  opacity: isDone ? 0.85 : 1
                }}
              >
                <div className="flex items-center gap-4" style={{ flex: 1 }}>
                  {/* Big Touch Checkbox */}
                  <button
                    className="btn-icon-only"
                    style={{
                      background: 'none',
                      border: 'none',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: isDone ? 'var(--accent-emerald)' : 'var(--border-color)',
                      flexShrink: 0
                    }}
                    onClick={() => handleToggle(rem.id)}
                    aria-label={isDone ? `Mark ${rem.title} as incomplete` : `Mark ${rem.title} as complete`}
                  >
                    {isDone ? (
                      <CheckCircle2 size={36} />
                    ) : (
                      <Circle size={36} />
                    )}
                  </button>

                  <div style={{ flex: 1 }}>
                    <div className="flex items-center gap-2 mb-1">
                      {renderCategoryIcon(rem.category)}
                      <span className="badge badge-blue" style={{ fontSize: '0.75rem' }}>
                        {rem.category}
                      </span>
                      <span className="badge badge-amber" style={{ fontSize: '0.75rem' }}>
                        <Clock size={12} /> {rem.time}
                      </span>
                      {rem.syncStatus === 'Pending Sync' && (
                        <span className="badge badge-pending" style={{ fontSize: '0.75rem' }}>
                          Pending Sync
                        </span>
                      )}
                    </div>

                    <h3
                      style={{
                        margin: '0 0 0.25rem',
                        color: isDone ? 'var(--text-subtle)' : 'var(--text-main)',
                        textDecoration: isDone ? 'line-through' : 'none',
                        fontSize: 'var(--font-size-lg)'
                      }}
                    >
                      {rem.title}
                    </h3>

                    <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)' }}>
                      {rem.instructions}
                    </p>

                    {isDone && rem.completedAt && (
                      <div style={{ fontSize: '0.8rem', color: '#16A34A', fontWeight: 600, marginTop: '4px' }}>
                        ✓ Completed ({rem.completedAt})
                      </div>
                    )}
                  </div>
                </div>

                {/* Status Action Button */}
                <button
                  className={`btn ${isDone ? 'btn-outline' : 'btn-primary'}`}
                  style={{ minHeight: '48px', padding: '0.5rem 1.25rem', flexShrink: 0 }}
                  onClick={() => handleToggle(rem.id)}
                >
                  {isDone ? 'Mark Pending' : 'Mark Done'}
                </button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
