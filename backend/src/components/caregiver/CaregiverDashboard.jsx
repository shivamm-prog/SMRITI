import React, { useState } from 'react';
import {
  Heart,
  ClipboardList,
  Clock,
  CheckCircle2,
  AlertCircle,
  Plus,
  BookOpen,
  ArrowRight,
  TrendingUp,
  User,
  ShieldCheck,
  Calendar
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';
import { DailyNotesModal } from './DailyNotesModal';
import { AddReminderModal } from './AddReminderModal';

export function CaregiverDashboard({ onNavigateTab }) {
  const { currentUser } = useAuth();
  const { reminders, dailyNotes, activityResults, verifyReminder } = useData();

  const [showNoteModal, setShowNoteModal] = useState(false);
  const [showReminderModal, setShowReminderModal] = useState(false);

  // Connected patient mock data
  const patient = {
    name: 'Bhaben Borah',
    relation: 'Father',
    age: 72,
    gender: 'Male',
    region: 'Assam',
    language: 'Assamese',
    avatar: '👴',
    doctor: 'Dr. Debabrata Sarma (Geriatric Neurologist)',
    status: 'Calm & Stable'
  };

  const completedReminders = reminders.filter(r => r.completed);
  const pendingReminders = reminders.filter(r => !r.completed);

  return (
    <div className="container mt-6 mb-8">
      {/* Top Banner */}
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <div>
          <div className="badge badge-blue mb-1">
            Caregiver Portal
          </div>
          <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
            Welcome, {currentUser?.name || 'Anamika Borah'}
          </h1>
          <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
            Caring for <strong>{patient.name}</strong> ({patient.relation}) in Guwahati, Assam.
          </p>
        </div>

        <div className="flex gap-2">
          <button className="btn btn-primary" onClick={() => setShowNoteModal(true)}>
            <Plus size={18} />
            <span>Log Daily Observation</span>
          </button>
          <button className="btn btn-secondary" onClick={() => setShowReminderModal(true)}>
            <Clock size={18} />
            <span>Add Reminder</span>
          </button>
        </div>
      </div>

      {/* Connected Patient Card */}
      <div
        className="card card-highlight mb-8"
        style={{
          padding: '1.75rem 2rem',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: '1.5rem'
        }}
      >
        <div className="flex items-center gap-4">
          <div style={{ fontSize: '3.5rem' }}>{patient.avatar}</div>
          <div>
            <div className="flex items-center gap-2 mb-1">
              <h2 style={{ margin: 0, color: 'var(--primary-900)' }}>{patient.name}</h2>
              <span className="badge badge-green">
                <ShieldCheck size={14} /> {patient.status}
              </span>
            </div>
            <div style={{ color: 'var(--text-subtle)', fontSize: 'var(--font-size-sm)' }}>
              Age {patient.age} • {patient.region} ({patient.language}) • Primary Doctor: {patient.doctor}
            </div>
          </div>
        </div>

        <div className="flex gap-4">
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)' }}>Today&apos;s Mood</div>
            <div style={{ fontWeight: 700, color: 'var(--primary-900)', fontSize: 'var(--font-size-base)' }}>
              {dailyNotes[0]?.mood || 'Calm & Happy'} {dailyNotes[0]?.moodEmoji || '😊'}
            </div>
          </div>
          <div style={{ textAlign: 'right', borderLeft: '1.5px solid var(--border-color)', paddingLeft: '1rem' }}>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)' }}>Last Activity</div>
            <div style={{ fontWeight: 700, color: 'var(--accent-emerald)', fontSize: 'var(--font-size-base)' }}>
              {activityResults[0]?.activityTitle || 'Familiar Places (100%)'}
            </div>
          </div>
        </div>
      </div>

      {/* 4 Summary Stats */}
      <div className="grid grid-cols-4 md-grid-cols-2 gap-4 mb-8">
        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Activities Practiced
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--primary-700)' }}>
            {activityResults.length} / 4
          </div>
          <div style={{ fontSize: '0.8rem', color: '#16A34A', marginTop: '0.25rem' }}>
            ✓ Consistent routine
          </div>
        </div>

        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Reminders Completed
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--accent-teal)' }}>
            {completedReminders.length} / {reminders.length}
          </div>
          <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)', marginTop: '0.25rem' }}>
            {pendingReminders.length} pending today
          </div>
        </div>

        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Average Recall Score
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--accent-emerald)' }}>
            95%
          </div>
          <div style={{ fontSize: '0.8rem', color: '#16A34A', marginTop: '0.25rem' }}>
            Steady over 14 days
          </div>
        </div>

        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Daily Notes Logged
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--accent-amber)' }}>
            {dailyNotes.length}
          </div>
          <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)', marginTop: '0.25rem' }}>
            Shared with Dr. Sarma
          </div>
        </div>
      </div>

      {/* 2 Column Details: Reminder Verification & Recent Observations */}
      <div className="grid grid-cols-2 md-grid-cols-1 gap-6 mb-8">
        {/* Reminder Verification Section */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <div className="card-header">
            <div>
              <h3 style={{ margin: 0, color: 'var(--primary-900)' }}>
                Reminder Verification
              </h3>
              <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                Verify whether scheduled care was taken by senior
              </p>
            </div>
            <button
              className="btn btn-outline"
              style={{ minHeight: '36px', padding: '0.3rem 0.8rem', fontSize: '0.85rem' }}
              onClick={() => onNavigateTab('reminders')}
            >
              Manage
            </button>
          </div>

          <div className="flex flex-col gap-3">
            {reminders.map((rem) => (
              <div
                key={rem.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '0.85rem 1rem',
                  backgroundColor: rem.completed ? '#F0FDF4' : 'var(--bg-app)',
                  borderRadius: 'var(--radius-md)',
                  border: `1.5px solid ${rem.completed ? '#86EFAC' : 'var(--border-subtle)'}`
                }}
              >
                <div>
                  <div style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: 'var(--font-size-sm)' }}>
                    {rem.title}
                  </div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>
                    {rem.time} • {rem.category} {rem.completedAt && `• ${rem.completedAt}`}
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  {rem.verifiedByCaregiver ? (
                    <span className="badge badge-green" style={{ fontSize: '0.75rem' }}>
                      <CheckCircle2 size={13} /> Verified
                    </span>
                  ) : rem.completed ? (
                    <button
                      className="btn btn-secondary"
                      style={{ minHeight: '34px', padding: '0.25rem 0.65rem', fontSize: '0.8rem' }}
                      onClick={() => verifyReminder(rem.id)}
                    >
                      Verify Now
                    </button>
                  ) : (
                    <span className="badge badge-pending" style={{ fontSize: '0.75rem' }}>
                      Pending Senior
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Daily Observation Notes Section */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <div className="card-header">
            <div>
              <h3 style={{ margin: 0, color: 'var(--primary-900)' }}>
                Caregiver Daily Notes
              </h3>
              <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                Recent mood, sleep, and behavioral observations
              </p>
            </div>
            <button
              className="btn btn-outline"
              style={{ minHeight: '36px', padding: '0.3rem 0.8rem', fontSize: '0.85rem' }}
              onClick={() => onNavigateTab('notes')}
            >
              All Notes
            </button>
          </div>

          <div className="flex flex-col gap-3">
            {dailyNotes.slice(0, 2).map((note) => (
              <div
                key={note.id}
                style={{
                  backgroundColor: 'var(--bg-app)',
                  borderRadius: 'var(--radius-md)',
                  padding: '1rem',
                  border: '1.5px solid var(--border-subtle)'
                }}
              >
                <div className="flex items-center justify-between mb-1">
                  <span style={{ fontWeight: 700, color: 'var(--primary-900)', fontSize: 'var(--font-size-sm)' }}>
                    {note.moodEmoji} {note.mood}
                  </span>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>
                    {note.date}
                  </span>
                </div>
                <div style={{ fontSize: '0.85rem', color: 'var(--text-main)', marginBottom: '0.35rem' }}>
                  <strong>Sleep:</strong> {note.sleepQuality} • <strong>Appetite:</strong> {note.appetite}
                </div>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', margin: 0 }}>
                  &ldquo;{note.observations}&rdquo;
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Caregiver Resources Teaser */}
      <div
        className="card"
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '1.5rem 2rem',
          backgroundColor: '#EFF6FF',
          borderColor: 'var(--primary-200)'
        }}
      >
        <div className="flex items-center gap-3">
          <BookOpen size={32} color="var(--primary-700)" />
          <div>
            <h4 style={{ margin: '0 0 0.2rem', color: 'var(--primary-900)' }}>
              Caregiver Support & Dementia Resources for NER Families
            </h4>
            <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--primary-800)' }}>
              Helpful tips on gentle communication, managing sunset restlessness, and regional elder helplines.
            </p>
          </div>
        </div>

        <button className="btn btn-primary" onClick={() => onNavigateTab('resources')}>
          <span>Read Resources</span>
          <ArrowRight size={18} />
        </button>
      </div>

      {/* Modals */}
      <DailyNotesModal isOpen={showNoteModal} onClose={() => setShowNoteModal(false)} />
      <AddReminderModal isOpen={showReminderModal} onClose={() => setShowReminderModal(false)} />
    </div>
  );
}
