import React, { useState } from 'react';
import { AlertTriangle, PhoneCall, CheckCircle2, X } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export function SOSModal({ isOpen, onClose }) {
  const { currentUser } = useAuth();
  const [isConfirmed, setIsConfirmed] = useState(false);

  if (!isOpen) return null;

  const handleConfirm = () => {
    setIsConfirmed(true);
  };

  const handleResetAndClose = () => {
    setIsConfirmed(false);
    onClose();
  };

  const emergencyContact = currentUser?.emergencyContact || {
    name: 'Anamika Borah (Family Caregiver)',
    phone: '+91 94350 12345',
    relation: 'Daughter'
  };

  return (
    <div className="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="sos-title">
      <div className="modal-container" style={{ borderColor: 'var(--sos-bg)' }}>
        <div className="modal-header">
          <div className="flex items-center gap-3">
            <span style={{ fontSize: '2rem' }}>🚨</span>
            <h2 id="sos-title" style={{ color: 'var(--sos-bg)', margin: 0 }}>
              Emergency Assistance (SOS)
            </h2>
          </div>
          <button
            className="modal-close-btn"
            onClick={handleResetAndClose}
            aria-label="Close emergency modal"
          >
            <X size={24} />
          </button>
        </div>

        {!isConfirmed ? (
          <div>
            <div
              style={{
                backgroundColor: '#FEE2E2',
                border: '2px solid #F87171',
                borderRadius: 'var(--radius-lg)',
                padding: '1.25rem',
                marginBottom: '1.5rem'
              }}
            >
              <h3 style={{ color: '#991B1B', marginBottom: '0.5rem' }}>
                Do you need immediate assistance?
              </h3>
              <p style={{ color: '#7F1D1D', fontSize: 'var(--font-size-base)', margin: 0 }}>
                Pressing the button below will immediately notify your designated family caregiver and doctor.
              </p>
            </div>

            <div
              style={{
                backgroundColor: 'var(--bg-app)',
                borderRadius: 'var(--radius-md)',
                padding: '1rem 1.25rem',
                border: '1.5px solid var(--border-subtle)',
                marginBottom: '1.75rem'
              }}
            >
              <div style={{ fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)', marginBottom: '0.25rem' }}>
                Primary Emergency Contact
              </div>
              <div style={{ fontWeight: 700, fontSize: 'var(--font-size-lg)', color: 'var(--text-main)' }}>
                {emergencyContact.name}
              </div>
              <div style={{ color: 'var(--primary-700)', fontWeight: 600 }}>
                {emergencyContact.phone} ({emergencyContact.relation})
              </div>
            </div>

            <div className="flex flex-col gap-3">
              <button
                className="btn btn-sos btn-lg btn-block"
                onClick={handleConfirm}
                aria-label="Confirm calling emergency assistance"
              >
                <PhoneCall size={26} />
                <span>Yes, Alert My Caregiver Now</span>
              </button>

              <button
                className="btn btn-outline btn-lg btn-block"
                onClick={handleResetAndClose}
              >
                I am okay, Cancel
              </button>
            </div>
          </div>
        ) : (
          <div className="text-center" style={{ padding: '1rem 0' }}>
            <div
              style={{
                width: '72px',
                height: '72px',
                backgroundColor: '#DCFCE7',
                color: '#16A34A',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                margin: '0 auto 1.25rem'
              }}
            >
              <CheckCircle2 size={44} />
            </div>

            <h3 style={{ color: '#166534', marginBottom: '0.5rem' }}>
              Alert Sent Successfully
            </h3>
            <p style={{ fontSize: 'var(--font-size-base)', color: 'var(--text-main)', marginBottom: '1.5rem' }}>
              Your caregiver <strong>{emergencyContact.name}</strong> has received an alert with your current location. Please sit down comfortably, take slow breaths, and rest.
            </p>

            <div
              style={{
                backgroundColor: '#EFF6FF',
                border: '1.5px solid var(--primary-200)',
                borderRadius: 'var(--radius-md)',
                padding: '1rem',
                marginBottom: '1.75rem',
                fontSize: 'var(--font-size-sm)',
                color: 'var(--primary-900)'
              }}
            >
              Note: In the future production release, this triggers automatic SMS, emergency IVR calls, and GPS dispatch.
            </div>

            <button
              className="btn btn-primary btn-block"
              onClick={handleResetAndClose}
            >
              Return to Safety
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
