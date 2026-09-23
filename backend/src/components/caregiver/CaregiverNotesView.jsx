import React, { useState } from 'react';
import { Plus, ClipboardList, Smile, Calendar, Moon, Utensils } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { DailyNotesModal } from './DailyNotesModal';

export function CaregiverNotesView() {
  const { dailyNotes } = useData();
  const [showModal, setShowModal] = useState(false);

  return (
    <div className="container mt-6 mb-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
            Daily Caregiver Observations & Notes
          </h1>
          <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
            Structured behavioral, mood, and sleep records shared with the consulting doctor.
          </p>
        </div>

        <button className="btn btn-primary" onClick={() => setShowModal(true)}>
          <Plus size={18} />
          <span>Add Observation</span>
        </button>
      </div>

      <div className="flex flex-col gap-4">
        {dailyNotes.map((note) => (
          <div
            key={note.id}
            className="card"
            style={{
              padding: '1.5rem',
              borderLeft: '5px solid var(--primary-600)'
            }}
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span style={{ fontSize: '1.75rem' }}>{note.moodEmoji || '😊'}</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: 'var(--font-size-base)', color: 'var(--text-main)' }}>
                    {note.mood}
                  </h3>
                  <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
                    Logged by {note.author} • {note.date}
                  </div>
                </div>
              </div>

              {note.syncStatus === 'Pending Sync' && (
                <span className="badge badge-pending">
                  Pending Sync
                </span>
              )}
            </div>

            <div className="grid grid-cols-2 md-grid-cols-1 gap-3 mb-3" style={{ fontSize: 'var(--font-size-sm)' }}>
              <div style={{ backgroundColor: 'var(--bg-app)', padding: '0.6rem 0.85rem', borderRadius: 'var(--radius-md)' }}>
                <strong>🌙 Sleep:</strong> {note.sleepQuality}
              </div>
              <div style={{ backgroundColor: 'var(--bg-app)', padding: '0.6rem 0.85rem', borderRadius: 'var(--radius-md)' }}>
                <strong>🍲 Appetite:</strong> {note.appetite}
              </div>
            </div>

            {note.behavior && (
              <div style={{ fontSize: 'var(--font-size-sm)', marginBottom: '0.5rem', color: 'var(--text-main)' }}>
                <strong>Communication & Behavior:</strong> {note.behavior}
              </div>
            )}

            <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)', fontStyle: 'italic' }}>
              &ldquo;{note.observations}&rdquo;
            </div>
          </div>
        ))}
      </div>

      <DailyNotesModal isOpen={showModal} onClose={() => setShowModal(false)} />
    </div>
  );
}
