import React, { useState } from 'react';
import { X, ClipboardList, Smile, Moon, Utensils, Heart } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';

export function DailyNotesModal({ isOpen, onClose }) {
  const { currentUser } = useAuth();
  const { addDailyNote } = useData();

  const [mood, setMood] = useState('Calm & Happy');
  const [moodEmoji, setMoodEmoji] = useState('😊');
  const [sleepQuality, setSleepQuality] = useState('Good (7–8 hours)');
  const [appetite, setAppetite] = useState('Good — ate full breakfast & tea');
  const [behavior, setBehavior] = useState('');
  const [observations, setObservations] = useState('');

  if (!isOpen) return null;

  const moodOptions = [
    { label: 'Calm & Happy', emoji: '😊' },
    { label: 'Cheerful & Lively', emoji: '🌟' },
    { label: 'Quiet & Resting', emoji: '😌' },
    { label: 'Slightly Confused', emoji: '🤔' },
    { label: 'Restless in Evening', emoji: '😟' }
  ];

  const handleSubmit = (e) => {
    e.preventDefault();

    addDailyNote({
      patientId: 'user-pat-01',
      author: currentUser.name || 'Anamika Borah (Caregiver)',
      mood,
      moodEmoji,
      sleepQuality,
      appetite,
      behavior: behavior.trim() || 'Stable and cooperative throughout the morning.',
      observations: observations.trim() || 'Enjoyed listening to gentle Bihu flute and completed morning tea.'
    });

    setBehavior('');
    setObservations('');
    onClose();
  };

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="note-modal-title">
      <div className="modal-container" style={{ maxWidth: '600px' }}>
        <div className="modal-header">
          <div className="flex items-center gap-2">
            <ClipboardList size={24} color="var(--primary-700)" />
            <h3 id="note-modal-title" style={{ margin: 0 }}>Log Daily Caregiver Observation</h3>
          </div>
          <button className="modal-close-btn" onClick={onClose} aria-label="Close notes modal">
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          {/* Mood Selection */}
          <div className="form-group">
            <label className="form-label">Patient Mood Today</label>
            <div className="flex flex-wrap gap-2">
              {moodOptions.map((opt) => (
                <button
                  key={opt.label}
                  type="button"
                  className={`btn ${mood === opt.label ? 'btn-primary' : 'btn-outline'}`}
                  style={{ minHeight: '44px', padding: '0.4rem 0.85rem', fontSize: 'var(--font-size-sm)' }}
                  onClick={() => {
                    setMood(opt.label);
                    setMoodEmoji(opt.emoji);
                  }}
                >
                  <span style={{ fontSize: '1.25rem' }}>{opt.emoji}</span>
                  <span>{opt.label}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Sleep Quality */}
          <div className="form-group">
            <label className="form-label" htmlFor="inp-sleep">Sleep Duration & Quality</label>
            <select
              id="inp-sleep"
              className="form-select"
              value={sleepQuality}
              onChange={(e) => setSleepQuality(e.target.value)}
            >
              <option value="Good (7–8 hours uninterrupted)">Good (7–8 hours uninterrupted)</option>
              <option value="Fair (6 hours, woke once)">Fair (6 hours, woke once)</option>
              <option value="Restless (woke multiple times)">Restless (woke multiple times)</option>
              <option value="Long afternoon nap (1+ hour)">Long afternoon nap (1+ hour)</option>
            </select>
          </div>

          {/* Appetite */}
          <div className="form-group">
            <label className="form-label" htmlFor="inp-appetite">Appetite & Nutrition</label>
            <select
              id="inp-appetite"
              className="form-select"
              value={appetite}
              onChange={(e) => setAppetite(e.target.value)}
            >
              <option value="Good — ate full breakfast & tea">Good — ate full breakfast & tea</option>
              <option value="Normal — finished main meals">Normal — finished main meals</option>
              <option value="Low — needed gentle encouragement">Low — needed gentle encouragement</option>
              <option value="Skipped meal / hydration reminder">Skipped meal / hydration reminder</option>
            </select>
          </div>

          {/* Behavior & Cognitive Notes */}
          <div className="form-group">
            <label className="form-label" htmlFor="inp-behavior">Behavior & Communication</label>
            <input
              id="inp-behavior"
              className="form-input"
              value={behavior}
              onChange={(e) => setBehavior(e.target.value)}
              placeholder="e.g. Talked fondly about old times; calm during morning tea"
            />
          </div>

          {/* General Observations */}
          <div className="form-group">
            <label className="form-label" htmlFor="inp-obs">General Health & Clinical Observations</label>
            <textarea
              id="inp-obs"
              className="form-textarea"
              value={observations}
              onChange={(e) => setObservations(e.target.value)}
              placeholder="e.g. Needed minor help with spectacles; played nature spotting activity happily."
              rows={3}
            />
          </div>

          <div className="flex justify-between gap-3 mt-6">
            <button type="button" className="btn btn-outline flex-1" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary btn-lg flex-1">
              Save Daily Note
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
