import React, { useState } from 'react';
import {
  User,
  Globe,
  Type,
  SunMoon,
  Volume2,
  Shield,
  LogOut,
  CheckCircle2,
  RefreshCw,
  Bell,
  Heart
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { useData } from '../../context/DataContext';
import { NER_STATES, ALL_LANGUAGES } from '../../data/nerRegions';

export function PatientProfile() {
  const { currentUser, updateProfile, startOnboarding } = useAuth();
  const {
    largeText,
    highContrast,
    soundFeedback,
    toggleLargeText,
    toggleHighContrast,
    toggleSoundFeedback
  } = useAccessibility();
  const { resetAllData } = useData();

  const [selectedLanguage, setSelectedLanguage] = useState(currentUser?.language || 'Assamese');
  const [selectedRegion, setSelectedRegion] = useState(currentUser?.region || 'assam');
  const [saveSuccess, setSaveSuccess] = useState(false);

  const handleSavePreferences = () => {
    const stateObj = NER_STATES.find(s => s.id === selectedRegion);
    updateProfile({
      language: selectedLanguage,
      region: selectedRegion,
      regionName: stateObj ? stateObj.name : 'Assam'
    });
    setSaveSuccess(true);
    setTimeout(() => setSaveSuccess(false), 2500);
  };

  const handleResetData = () => {
    if (window.confirm('Reset all mock local data to default starter values?')) {
      resetAllData();
      alert('Local mock data restored to default.');
    }
  };

  return (
    <div className="container-narrow mt-6 mb-8">
      <div className="mb-6">
        <h1 style={{ marginBottom: '0.25rem', color: 'var(--primary-900)' }}>
          Profile & Preferences
        </h1>
        <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-muted)', margin: 0 }}>
          Manage your regional settings, language choices, accessibility, and privacy.
        </p>
      </div>

      {saveSuccess && (
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
          <span>Preferences updated and saved locally!</span>
        </div>
      )}

      {/* Senior Profile Summary */}
      <div className="card mb-6" style={{ padding: '1.75rem' }}>
        <div className="flex items-center gap-4 mb-4">
          <div style={{ fontSize: '3.5rem' }}>{currentUser?.avatar || '👴'}</div>
          <div>
            <h2 style={{ margin: '0 0 0.25rem', color: 'var(--text-main)' }}>
              {currentUser?.name || 'Bhaben Borah'}
            </h2>
            <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
              Age: {currentUser?.age || 72} • Gender: {currentUser?.gender || 'Male'} • Stage: {currentUser?.cognitiveStage || 'Mild Memory Support'}
            </div>
            <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--primary-700)', fontWeight: 600, marginTop: '2px' }}>
              Doctor: {currentUser?.doctorName || 'Dr. Debabrata Sarma (Geriatric Care)'}
            </div>
          </div>
        </div>
      </div>

      {/* Region & Language Preferences */}
      <div className="card mb-6" style={{ padding: '1.75rem' }}>
        <h3 style={{ color: 'var(--primary-900)', marginBottom: '1.25rem' }}>
          🌐 Regional & Language Preference
        </h3>

        <div className="form-group mb-4">
          <label className="form-label">North Eastern State / Region</label>
          <select
            className="form-select"
            value={selectedRegion}
            onChange={(e) => setSelectedRegion(e.target.value)}
          >
            {NER_STATES.map((state) => (
              <option key={state.id} value={state.id}>
                {state.symbol} {state.name}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group mb-4">
          <label className="form-label">Preferred Platform Language</label>
          <select
            className="form-select"
            value={selectedLanguage}
            onChange={(e) => setSelectedLanguage(e.target.value)}
          >
            {ALL_LANGUAGES.map((lang) => (
              <option key={lang.code} value={lang.name}>
                {lang.nativeName} ({lang.name})
              </option>
            ))}
          </select>
        </div>

        <button className="btn btn-primary" onClick={handleSavePreferences}>
          Save Regional Preferences
        </button>
      </div>

      {/* Accessibility Controls */}
      <div className="card mb-6" style={{ padding: '1.75rem' }}>
        <h3 style={{ color: 'var(--primary-900)', marginBottom: '1.25rem' }}>
          👁️ Accessibility & Sensory Comfort
        </h3>

        <div className="flex flex-col gap-3">
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '1rem',
              backgroundColor: 'var(--bg-app)',
              borderRadius: 'var(--radius-md)'
            }}
          >
            <div className="flex items-center gap-3">
              <Type size={22} color="var(--primary-700)" />
              <div>
                <div style={{ fontWeight: 700, color: 'var(--text-main)' }}>Large Text Mode</div>
                <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                  Enlarges all font scales and button labels for ease of reading
                </div>
              </div>
            </div>
            <button
              className={`btn ${largeText ? 'btn-primary' : 'btn-outline'}`}
              style={{ minHeight: '42px', padding: '0.3rem 1rem' }}
              onClick={toggleLargeText}
            >
              {largeText ? 'Enabled' : 'Disabled'}
            </button>
          </div>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '1rem',
              backgroundColor: 'var(--bg-app)',
              borderRadius: 'var(--radius-md)'
            }}
          >
            <div className="flex items-center gap-3">
              <SunMoon size={22} color="var(--primary-700)" />
              <div>
                <div style={{ fontWeight: 700, color: 'var(--text-main)' }}>High Contrast Mode</div>
                <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                  Stark dark mode with bold borders for vision impairments
                </div>
              </div>
            </div>
            <button
              className={`btn ${highContrast ? 'btn-primary' : 'btn-outline'}`}
              style={{ minHeight: '42px', padding: '0.3rem 1rem' }}
              onClick={toggleHighContrast}
            >
              {highContrast ? 'Enabled' : 'Disabled'}
            </button>
          </div>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '1rem',
              backgroundColor: 'var(--bg-app)',
              borderRadius: 'var(--radius-md)'
            }}
          >
            <div className="flex items-center gap-3">
              <Volume2 size={22} color="var(--primary-700)" />
              <div>
                <div style={{ fontWeight: 700, color: 'var(--text-main)' }}>Gentle Audio Chime</div>
                <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                  Calming audio feedback tone when tapping buttons and finishing games
                </div>
              </div>
            </div>
            <button
              className={`btn ${soundFeedback ? 'btn-primary' : 'btn-outline'}`}
              style={{ minHeight: '42px', padding: '0.3rem 1rem' }}
              onClick={toggleSoundFeedback}
            >
              {soundFeedback ? 'On' : 'Off'}
            </button>
          </div>
        </div>
      </div>

      {/* Privacy & Offline Data Notice */}
      <div className="card mb-6" style={{ padding: '1.75rem' }}>
        <h3 style={{ color: 'var(--primary-900)', marginBottom: '0.75rem' }}>
          🛡️ Privacy & Device Storage
        </h3>
        <p style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-muted)', lineHeight: 1.5, marginBottom: '1.25rem' }}>
          MindSetu is designed with strict privacy standards for elderly healthcare. All activity scores, memory journal entries, and personal notes are safely stored locally in your browser storage and will only sync to your clinic when explicitly authorized.
        </p>

        <div className="flex gap-3">
          <button className="btn btn-secondary" onClick={handleResetData}>
            <RefreshCw size={16} />
            <span>Reset Demo Data</span>
          </button>
          <button className="btn btn-outline" onClick={startOnboarding}>
            <LogOut size={16} />
            <span>Start Onboarding Again</span>
          </button>
        </div>
      </div>
    </div>
  );
}
