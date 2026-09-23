import React from 'react';
import { BookOpen, PhoneCall, Heart, Clock, ShieldAlert, CheckCircle2 } from 'lucide-react';
import { CAREGIVER_RESOURCES } from '../../data/initialMockData';

export function CaregiverResources() {
  return (
    <div className="container mt-6 mb-8">
      <div className="mb-6">
        <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
          Caregiver Educational Resources
        </h1>
        <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
          Practical guidance, communication advice, and emergency helplines for families in the North East.
        </p>
      </div>

      <div className="grid grid-cols-2 md-grid-cols-1 gap-6">
        {CAREGIVER_RESOURCES.map((res) => (
          <div
            key={res.id}
            className="card"
            style={{
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              padding: '1.75rem',
              borderTop: '5px solid var(--primary-600)'
            }}
          >
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="badge badge-blue">
                  {res.category}
                </span>
                <span style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
                  <Clock size={12} style={{ display: 'inline', marginRight: '4px' }} />
                  {res.readTime}
                </span>
              </div>

              <h3 style={{ margin: '0 0 0.5rem', color: 'var(--text-main)', fontSize: 'var(--font-size-lg)' }}>
                {res.title}
              </h3>

              <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)', marginBottom: '1.25rem' }}>
                {res.summary}
              </p>

              <div
                style={{
                  backgroundColor: 'var(--bg-app)',
                  borderRadius: 'var(--radius-md)',
                  padding: '1rem 1.25rem',
                  border: '1px solid var(--border-subtle)'
                }}
              >
                <div style={{ fontSize: 'var(--font-size-xs)', fontWeight: 700, color: 'var(--primary-800)', textTransform: 'uppercase', marginBottom: '0.5rem' }}>
                  Key Recommendations:
                </div>
                <ul style={{ paddingLeft: '1.25rem', margin: 0 }}>
                  {res.keyPoints.map((pt, idx) => (
                    <li key={idx} style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-main)', marginBottom: '0.35rem' }}>
                      {pt}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
