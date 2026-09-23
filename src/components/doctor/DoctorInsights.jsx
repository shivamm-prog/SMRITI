import React from 'react';
import { Sparkles, AlertCircle, CheckCircle2, TrendingUp, Clock, Info } from 'lucide-react';
import { useData } from '../../context/DataContext';

export function DoctorInsights() {
  const { clinicalInsights } = useData();

  return (
    <div className="container mt-6 mb-8">
      {/* Title */}
      <div className="mb-6">
        <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
          AI-Assisted Cognitive Insights
        </h1>
        <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
          Pattern detection across daily cognitive tasks, routine adherence, and caregiver observations.
        </p>
      </div>

      {/* Mandatory Non-Diagnostic Clinical Disclaimer Banner */}
      <div
        style={{
          backgroundColor: '#EFF6FF',
          border: '2px solid var(--primary-400)',
          borderRadius: 'var(--radius-lg)',
          padding: '1.25rem 1.5rem',
          display: 'flex',
          alignItems: 'center',
          gap: '1rem',
          marginBottom: '2rem'
        }}
      >
        <Info size={28} color="var(--primary-700)" style={{ flexShrink: 0 }} />
        <div>
          <h4 style={{ margin: '0 0 0.2rem', color: 'var(--primary-900)' }}>
            Clinical Decision Support Notice
          </h4>
          <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--primary-800)' }}>
            MindSetu provides statistical trend analysis and continuity markers. <strong>No automated medical diagnoses are generated.</strong> All diagnostic evaluations and therapeutic interventions remain the sole professional responsibility of the attending clinician.
          </p>
        </div>
      </div>

      {/* Insights Cards */}
      <div className="flex flex-col gap-6">
        {clinicalInsights.map((ins) => {
          const isPositive = ins.severity === 'positive';

          return (
            <div
              key={ins.id}
              className="card"
              style={{
                padding: '1.75rem',
                borderLeft: `6px solid ${isPositive ? 'var(--accent-emerald)' : '#D97706'}`
              }}
            >
              <div className="flex items-center justify-between mb-3 flex-wrap gap-2">
                <div className="flex items-center gap-2">
                  <span className={`badge ${isPositive ? 'badge-green' : 'badge-amber'}`}>
                    {ins.badge}
                  </span>
                  <h3 style={{ margin: 0, color: 'var(--text-main)', fontSize: 'var(--font-size-lg)' }}>
                    {ins.title}
                  </h3>
                </div>
                <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
                  Generated: {ins.generatedAt}
                </div>
              </div>

              <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-main)', lineHeight: 1.5, marginBottom: '1rem' }}>
                {ins.summary}
              </p>

              <div
                style={{
                  backgroundColor: 'var(--bg-app)',
                  borderRadius: 'var(--radius-md)',
                  padding: '1rem 1.25rem',
                  border: '1px solid var(--border-subtle)',
                  marginBottom: '1rem'
                }}
              >
                <div style={{ fontSize: 'var(--font-size-xs)', fontWeight: 700, color: 'var(--primary-800)', textTransform: 'uppercase', marginBottom: '0.25rem' }}>
                  Suggested Clinical Recommendation:
                </div>
                <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)' }}>
                  {ins.clinicalAdvice}
                </div>
              </div>

              <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontStyle: 'italic' }}>
                * {ins.disclaimer}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
