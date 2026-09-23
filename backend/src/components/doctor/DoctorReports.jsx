import React, { useState } from 'react';
import {
  FileText,
  Download,
  Printer,
  Share2,
  CheckCircle2,
  Calendar,
  User,
  Activity,
  Heart
} from 'lucide-react';
import { useData } from '../../context/DataContext';

export function DoctorReports({ selectedPatient }) {
  const { activityResults, dailyNotes, reminders } = useData();
  const [downloadSuccess, setDownloadSuccess] = useState(false);

  const patient = selectedPatient || {
    name: 'Bhaben Borah',
    age: 72,
    gender: 'Male',
    region: 'Assam',
    language: 'Assamese',
    doctor: 'Dr. Debabrata Sarma',
    clinic: 'Guwahati Neurological Institute'
  };

  const handleDownload = () => {
    setDownloadSuccess(true);
    setTimeout(() => setDownloadSuccess(false), 3000);
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="container mt-6 mb-8">
      {/* Top Header & Actions */}
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <div>
          <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
            Clinical Report & Progress Summary
          </h1>
          <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
            Standardized tele-monitoring report for clinical review and family counseling.
          </p>
        </div>

        <div className="flex gap-2">
          <button className="btn btn-outline" onClick={handlePrint}>
            <Printer size={18} />
            <span>Print Report</span>
          </button>
          <button className="btn btn-primary" onClick={handleDownload}>
            <Download size={18} />
            <span>Download PDF Summary</span>
          </button>
        </div>
      </div>

      {downloadSuccess && (
        <div
          style={{
            backgroundColor: '#DCFCE7',
            border: '1.5px solid #86EFAC',
            borderRadius: 'var(--radius-md)',
            padding: '1rem',
            color: '#14532D',
            marginBottom: '1.5rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
            fontWeight: 600
          }}
        >
          <CheckCircle2 size={20} />
          <span>Clinical Summary PDF prepared and downloaded (Mock Export).</span>
        </div>
      )}

      {/* Printable Report Document Card */}
      <div
        className="card"
        style={{
          padding: '2.5rem',
          backgroundColor: '#FFFFFF',
          border: '2px solid var(--border-color)',
          boxShadow: 'var(--shadow-md)',
          borderRadius: 'var(--radius-lg)'
        }}
      >
        {/* Report Header */}
        <div
          style={{
            display: 'flex',
            alignItems: 'flex-start',
            justifyContent: 'space-between',
            borderBottom: '2px solid var(--primary-800)',
            paddingBottom: '1.25rem',
            marginBottom: '1.75rem'
          }}
        >
          <div>
            <h2 style={{ color: 'var(--primary-900)', margin: '0 0 0.25rem' }}>
              MindSetu — Clinical Cognitive Continuity Report
            </h2>
            <div style={{ color: 'var(--text-subtle)', fontSize: 'var(--font-size-sm)' }}>
              North Eastern Regional Cognitive Tele-Health & Geriatric Support Platform
            </div>
          </div>
          <div style={{ textAlign: 'right', fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)' }}>
            <div>Date: <strong>September 02, 2026</strong></div>
            <div>Report ID: <strong>MND-NER-2026-0841</strong></div>
          </div>
        </div>

        {/* Section 1: Patient Demographics */}
        <div style={{ marginBottom: '1.75rem' }}>
          <h3 style={{ fontSize: 'var(--font-size-base)', color: 'var(--primary-800)', borderBottom: '1px solid var(--border-subtle)', paddingBottom: '0.4rem', marginBottom: '0.75rem' }}>
            1. Patient Demographics & Regional Profile
          </h3>
          <div className="grid grid-cols-3 md-grid-cols-1 gap-3" style={{ fontSize: 'var(--font-size-sm)' }}>
            <div><strong>Name:</strong> {patient.name}</div>
            <div><strong>Age / Gender:</strong> {patient.age} Yrs / {patient.gender}</div>
            <div><strong>Region:</strong> {patient.region} ({patient.language})</div>
            <div><strong>Primary Physician:</strong> {patient.doctor || 'Dr. D. Sarma'}</div>
            <div><strong>Caregiver:</strong> Anamika Borah (Daughter)</div>
            <div><strong>Cognitive Stage:</strong> Mild Memory Support (NER-CDR 0.5)</div>
          </div>
        </div>

        {/* Section 2: Cognitive Activity Trends */}
        <div style={{ marginBottom: '1.75rem' }}>
          <h3 style={{ fontSize: 'var(--font-size-base)', color: 'var(--primary-800)', borderBottom: '1px solid var(--border-subtle)', paddingBottom: '0.4rem', marginBottom: '0.75rem' }}>
            2. Multi-Domain Cognitive Performance
          </h3>
          <div className="grid grid-cols-4 md-grid-cols-2 gap-3 mb-3">
            <div style={{ backgroundColor: 'var(--bg-app)', padding: '0.75rem', borderRadius: 'var(--radius-md)' }}>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Memory Recall</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 800, color: 'var(--primary-700)' }}>96%</div>
              <div style={{ fontSize: '0.75rem', color: '#16A34A' }}>Stable Landmark Recall</div>
            </div>
            <div style={{ backgroundColor: 'var(--bg-app)', padding: '0.75rem', borderRadius: 'var(--radius-md)' }}>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Matching & Assoc.</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 800, color: 'var(--accent-teal)' }}>90%</div>
              <div style={{ fontSize: '0.75rem', color: '#16A34A' }}>Active cultural pairing</div>
            </div>
            <div style={{ backgroundColor: 'var(--bg-app)', padding: '0.75rem', borderRadius: 'var(--radius-md)' }}>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Routine Sequencing</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 800, color: 'var(--accent-emerald)' }}>100%</div>
              <div style={{ fontSize: '0.75rem', color: '#16A34A' }}>Flawless procedural flow</div>
            </div>
            <div style={{ backgroundColor: 'var(--bg-app)', padding: '0.75rem', borderRadius: 'var(--radius-md)' }}>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Visual Attention</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 800, color: '#D97706' }}>92%</div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>Dips mildly in late afternoon</div>
            </div>
          </div>
        </div>

        {/* Section 3: Medication & Reminder Adherence */}
        <div style={{ marginBottom: '1.75rem' }}>
          <h3 style={{ fontSize: 'var(--font-size-base)', color: 'var(--primary-800)', borderBottom: '1px solid var(--border-subtle)', paddingBottom: '0.4rem', marginBottom: '0.75rem' }}>
            3. Scheduled Care & Medication Adherence
          </h3>
          <p style={{ fontSize: 'var(--font-size-sm)', margin: '0 0 0.5rem' }}>
            Adherence rate over past 14 days: <strong>94% (17 of 18 scheduled reminders verified by caregiver)</strong>.
          </p>
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)' }}>
            Morning blood pressure medication and morning tea routine are completed consistently at 8:30 AM without hesitation.
          </div>
        </div>

        {/* Section 4: Caregiver Daily Observation Log Summary */}
        <div style={{ marginBottom: '1.75rem' }}>
          <h3 style={{ fontSize: 'var(--font-size-base)', color: 'var(--primary-800)', borderBottom: '1px solid var(--border-subtle)', paddingBottom: '0.4rem', marginBottom: '0.75rem' }}>
            4. Recent Caregiver Observations
          </h3>
          <div className="flex flex-col gap-2">
            {dailyNotes.slice(0, 2).map((note) => (
              <div
                key={note.id}
                style={{
                  padding: '0.6rem 0.85rem',
                  backgroundColor: 'var(--bg-app)',
                  borderRadius: 'var(--radius-md)',
                  fontSize: 'var(--font-size-sm)'
                }}
              >
                <strong>{note.date}</strong> — Mood: {note.mood} {note.moodEmoji} • Sleep: {note.sleepQuality}
                <div style={{ fontStyle: 'italic', color: 'var(--text-muted)', marginTop: '2px' }}>
                  &ldquo;{note.observations}&rdquo;
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Section 5: Physician Signature & Disclaimer */}
        <div
          style={{
            borderTop: '1px solid var(--border-color)',
            paddingTop: '1.25rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '1rem'
          }}
        >
          <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', maxWidth: '480px' }}>
            * This report is generated by MindSetu for supportive clinical tracking. It does not replace comprehensive neuropsychological evaluation.
          </div>

          <div style={{ textAlign: 'right' }}>
            <div style={{ fontWeight: 700, color: 'var(--primary-900)' }}>
              Dr. Debabrata Sarma, MD
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>
              Consultant Geriatric Neurologist (NMC-NER-44821)
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
