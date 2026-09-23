import React from 'react';
import {
  TrendingUp,
  Award,
  Sparkles,
  Calendar,
  CheckCircle2,
  Heart,
  Brain,
  Smile
} from 'lucide-react';
import { useData } from '../../context/DataContext';

export function PatientProgress() {
  const { activityResults } = useData();

  // Weekly consistency data (Mon - Sun)
  const weeklyData = [
    { day: 'Mon', completed: 2, height: '65%' },
    { day: 'Tue', completed: 3, height: '90%' },
    { day: 'Wed', completed: 1, height: '40%' },
    { day: 'Thu', completed: 2, height: '70%' },
    { day: 'Fri', completed: 3, height: '100%' },
    { day: 'Sat', completed: 2, height: '65%' },
    { day: 'Sun', completed: 2, height: '65%' }
  ];

  // Areas practiced aggregation
  const categories = [
    { name: 'Memory Recall', count: 4, color: '#2563EB', icon: '🧠' },
    { name: 'Cultural Matching', count: 3, color: '#0D9488', icon: '✨' },
    { name: 'Routine Sequencing', count: 3, color: '#7C3AED', icon: '☕' },
    { name: 'Nature Attention', count: 2, color: '#0284C7', icon: '🌸' }
  ];

  return (
    <div className="container mt-6 mb-8">
      {/* Title */}
      <div className="mb-6">
        <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
          Your Activity Journey & Progress
        </h1>
        <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
          Celebrating daily continuity, positive focus, and peaceful mental practice.
        </p>
      </div>

      {/* Reassuring Positive Banner */}
      <div
        style={{
          backgroundColor: '#ECFDF5',
          border: '1.5px solid #A7F3D0',
          borderRadius: 'var(--radius-lg)',
          padding: '1.25rem 1.5rem',
          display: 'flex',
          alignItems: 'center',
          gap: '1rem',
          marginBottom: '2rem'
        }}
      >
        <div style={{ fontSize: '2.5rem' }}>🌱</div>
        <div>
          <h3 style={{ color: '#065F46', margin: '0 0 0.25rem', fontSize: 'var(--font-size-lg)' }}>
            Consistent Daily Practice Keeps Mind & Spirit Serene
          </h3>
          <p style={{ color: '#047857', margin: 0, fontSize: 'var(--font-size-base)' }}>
            Every gentle activity strengthens familiar memories, stimulates natural focus, and brings calm joy.
          </p>
        </div>
      </div>

      {/* Top Summary Metric Cards */}
      <div className="grid grid-cols-3 md-grid-cols-1 gap-4 mb-8">
        <div className="card">
          <div className="flex items-center justify-between mb-2">
            <span style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', fontWeight: 600 }}>
              Activities Practiced
            </span>
            <span className="badge badge-blue">This Week</span>
          </div>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: 'var(--primary-700)' }}>
            {activityResults.length + 8}
          </div>
          <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)', margin: 0 }}>
            Gentle sessions completed with ease
          </p>
        </div>

        <div className="card">
          <div className="flex items-center justify-between mb-2">
            <span style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', fontWeight: 600 }}>
              Activity Trend
            </span>
            <span className="badge badge-green">Steady</span>
          </div>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: 'var(--accent-emerald)' }}>
            94%
          </div>
          <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)', margin: 0 }}>
            Average positive performance score
          </p>
        </div>

        <div className="card">
          <div className="flex items-center justify-between mb-2">
            <span style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', fontWeight: 600 }}>
              Consistency Streak
            </span>
            <span className="badge badge-amber">Warm Streak</span>
          </div>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: 'var(--accent-amber)' }}>
            6 Days
          </div>
          <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)', margin: 0 }}>
            Engaged peacefully every morning
          </p>
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-2 md-grid-cols-1 gap-6 mb-8">
        {/* Weekly Progress Bar Chart */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <h3 style={{ color: 'var(--text-main)', marginBottom: '0.25rem' }}>
            Weekly Activity Frequency
          </h3>
          <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '1.5rem' }}>
            Number of calm sessions practiced each day of the week
          </p>

          <div
            style={{
              height: '180px',
              display: 'flex',
              alignItems: 'flex-end',
              justifyContent: 'space-between',
              paddingTop: '1rem',
              borderBottom: '2px solid var(--border-color)',
              paddingBottom: '0.5rem'
            }}
          >
            {weeklyData.map((d) => (
              <div key={d.day} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', flex: 1 }}>
                <div
                  style={{
                    width: '32px',
                    height: d.height,
                    backgroundColor: 'var(--primary-500)',
                    borderRadius: '6px 6px 0 0',
                    transition: 'height 400ms ease',
                    marginBottom: '0.5rem',
                    position: 'relative'
                  }}
                  title={`${d.completed} activities`}
                />
                <span style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-muted)' }}>
                  {d.day}
                </span>
              </div>
            ))}
          </div>
          <div className="text-center mt-3" style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
            Daily consistency is higher in the peaceful morning hours (8:00 AM – 10:30 AM).
          </div>
        </div>

        {/* Areas Practiced Breakdown */}
        <div className="card" style={{ padding: '1.75rem' }}>
          <h3 style={{ color: 'var(--text-main)', marginBottom: '0.25rem' }}>
            Cognitive Areas Practiced
          </h3>
          <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '1.5rem' }}>
            Varied exercises support diverse brain regions
          </p>

          <div className="flex flex-col gap-4">
            {categories.map((cat) => (
              <div key={cat.name}>
                <div className="flex items-center justify-between mb-1">
                  <span style={{ fontWeight: 600, color: 'var(--text-main)', fontSize: 'var(--font-size-sm)' }}>
                    {cat.icon} {cat.name}
                  </span>
                  <span style={{ fontSize: 'var(--font-size-sm)', fontWeight: 700, color: cat.color }}>
                    {cat.count} Sessions
                  </span>
                </div>
                <div
                  style={{
                    height: '10px',
                    backgroundColor: 'var(--border-subtle)',
                    borderRadius: '5px',
                    overflow: 'hidden'
                  }}
                >
                  <div
                    style={{
                      height: '100%',
                      width: `${cat.count * 25}%`,
                      backgroundColor: cat.color,
                      borderRadius: '5px'
                    }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recent Activity Log */}
      <div className="card" style={{ padding: '1.75rem' }}>
        <h3 style={{ color: 'var(--text-main)', marginBottom: '1.25rem' }}>
          Recent Activity Journal
        </h3>

        <div className="flex flex-col gap-3">
          {activityResults.map((res) => (
            <div
              key={res.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '1rem 1.25rem',
                backgroundColor: 'var(--bg-app)',
                borderRadius: 'var(--radius-md)',
                border: '1.5px solid var(--border-subtle)'
              }}
            >
              <div className="flex items-center gap-3">
                <div
                  style={{
                    width: '42px',
                    height: '42px',
                    borderRadius: '50%',
                    backgroundColor: '#DCFCE7',
                    color: '#15803D',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}
                >
                  <CheckCircle2 size={24} />
                </div>
                <div>
                  <h4 style={{ margin: '0 0 0.2rem', color: 'var(--text-main)', fontSize: 'var(--font-size-base)' }}>
                    {res.activityTitle}
                  </h4>
                  <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
                    {res.completedAt} • {res.category}
                  </div>
                </div>
              </div>

              <div className="text-right">
                <span className="badge badge-green" style={{ fontSize: '0.9rem', padding: '0.3rem 0.75rem' }}>
                  {res.score}% Score
                </span>
                <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-muted)', marginTop: '4px' }}>
                  {res.feedback}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
