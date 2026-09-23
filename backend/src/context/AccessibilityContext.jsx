import React, { createContext, useContext, useState, useEffect } from 'react';
import { storageService } from '../services/storageService';

const AccessibilityContext = createContext(null);

export function AccessibilityProvider({ children }) {
  const [settings, setSettings] = useState(() => storageService.getAccessibilitySettings());

  useEffect(() => {
    // Apply classes to HTML root element
    const root = document.documentElement;
    if (settings.largeText) {
      root.classList.add('large-text-mode');
    } else {
      root.classList.remove('large-text-mode');
    }

    if (settings.highContrast) {
      root.classList.add('high-contrast-mode');
    } else {
      root.classList.remove('high-contrast-mode');
    }

    storageService.saveAccessibilitySettings(settings);
  }, [settings]);

  const toggleLargeText = () => {
    setSettings(prev => ({ ...prev, largeText: !prev.largeText }));
  };

  const toggleHighContrast = () => {
    setSettings(prev => ({ ...prev, highContrast: !prev.highContrast }));
  };

  const toggleSoundFeedback = () => {
    setSettings(prev => ({ ...prev, soundFeedback: !prev.soundFeedback }));
  };

  // Gentle audio chime / click simulation
  const playGentleChime = () => {
    if (!settings.soundFeedback) return;
    try {
      const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(523.25, audioCtx.currentTime); // C5 calm tone
      osc.frequency.exponentialRampToValueAtTime(659.25, audioCtx.currentTime + 0.18); // E5
      gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.28);
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start();
      osc.stop(audioCtx.currentTime + 0.3);
    } catch {
      // AudioContext might be restricted until user interacts, which is safe to ignore
    }
  };

  return (
    <AccessibilityContext.Provider
      value={{
        largeText: settings.largeText,
        highContrast: settings.highContrast,
        soundFeedback: settings.soundFeedback,
        simpleLanguage: settings.simpleLanguage,
        toggleLargeText,
        toggleHighContrast,
        toggleSoundFeedback,
        playGentleChime
      }}
    >
      {children}
    </AccessibilityContext.Provider>
  );
}

export function useAccessibility() {
  const context = useContext(AccessibilityContext);
  if (!context) {
    throw new Error('useAccessibility must be used within an AccessibilityProvider');
  }
  return context;
}
