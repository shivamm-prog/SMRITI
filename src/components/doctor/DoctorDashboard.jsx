import React from 'react';
import {
  Users,
  AlertCircle,
  TrendingUp,
  Activity,
  CheckCircle2,
  Clock,
  Sparkles,
  ArrowRight,
  FileText,
  ShieldCheck
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useData } from '../../context/DataContext';

export function DoctorDashboard({ onSelectPatient, onNavigateTab }) {
  const { currentUser } = useAuth();
  const { clinicalInsights, activityResults, reminders } = useData();

  // Doctor's registered patients mock roster
  const patients = [
    {
      id: 'user-pat-01',
      name: 'Bhaben Borah',
      age: 72,
      gender: 'Male',
      region: 'Assam',
      language: 'Assamese',
      caregiver: 'Anamika Borah (Daughter)',
      trend: 'Steady Positive',
      trendScore: '96%',
      adherence: '94%',
      lastActive: 'Today, 08:35 AM',
      attentionRequired: false,
      flagNote: 'Afternoon attention slightly dips if nap is skipped.'
    },
    {
      id: 'user-pat-02',
      name: 'Tongbram Ibochouba',
      age: 76,
      gender: 'Male',
      region: 'Manipur',
      language: 'Meitei (Manipuri)',
      caregiver: 'Bembem (Wife)',
      trend: 'Needs Attention',
      trendScore: '78%',
      adherence: '82%',
      lastActive: 'Yesterday, 06:15 PM',
      attentionRequired: true,
      flagNote: 'Missed 2 evening blood pressure reminders.'
    },
    {
      id: 'user-pat-03',
      name: 'Marilyn Khongwir',
      age: 69,
      gender: 'Female',
      region: 'Meghalaya',
      language: 'Khasi',
      caregiver: 'Donbok (Son)',
      trend: 'Excellent',
      trendScore: '98%',
      adherence: '100%',
      lastActive: 'Today, 09:10 AM',
      attentionRequired: false,
      flagNote: 'Very enthusiastic in musical recall activities.'
    }
  ];

  return (
    <div className="container mt-6 mb-8">
      {/* Clinician Welcome Banner */}
      <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
        <div>
          <div className="badge badge-blue mb-1">
            Clinical Tele-Monitoring Portal
          </div>
          <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
            {currentUser?.name || 'Dr. Debabrata Sarma'}
          </h1>
          <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
            Guwahati Neurological & Senior Wellness Network • NMC-NER-44821
          </p>
        </div>

        <div className="flex gap-2">
          <button className="btn btn-outline" onClick={() => onNavigateTab('insights')}>
            <Sparkles size={18} />
            <span>AI Clinical Insights</span>
          </button>
          <button className="btn btn-primary" onClick={() => onNavigateTab('reports')}>
            <FileText size={18} />
            <span>Generate Reports</span>
          </button>
        </div>
      </div>

      {/* Top 4 Metrics */}
      <div className="grid grid-cols-4 md-grid-cols-2 gap-4 mb-8">
        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Registered Patients
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--primary-700)' }}>
            14
          </div>
          <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
            Across 5 NER States
          </div>
        </div>

        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Active Today
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--accent-emerald)' }}>
            9
          </div>
          <div style={{ fontSize: '0.8rem', color: '#16A34A', marginTop: '0.25rem' }}>
            ✓ 64% completed games
          </div>
        </div>

        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Flagged for Attention
          </div>
          <div style={{ fontSize: '2rem', fontWeight: 800, color: '#DC2626' }}>
            1
          </div>
          <div style={{ fontSize: '0.8rem', color: '#B91C1C', marginTop: '0.25rem' }}>
            Reminder missed (Manipur)
          </div>
        </div>

        <div className="card">
          <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
            Sync Infrastructure
          </div>
          <div style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--accent-teal)', display: 'flex', alignItems: 'center', gap: '6px', height: '40px' }}>
            <ShieldCheck size={24} /> Online
          </div>
          <div style={{ fontSize: '0.8rem', color: 'var(--text-subtle)', marginTop: '0.25rem' }}>
            Local-first cache active
          </div>
        </div>
      </div>

      {/* Patient Registry Table */}
      <div className="card mb-8" style={{ padding: '1.75rem' }}>
        <div className="card-header">
          <div>
            <h2 style={{ fontSize: 'var(--font-size-xl)', color: 'var(--primary-900)', margin: 0 }}>
              Assigned Patient Registry
            </h2>
            <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
              Select a patient to inspect cognitive trend graphs, caregiver logs, and generate clinical summaries.
            </p>
          </div>
        </div>

        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ borderBottom: '2px solid var(--border-color)', color: 'var(--text-subtle)', fontSize: 'var(--font-size-sm)' }}>
                <th style={{ padding: '0.75rem 1rem' }}>Patient Name</th>
                <th style={{ padding: '0.75rem 1rem' }}>Region / Lang</th>
                <th style={{ padding: '0.75rem 1rem' }}>Primary Caregiver</th>
                <th style={{ padding: '0.75rem 1rem' }}>Cognitive Trend</th>
                <th style={{ padding: '0.75rem 1rem' }}>Med Adherence</th>
                <th style={{ padding: '0.75rem 1rem', textAlign: 'right' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {patients.map((p) => (
                <tr
                  key={p.id}
                  style={{
                    borderBottom: '1px solid var(--border-subtle)',
                    transition: 'background-color 150ms ease'
                  }}
                  className="card-interactive"
                  onClick={() => onSelectPatient(p)}
                >
                  <td style={{ padding: '1rem' }}>
                    <div style={{ fontWeight: 700, color: 'var(--text-main)' }}>{p.name}</div>
                    <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
                      Age {p.age} • {p.gender}
                    </div>
                  </td>

                  <td style={{ padding: '1rem', fontSize: 'var(--font-size-sm)' }}>
                    <div>{p.region}</div>
                    <div style={{ color: 'var(--text-subtle)', fontSize: 'var(--font-size-xs)' }}>{p.language}</div>
                  </td>

                  <td style={{ padding: '1rem', fontSize: 'var(--font-size-sm)' }}>
                    {p.caregiver}
                  </td>

                  <td style={{ padding: '1rem' }}>
                    <span
                      className={`badge ${p.attentionRequired ? 'badge-rose' : 'badge-green'}`}
                      style={{ fontSize: '0.8rem' }}
                    >
                      {p.trend} ({p.trendScore})
                    </span>
                  </td>

                  <td style={{ padding: '1rem', fontWeight: 600, fontSize: 'var(--font-size-sm)' }}>
                    {p.adherence}
                  </td>

                  <td style={{ padding: '1rem', textAlign: 'right' }}>
                    <button
                      className="btn btn-secondary"
                      style={{ minHeight: '36px', padding: '0.3rem 0.8rem', fontSize: '0.85rem' }}
                      onClick={(e) => {
                        e.stopPropagation();
                        onSelectPatient(p);
                      }}
                    >
                      <span>Deep Dive</span>
                      <ArrowRight size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Latest AI Clinical Pattern Highlight */}
      <div
        className="card"
        style={{
          borderLeft: '6px solid var(--primary-600)',
          padding: '1.5rem 2rem',
          backgroundColor: 'var(--primary-50)'
        }}
      >
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <Sparkles size={20} color="var(--primary-700)" />
            <h3 style={{ margin: 0, color: 'var(--primary-900)', fontSize: 'var(--font-size-base)' }}>
              Latest Pattern: Bhaben Borah (Assam)
            </h3>
          </div>
          <span className="badge badge-blue">AI-Assisted Insight</span>
        </div>

        <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-main)', margin: '0 0 0.5rem' }}>
          {clinicalInsights[0]?.summary}
        </p>

        <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontStyle: 'italic' }}>
          * {clinicalInsights[0]?.disclaimer}
        </div>
      </div>
    </div>
  );
}
