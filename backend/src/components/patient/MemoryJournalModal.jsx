import React, { useState } from 'react';
import { X, Image, Mic, MapPin, Users, Calendar, Sparkles } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';

export function MemoryJournalModal({ isOpen, onClose }) {
  const { currentUser } = useAuth();
  const { addMemory } = useData();

  const [title, setTitle] = useState('');
  const [date, setDate] = useState('Today');
  const [location, setLocation] = useState('Guwahati, Assam');
  const [people, setPeople] = useState('Anamika (Daughter), Bhaben Borah');
  const [description, setDescription] = useState('');
  const [emojiPhoto, setEmojiPhoto] = useState('🏡 ☕ 🌺');
  const [voiceNoteTitle, setVoiceNoteTitle] = useState('Veranda morning birds & laughter (0:24)');

  const emojiPresets = [
    '🏡 ☕ 🌺',
    '🌾 🪕 👨‍👩‍👧‍👦',
    '🦏 🌄 🌿',
    '🎋 🧣 🌸',
    '🥟 🍲 🫖',
    '🌉 🌳 💧',
    '🏰 🏛️ 🕊️'
  ];

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!title.trim()) return;

    addMemory({
      patientId: currentUser.id,
      title,
      date,
      location,
      people,
      description,
      emojiPhoto,
      tags: ['Family', 'Personal'],
      voiceNoteTitle,
      voiceDuration: '0:24',
      recallQuestion: `Who was with you during "${title}"?`,
      recallAnswer: people,
      recallHint: `Look at the smiling family members mentioned in this memory.`
    });

    onClose();
  };

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="journal-title">
      <div className="modal-container" style={{ maxWidth: '640px' }}>
        <div className="modal-header">
          <div className="flex items-center gap-2">
            <span style={{ fontSize: '1.75rem' }}>📖</span>
            <h3 id="journal-title" style={{ margin: 0 }}>Add Family Memory to Journal</h3>
          </div>
          <button className="modal-close-btn" onClick={onClose} aria-label="Close memory modal">
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          {/* Preset Emoji Photo Picker */}
          <div className="form-group">
            <label className="form-label">Choose Photo / Scene Illustration</label>
            <div className="flex flex-wrap gap-2 mb-2">
              {emojiPresets.map((preset, idx) => (
                <button
                  key={idx}
                  type="button"
                  className={`btn ${emojiPhoto === preset ? 'btn-primary' : 'btn-outline'}`}
                  style={{ minHeight: '44px', fontSize: '1.5rem', padding: '0.4rem 0.8rem' }}
                  onClick={() => setEmojiPhoto(preset)}
                >
                  {preset}
                </button>
              ))}
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="mem-title">Memory Title</label>
            <input
              id="mem-title"
              className="form-input"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Afternoon Tea with Grandchildren"
              required
            />
          </div>

          <div className="grid grid-cols-2 md-grid-cols-1 gap-3">
            <div className="form-group">
              <label className="form-label" htmlFor="mem-date">Date / Season</label>
              <input
                id="mem-date"
                className="form-input"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                placeholder="e.g. October 2024 / Autumn"
              />
            </div>

            <div className="form-group">
              <label className="form-label" htmlFor="mem-location">Place / Landmark</label>
              <input
                id="mem-location"
                className="form-input"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g. Jorhat Family Garden"
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="mem-people">People Present</label>
            <input
              id="mem-people"
              className="form-input"
              value={people}
              onChange={(e) => setPeople(e.target.value)}
              placeholder="e.g. Daughter Anamika, Grandson Joy"
            />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="mem-desc">Heartwarming Story / Details</label>
            <textarea
              id="mem-desc"
              className="form-textarea"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="What made this moment special? What did you talk about?"
              rows={3}
            />
          </div>

          {/* Voice note simulation */}
          <div
            style={{
              backgroundColor: 'var(--primary-50)',
              border: '1.5px solid var(--primary-200)',
              borderRadius: 'var(--radius-md)',
              padding: '0.85rem 1.25rem',
              marginBottom: '1.5rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.75rem'
            }}
          >
            <Mic size={22} color="var(--primary-700)" />
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 700, color: 'var(--primary-900)', fontSize: 'var(--font-size-sm)' }}>
                Simulated Voice Audio Note Attached
              </div>
              <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
                {voiceNoteTitle}
              </div>
            </div>
          </div>

          <div className="flex justify-between gap-3">
            <button type="button" className="btn btn-outline flex-1" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary btn-lg flex-1">
              Save Memory
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
