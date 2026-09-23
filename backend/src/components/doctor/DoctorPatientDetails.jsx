import React, { useState } from 'react';
import {
  ArrowLeft,
  Calendar,
  FileText,
  TrendingUp,
  CheckCircle2,
  Clock,
  Sparkles,
  ClipboardList,
  AlertTriangle
} from 'lucide-react';
import { useData } from '../../context/DataContext';

export function DoctorPatientDetails({ patient, onBack, onGenerateReport }) {
  const { activityResults, dailyNotes, reminders } = useData();
  const [doctorNote, setDoctorNote] = useState('');
  const [noteSaved, setNoteSaved] = useState(false);

  const handleSaveNote = (e) => {
    e.preventDefault();
    if (!doctorNote.trim()) return;
    setNoteSaved(true);
    setTimeout(() => setNoteSaved(false), 2500);
  };

  return (
    <div className="container mt-6 mb-8">
      {/* Top Header */}
      <div className="flex items-center justify-between mb-6">
        <button className="btn btn-outline" onClick={onBack}>
          <ArrowLeft size={18} />
          <span>Back to Registry</span>
        </button>

        <button className="btn btn-primary" onClick={() => onGenerateReport(patient)}>
          <FileText size={18} />
          <span>Export Clinical Summary</span>
        </button>
      </div>

      {/* Patient Header Card */}
      <div
        className="card card-highlight mb-6"
        style={{ padding: '1.75rem 2rem' }}
      >
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div className="flex items-center gap-4">
            <div style={{ fontSize: '3.5rem' }}>👴</div>
            <div>
              <div className="flex items-center gap-3">
                <h1 style={{ margin: 0, fontSize: 'var(--font-size-2xl)', color: 'var(--primary-900)' }}>
                  {patient?.name || 'Bhaben Borah'}
                </h1>
                <span className="badge badge-green">Steady Continuity</span>
              </div>
              <p style={{ margin: '0.25rem 0 0', color: 'var(--text-subtle)', fontSize: 'var(--font-size-sm)' }}>
                Age 72 • Male • {patient?.region || 'Assam'} ({patient?.language || 'Assamese'}) • Caregiver: Anamika Borah (Daughter)
              </p>
            </div>
          </div>

          <div className="flex gap-4">
            <div style={{ textAlign: 'center' }}>
              <div style={{ fontSize: '1.75rem', fontWeight: 800, color: 'var(--primary-700)' }}>95%</div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Cognitive Trend</div>
            </div>
            <div style={{ textAlign: 'center', borderLeft: '1.5px solid var(--border-color)', paddingLeft: '1rem' }}>
              <div style={{ fontSize: '1.75rem', fontWeight: 800, color: 'var(--accent-emerald)' }}>94%</div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Med Adherence</div>
            </div>
          </div>
        </div>
      </div>

      {/* 2 Column Details: Cognitive Trends & Caregiver Notes */}
      <div className="grid grid-cols-2 md-grid-cols-1 gap-6 mb-8">
        {/* Cognitive Trends */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.25rem' }}>
            Cognitive Domain Performance
          </h3>
          <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '1.5rem' }}>
            Multi-session assessment across 4 functional domains
          </p>

          <div className="flex flex-col gap-4">
            <div>
              <div className="flex justify-between mb-1" style={{ fontSize: 'var(--font-size-sm)', fontWeight: 600 }}>
                <span>🧠 Semantic Memory & Recall (NER Landmarks)</span>
                <span style={{ color: 'var(--primary-700)' }}>96%</span>
              </div>
              <div style={{ height: '8px', backgroundColor: 'var(--border-subtle)', borderRadius: '4px' }}>
                <div style={{ width: '96%', height: '100%', backgroundColor: 'var(--primary-600)', borderRadius: '4px' }} />
              </div>
            </div>

            <div>
              <div className="flex justify-between mb-1" style={{ fontSize: 'var(--font-size-sm)', fontWeight: 600 }}>
                <span>✨ Cultural Association & Matching</span>
                <span style={{ color: 'var(--accent-teal)' }}>90%</span>
              </div>
              <div style={{ height: '8px', backgroundColor: 'var(--border-subtle)', borderRadius: '4px' }}>
                <div style={{ width: '90%', height: '100%', backgroundColor: 'var(--accent-teal)', borderRadius: '4px' }} />
              </div>
            </div>

            <div>
              <div className="flex justify-between mb-1" style={{ fontSize: 'var(--font-size-sm)', fontWeight: 600 }}>
                <span>☕ Procedural Routine Sequencing (Making Tea)</span>
                <span style={{ color: 'var(--accent-emerald)' }}>100%</span>
              </div>
              <div style={{ height: '8px', backgroundColor: 'var(--border-subtle)', borderRadius: '4px' }}>
                <div style={{ width: '100%', height: '100%', backgroundColor: 'var(--accent-emerald)', borderRadius: '4px' }} />
              </div>
            </div>

            <div>
              <div className="flex justify-between mb-1" style={{ fontSize: 'var(--font-size-sm)', fontWeight: 600 }}>
                <span>🌸 Visual Attention & Flora Spotting</span>
                <span style={{ color: '#D97706' }}>92%</span>
              </div>
              <div style={{ height: '8px', backgroundColor: 'var(--border-subtle)', borderRadius: '4px' }}>
                <div style={{ width: '92%', height: '100%', backgroundColor: '#D97706', borderRadius: '4px' }} />
              </div>
            </div>
          </div>
        </div>

        {/* Caregiver Observation Correlation */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.25rem' }}>
            Caregiver Daily Observations Log
          </h3>
          <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '1.25rem' }}>
            Recent entries from daughter Anamika
          </p>

          <div className="flex flex-col gap-3" style={{ maxHeight: '280px', overflowY: 'auto' }}>
            {dailyNotes.map((note) => (
              <div
                key={note.id}
                style={{
                  backgroundColor: 'var(--bg-app)',
                  borderRadius: 'var(--radius-md)',
                  padding: '0.85rem 1rem',
                  border: '1px solid var(--border-subtle)'
                }}
              >
                <div className="flex items-center justify-between mb-1">
                  <span style={{ fontWeight: 700, fontSize: 'var(--font-size-sm)', color: 'var(--text-main)' }}>
                    {note.moodEmoji} {note.mood}
                  </span>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>
                    {note.date}
                  </span>
                </div>
                <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                  <strong>Sleep:</strong> {note.sleepQuality} • <strong>Appetite:</strong> {note.appetite}
                </div>
                <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)', fontStyle: 'italic', marginTop: '2px' }}>
                  &ldquo;{note.observations}&rdquo;
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Doctor Clinical Notes */}
      <div className="card" style={{ padding: '1.75rem' }}>
        <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
          Physician Consultation & Progress Notes
        </h3>

        {noteSaved && (
          <div className="badge badge-green mb-3">
            ✓ Clinical note recorded in local patient chart
          </div>
        )}

        <form onSubmit={handleSaveNote}>
          <div className="form-group">
            <textarea
              className="form-textarea"
              value={doctorNote}
              onChange={(e) => setDoctorNote(e.target.value)}
              placeholder="Record physician clinical observations, recommendations for family caregiver, or medication review..."
              rows={3}
            />
          </div>
          <button type="submit" className="btn btn-primary">
            Save Clinical Note
          </button>
        </form>
      </div>
    </div>
  );
}
