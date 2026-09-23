import React, { useState } from 'react';
import {
  Brain,
  Wifi,
  WifiOff,
  Type,
  SunMoon,
  AlertCircle,
  Mic,
  RefreshCw,
  LogOut,
  User,
  Shield,
  Layers
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { useData } from '../../context/DataContext';
import { SOSModal } from './SOSModal';
import { VoiceCompanionModal } from './VoiceCompanionModal';
import { SyncQueueModal } from './SyncQueueModal';

export function Header({ activeTab, onTabChange }) {
  const { currentUser, role, switchRole, logout, startOnboarding } = useAuth();
  const { largeText, highContrast, toggleLargeText, toggleHighContrast } = useAccessibility();
  const { isOffline, syncQueue } = useData();

  const [showSOS, setShowSOS] = useState(false);
  const [showVoice, setShowVoice] = useState(false);
  const [showSyncModal, setShowSyncModal] = useState(false);

  return (
    <>
      <header className="app-header" role="banner">
        <div className="container app-header-inner">
          {/* Logo & Brand */}
          <div className="flex items-center gap-3">
            <button
              onClick={() => onTabChange && onTabChange('home')}
              className="brand-logo"
              style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0 }}
              aria-label="MindSetu Home"
            >
              <div
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '12px',
                  backgroundColor: 'var(--primary-600)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#FFFFFF'
                }}
              >
                <Brain size={26} />
              </div>
              <div className="text-left">
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <span>MindSetu</span>
                  <span style={{ fontSize: '0.85rem', color: 'var(--primary-600)', fontWeight: 600 }}>
                    মন সেতু
                  </span>
                </div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-subtle)', fontWeight: 500 }}>
                  NER Elderly Dementia Platform
                </div>
              </div>
            </button>

            {/* Quick Role Switcher (Evaluation Pill) */}
            <div className="role-switcher-pill" title="Fast Role Switcher for Evaluation">
              <button
                className={`role-pill-btn ${role === 'patient' ? 'active' : ''}`}
                onClick={() => switchRole('patient')}
                aria-label="Switch to Patient role"
              >
                👴 Patient
              </button>
              <button
                className={`role-pill-btn ${role === 'caregiver' ? 'active' : ''}`}
                onClick={() => switchRole('caregiver')}
                aria-label="Switch to Caregiver role"
              >
                👩‍⚕️ Caregiver
              </button>
              <button
                className={`role-pill-btn ${role === 'doctor' ? 'active' : ''}`}
                onClick={() => switchRole('doctor')}
                aria-label="Switch to Doctor role"
              >
                👨‍⚕️ Doctor
              </button>
            </div>
          </div>

          {/* Desktop Navigation Links based on Active Role */}
          <nav className="desktop-nav" aria-label="Main Navigation">
            {role === 'patient' && (
              <>
                <button
                  className={`nav-link ${activeTab === 'home' ? 'active' : ''}`}
                  onClick={() => onTabChange('home')}
                >
                  Home
                </button>
                <button
                  className={`nav-link ${activeTab === 'activities' ? 'active' : ''}`}
                  onClick={() => onTabChange('activities')}
                >
                  Activities
                </button>
                <button
                  className={`nav-link ${activeTab === 'memories' ? 'active' : ''}`}
                  onClick={() => onTabChange('memories')}
                >
                  Memories
                </button>
                <button
                  className={`nav-link ${activeTab === 'reminders' ? 'active' : ''}`}
                  onClick={() => onTabChange('reminders')}
                >
                  Reminders
                </button>
                <button
                  className={`nav-link ${activeTab === 'progress' ? 'active' : ''}`}
                  onClick={() => onTabChange('progress')}
                >
                  Progress
                </button>
                <button
                  className={`nav-link ${activeTab === 'profile' ? 'active' : ''}`}
                  onClick={() => onTabChange('profile')}
                >
                  Profile
                </button>
              </>
            )}

            {role === 'caregiver' && (
              <>
                <button
                  className={`nav-link ${activeTab === 'dashboard' ? 'active' : ''}`}
                  onClick={() => onTabChange('dashboard')}
                >
                  Dashboard
                </button>
                <button
                  className={`nav-link ${activeTab === 'notes' ? 'active' : ''}`}
                  onClick={() => onTabChange('notes')}
                >
                  Daily Notes
                </button>
                <button
                  className={`nav-link ${activeTab === 'reminders' ? 'active' : ''}`}
                  onClick={() => onTabChange('reminders')}
                >
                  Reminders
                </button>
                <button
                  className={`nav-link ${activeTab === 'memories' ? 'active' : ''}`}
                  onClick={() => onTabChange('memories')}
                >
                  Memories
                </button>
                <button
                  className={`nav-link ${activeTab === 'resources' ? 'active' : ''}`}
                  onClick={() => onTabChange('resources')}
                >
                  Resources
                </button>
              </>
            )}

            {role === 'doctor' && (
              <>
                <button
                  className={`nav-link ${activeTab === 'dashboard' ? 'active' : ''}`}
                  onClick={() => onTabChange('dashboard')}
                >
                  Clinical Dashboard
                </button>
                <button
                  className={`nav-link ${activeTab === 'details' ? 'active' : ''}`}
                  onClick={() => onTabChange('details')}
                >
                  Patient Details
                </button>
                <button
                  className={`nav-link ${activeTab === 'insights' ? 'active' : ''}`}
                  onClick={() => onTabChange('insights')}
                >
                  Insights
                </button>
                <button
                  className={`nav-link ${activeTab === 'reports' ? 'active' : ''}`}
                  onClick={() => onTabChange('reports')}
                >
                  Reports
                </button>
              </>
            )}
          </nav>

          {/* Right Action Utilities (Accessibility, Offline Status, SOS, Voice) */}
          <div className="flex items-center gap-2">
            {/* Offline / Sync Status Pill */}
            <button
              className={`badge ${isOffline ? 'badge-offline' : syncQueue.length > 0 ? 'badge-amber' : 'badge-online'}`}
              onClick={() => setShowSyncModal(true)}
              style={{ cursor: 'pointer', border: 'none', padding: '0.4rem 0.75rem' }}
              title="Click to view offline storage & sync details"
            >
              {isOffline ? (
                <>
                  <WifiOff size={15} />
                  <span>Offline — Saved</span>
                </>
              ) : syncQueue.length > 0 ? (
                <>
                  <RefreshCw size={15} />
                  <span>{syncQueue.length} Pending Sync</span>
                </>
              ) : (
                <>
                  <Wifi size={15} />
                  <span>Online — Synced</span>
                </>
              )}
            </button>

            {/* Accessibility: Large Text Toggle */}
            <button
              className={`btn btn-outline btn-icon-only ${largeText ? 'btn-secondary' : ''}`}
              onClick={toggleLargeText}
              title={largeText ? 'Disable large text mode' : 'Enable large text mode'}
              aria-label="Toggle large text mode"
            >
              <Type size={20} />
            </button>

            {/* Accessibility: High Contrast Toggle */}
            <button
              className={`btn btn-outline btn-icon-only ${highContrast ? 'btn-secondary' : ''}`}
              onClick={toggleHighContrast}
              title={highContrast ? 'Disable high contrast mode' : 'Enable high contrast mode'}
              aria-label="Toggle high contrast mode"
            >
              <SunMoon size={20} />
            </button>

            {/* Voice Companion Shortcut (Prominent for Patient) */}
            {role === 'patient' && (
              <button
                className="btn btn-secondary"
                onClick={() => setShowVoice(true)}
                style={{ padding: '0.5rem 1rem', minHeight: '44px' }}
                aria-label="Open Voice Companion"
              >
                <Mic size={18} color="var(--primary-700)" />
                <span className="font-semibold">Voice</span>
              </button>
            )}

            {/* SOS Emergency Button */}
            {(role === 'patient' || role === 'caregiver') && (
              <button
                className="btn btn-sos"
                onClick={() => setShowSOS(true)}
                style={{ minHeight: '44px', padding: '0.4rem 1.1rem' }}
                aria-label="Emergency SOS button"
              >
                <AlertCircle size={18} />
                <span>SOS</span>
              </button>
            )}

            {/* Logout / Switch Profile */}
            <button
              className="btn btn-outline btn-icon-only"
              onClick={startOnboarding}
              title="Onboarding / Signup flow"
              aria-label="Onboarding / Signup Flow"
            >
              <User size={18} />
            </button>
          </div>
        </div>
      </header>

      {/* Modals */}
      <SOSModal isOpen={showSOS} onClose={() => setShowSOS(false)} />
      <VoiceCompanionModal
        isOpen={showVoice}
        onClose={() => setShowVoice(false)}
        onNavigateTab={(tab) => onTabChange && onTabChange(tab)}
      />
      <SyncQueueModal isOpen={showSyncModal} onClose={() => setShowSyncModal(false)} />
    </>
  );
}
