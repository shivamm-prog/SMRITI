import React, { useState } from 'react';
import { X, Clock, Pill, Coffee, Utensils, Footprints } from 'lucide-react';
import { useData } from '../../context/DataContext';
import { useAuth } from '../../context/AuthContext';

export function AddReminderModal({ isOpen, onClose }) {
  const { currentUser } = useAuth();
  const { addReminder } = useData();

  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('Medicine');
  const [time, setTime] = useState('08:00 AM');
  const [instructions, setInstructions] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!title.trim()) return;

    addReminder({
      patientId: currentUser.id || 'user-pat-01',
      title,
      category,
      time,
      instructions: instructions.trim() || 'Follow prescribed routine with care.'
    });

    setTitle('');
    setInstructions('');
    onClose();
  };

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="add-rem-title">
      <div className="modal-container" style={{ maxWidth: '540px' }}>
        <div className="modal-header">
          <div className="flex items-center gap-2">
            <Clock size={24} color="var(--primary-700)" />
            <h3 id="add-rem-title" style={{ margin: 0 }}>Schedule New Care Reminder</h3>
          </div>
          <button className="modal-close-btn" onClick={onClose} aria-label="Close reminder modal">
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label" htmlFor="rem-type">Reminder Category</label>
            <select
              id="rem-type"
              className="form-select"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            >
              <option value="Medicine">💊 Medicine Reminder</option>
              <option value="Hydration">☕ Hydration & Warm Tea</option>
              <option value="Meal">🍲 Meal & Nutrition</option>
              <option value="Daily Activity">🚶 Daily Walk / Gardening</option>
              <option value="Appointment">🩺 Doctor / Health Checkup</option>
            </select>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="rem-title-inp">Reminder Title</label>
            <input
              id="rem-title-inp"
              className="form-input"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Afternoon Blood Pressure Tablet"
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="rem-time-inp">Scheduled Time</label>
            <input
              id="rem-time-inp"
              className="form-input"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              placeholder="e.g. 02:30 PM"
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="rem-inst">Gentle Instructions for Senior</label>
            <textarea
              id="rem-inst"
              className="form-textarea"
              value={instructions}
              onChange={(e) => setInstructions(e.target.value)}
              placeholder="e.g. Take 1 tablet with warm water and rest for 15 minutes."
              rows={2}
            />
          </div>

          <div className="flex justify-between gap-3 mt-6">
            <button type="button" className="btn btn-outline flex-1" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary btn-lg flex-1">
              Save Reminder
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
