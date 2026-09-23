import React from 'react';
import { Wifi, WifiOff, RefreshCw, CheckCircle2, Clock, X, Database } from 'lucide-react';
import { useData } from '../../context/DataContext';

export function SyncQueueModal({ isOpen, onClose }) {
  const {
    isOffline,
    isOfflineManual,
    isSyncing,
    syncQueue,
    toggleOfflineSimulation,
    syncNow
  } = useData();

  if (!isOpen) return null;

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="sync-title">
      <div className="modal-container" style={{ maxWidth: '600px' }}>
        <div className="modal-header">
          <div className="flex items-center gap-2">
            <Database size={24} color="var(--primary-700)" />
            <h3 id="sync-title" style={{ margin: 0 }}>Offline Storage & Sync Status</h3>
          </div>
          <button className="modal-close-btn" onClick={onClose} aria-label="Close sync modal">
            <X size={24} />
          </button>
        </div>

        {/* Current Network Mode */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '1.25rem',
            borderRadius: 'var(--radius-md)',
            backgroundColor: isOffline ? '#FEF3C7' : '#DCFCE7',
            border: `1.5px solid ${isOffline ? '#FCD34D' : '#86EFAC'}`,
            marginBottom: '1.5rem'
          }}
        >
          <div className="flex items-center gap-3">
            {isOffline ? (
              <div style={{ color: '#92400E' }}><WifiOff size={32} /></div>
            ) : (
              <div style={{ color: '#166534' }}><Wifi size={32} /></div>
            )}
            <div>
              <h4 style={{ margin: 0, color: isOffline ? '#92400E' : '#166534' }}>
                {isOffline ? 'Offline — Data saved on this device' : 'Online — Ready to sync'}
              </h4>
              <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: isOffline ? '#78350F' : '#14532D' }}>
                {isOffline
                  ? 'All games, reminders, and notes work 100% without internet.'
                  : 'Connected to local storage. Changes ready to transmit to cloud.'}
              </p>
            </div>
          </div>
        </div>

        {/* Evaluation Control: Toggle Offline Simulation */}
        <div
          style={{
            backgroundColor: 'var(--bg-app)',
            borderRadius: 'var(--radius-md)',
            padding: '1rem 1.25rem',
            border: '1.5px solid var(--border-subtle)',
            marginBottom: '1.5rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between'
          }}
        >
          <div>
            <div style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: 'var(--font-size-base)' }}>
              Simulate Offline Mode (For Evaluation)
            </div>
            <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
              Toggle on to test zero-connectivity behavior in remote NER villages.
            </div>
          </div>
          <button
            className={`btn ${isOfflineManual ? 'btn-primary' : 'btn-outline'}`}
            onClick={toggleOfflineSimulation}
            style={{ minHeight: '44px', padding: '0.4rem 1rem' }}
          >
            {isOfflineManual ? 'Offline Active' : 'Switch Offline'}
          </button>
        </div>

        {/* Pending Sync Queue List */}
        <div style={{ marginBottom: '1.5rem' }}>
          <div className="flex items-center justify-between mb-2">
            <h4 style={{ margin: 0 }}>
              Local Sync Queue ({syncQueue.length} items)
            </h4>
            {syncQueue.length > 0 && (
              <span className="badge badge-pending">
                <Clock size={14} /> Pending Cloud Sync
              </span>
            )}
          </div>

          {syncQueue.length === 0 ? (
            <div
              style={{
                textAlign: 'center',
                padding: '2rem 1rem',
                backgroundColor: 'var(--bg-card-subtle)',
                borderRadius: 'var(--radius-md)',
                color: 'var(--text-muted)'
              }}
            >
              <CheckCircle2 size={36} color="#16A34A" style={{ margin: '0 auto 0.5rem' }} />
              <div style={{ fontWeight: 600 }}>All local changes are fully synced!</div>
              <p style={{ fontSize: 'var(--font-size-sm)', margin: '0.25rem 0 0' }}>
                New activities, journal entries, or daily notes will be queued here safely.
              </p>
            </div>
          ) : (
            <div
              style={{
                maxHeight: '220px',
                overflowY: 'auto',
                border: '1.5px solid var(--border-subtle)',
                borderRadius: 'var(--radius-md)'
              }}
            >
              {syncQueue.map((item) => (
                <div
                  key={item.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '0.75rem 1rem',
                    borderBottom: '1px solid var(--border-subtle)',
                    fontSize: 'var(--font-size-sm)'
                  }}
                >
                  <div>
                    <strong style={{ color: 'var(--primary-800)' }}>{item.action}</strong>
                    <div style={{ color: 'var(--text-subtle)', fontSize: '0.8rem' }}>
                      {new Date(item.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                    </div>
                  </div>
                  <span className="badge badge-pending" style={{ fontSize: '0.75rem' }}>
                    Pending Sync
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Sync Actions */}
        <div className="flex gap-3">
          <button
            className="btn btn-primary btn-lg flex-1"
            disabled={isSyncing || syncQueue.length === 0}
            onClick={syncNow}
          >
            <RefreshCw size={20} className={isSyncing ? 'animate-spin' : ''} />
            <span>{isSyncing ? 'Syncing with Server...' : 'Simulate Sync Now'}</span>
          </button>
          <button className="btn btn-outline" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
