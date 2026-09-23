import React, { useState } from 'react';
import { Plus, Sparkles, Volume2, Users, MapPin, Calendar, Heart, BookOpen } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { MemoryJournalModal } from './MemoryJournalModal';
import { MemoryRecallModal } from './MemoryRecallModal';

export function PatientMemories() {
  const { memories } = useData();
  const [showAddModal, setShowAddModal] = useState(false);
  const [showRecallModal, setShowRecallModal] = useState(false);
  const [playingVoiceId, setPlayingVoiceId] = useState(null);

  const handlePlayVoice = (id) => {
    if (playingVoiceId === id) {
      setPlayingVoiceId(null);
    } else {
      setPlayingVoiceId(id);
      setTimeout(() => {
        setPlayingVoiceId(null);
      }, 4000);
    }
  };

  return (
    <div className="container mt-6 mb-8">
      {/* Top Header & Actions */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
            Memory Journal & Recall
          </h1>
          <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
            Cherished family stories, familiar places, and peaceful moments.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            className="btn btn-secondary"
            onClick={() => setShowRecallModal(true)}
            disabled={memories.length === 0}
          >
            <Sparkles size={18} />
            <span>Memory Recall Quiz</span>
          </button>

          <button
            className="btn btn-primary"
            onClick={() => setShowAddModal(true)}
          >
            <Plus size={20} />
            <span>Add Memory</span>
          </button>
        </div>
      </div>

      {/* Memories Grid or Empty State */}
      {memories.length === 0 ? (
        <div
          className="card text-center"
          style={{ padding: '3.5rem 1.5rem', maxWidth: '600px', margin: '2rem auto' }}
        >
          <div style={{ fontSize: '3.5rem', marginBottom: '1rem' }}>📖</div>
          <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
            No Memories Added Yet
          </h3>
          <p style={{ color: 'var(--text-muted)', marginBottom: '1.5rem' }}>
            Add family photos, pleasant trips, or special days to create your personal memory journal.
          </p>
          <button className="btn btn-primary" onClick={() => setShowAddModal(true)}>
            <Plus size={18} />
            <span>Create First Memory</span>
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-2 md-grid-cols-1 gap-6">
          {memories.map((mem) => {
            const isPlaying = playingVoiceId === mem.id;

            return (
              <div
                key={mem.id}
                className="card"
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  justifyContent: 'space-between',
                  padding: '1.75rem'
                }}
              >
                <div>
                  {/* Visual Scene Banner */}
                  <div
                    style={{
                      backgroundColor: 'var(--primary-50)',
                      border: '1.5px solid var(--primary-200)',
                      borderRadius: 'var(--radius-lg)',
                      padding: '1.5rem',
                      textAlign: 'center',
                      marginBottom: '1.25rem'
                    }}
                  >
                    <div style={{ fontSize: '3.5rem', lineHeight: 1 }}>
                      {mem.emojiPhoto || '🏡 ☕ 🌺'}
                    </div>
                  </div>

                  <div className="flex items-center justify-between mb-2">
                    <h3 style={{ margin: 0, color: 'var(--text-main)' }}>
                      {mem.title}
                    </h3>
                    {mem.syncStatus === 'Pending Sync' && (
                      <span className="badge badge-pending">
                        Pending Sync
                      </span>
                    )}
                  </div>

                  <div className="flex flex-wrap gap-3 mb-3" style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                    <span className="flex items-center gap-1">
                      <Calendar size={14} /> {mem.date}
                    </span>
                    <span className="flex items-center gap-1">
                      <MapPin size={14} /> {mem.location}
                    </span>
                  </div>

                  <div className="flex items-center gap-2 mb-3" style={{ fontSize: 'var(--font-size-sm)', color: 'var(--primary-800)', fontWeight: 600 }}>
                    <Users size={16} />
                    <span>{mem.people}</span>
                  </div>

                  <p style={{ color: 'var(--text-main)', fontSize: 'var(--font-size-base)', lineHeight: 1.5, marginBottom: '1.25rem' }}>
                    {mem.description}
                  </p>
                </div>

                {/* Voice Note Simulation & Action */}
                <div
                  style={{
                    backgroundColor: isPlaying ? '#DCFCE7' : 'var(--bg-app)',
                    border: `1.5px solid ${isPlaying ? '#86EFAC' : 'var(--border-subtle)'}`,
                    borderRadius: 'var(--radius-md)',
                    padding: '0.75rem 1rem',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginTop: '0.5rem'
                  }}
                >
                  <div className="flex items-center gap-2">
                    <Volume2 size={18} color={isPlaying ? '#15803D' : 'var(--primary-600)'} />
                    <div>
                      <div style={{ fontWeight: 600, fontSize: 'var(--font-size-sm)', color: isPlaying ? '#14532D' : 'var(--text-main)' }}>
                        {isPlaying ? 'Playing Audio...' : (mem.voiceNoteTitle || 'Family Audio Note')}
                      </div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)' }}>
                        Duration: {mem.voiceDuration || '0:30'}
                      </div>
                    </div>
                  </div>

                  <button
                    className={`btn ${isPlaying ? 'btn-success' : 'btn-outline'}`}
                    style={{ minHeight: '38px', padding: '0.3rem 0.8rem', fontSize: 'var(--font-size-sm)' }}
                    onClick={() => handlePlayVoice(mem.id)}
                  >
                    {isPlaying ? 'Pause' : 'Listen'}
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Modals */}
      <MemoryJournalModal isOpen={showAddModal} onClose={() => setShowAddModal(false)} />
      <MemoryRecallModal
        isOpen={showRecallModal}
        onClose={() => setShowRecallModal(false)}
        memories={memories}
      />
    </div>
  );
}
