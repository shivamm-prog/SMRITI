import React, { useState } from 'react';
import {
  Brain,
  CheckCircle2,
  ArrowRight,
  ArrowLeft,
  User,
  Heart,
  Globe,
  Sparkles,
  MapPin,
  Smile,
  X
} from 'lucide-react';
import { NER_STATES, ALL_LANGUAGES, PREFERENCE_OPTIONS } from '../../data/nerRegions';
import { useAuth } from '../../context/AuthContext';

export function OnboardingFlow() {
  const { completeOnboarding, cancelOnboarding } = useAuth();

  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    role: 'patient',
    name: 'Bhaben Borah',
    age: 72,
    gender: 'Male',
    dob: '1954-04-14',
    region: 'assam',
    language: 'Assamese',
    preferences: {
      activities: ['Morning tea on the veranda', 'Gardening & caring for plants'],
      foods: ['Fresh Masor Tenga / sour fish curry', 'Soft Pitha with jaggery'],
      music: ['Gentle Bihu songs & Pepa'],
      places: ['Lush Green Tea Garden']
    }
  });

  const selectedStateObj = NER_STATES.find(s => s.id === formData.region) || NER_STATES[0];

  const handleRoleSelect = (role) => {
    setFormData(prev => ({ ...prev, role }));
  };

  const handleStateSelect = (stateId) => {
    const st = NER_STATES.find(s => s.id === stateId);
    setFormData(prev => ({
      ...prev,
      region: stateId,
      language: st ? st.defaultLanguage : 'English'
    }));
  };

  const togglePreference = (category, item) => {
    setFormData(prev => {
      const currentList = prev.preferences[category] || [];
      const updatedList = currentList.includes(item)
        ? currentList.filter(i => i !== item)
        : [...currentList, item];
      return {
        ...prev,
        preferences: {
          ...prev.preferences,
          [category]: updatedList
        }
      };
    });
  };

  const handleNext = () => {
    if (step === 1 && formData.role !== 'patient') {
      // Direct completion for Caregiver or Doctor mock profile
      completeOnboarding({
        ...formData,
        avatar: formData.role === 'caregiver' ? '👩‍⚕️' : '👨‍⚕️'
      });
      return;
    }

    if (step < 5) {
      setStep(step + 1);
    } else {
      // Step 5 finish
      completeOnboarding({
        ...formData,
        regionName: selectedStateObj.name,
        avatar: '👴',
        cognitiveStage: 'Gentle Support'
      });
    }
  };

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1);
    } else {
      cancelOnboarding();
    }
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        backgroundColor: 'var(--bg-app)',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '2rem 1rem'
      }}
    >
      <div
        className="card"
        style={{
          width: '100%',
          maxWidth: '780px',
          boxShadow: 'var(--shadow-lg)',
          borderRadius: 'var(--radius-xl)',
          padding: '2.25rem'
        }}
      >
        {/* Header & Progress Indicator */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
          <div className="flex items-center gap-3">
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '12px',
                backgroundColor: 'var(--primary-600)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FFFFFF'
              }}
            >
              <Brain size={24} />
            </div>
            <div>
              <h2 style={{ fontSize: 'var(--font-size-xl)', margin: 0, color: 'var(--primary-900)' }}>
                MindSetu Onboarding
              </h2>
              <p style={{ margin: 0, fontSize: 'var(--font-size-sm)', color: 'var(--text-subtle)' }}>
                Personalizing care for North Eastern elders
              </p>
            </div>
          </div>

          <button
            className="btn btn-outline btn-icon-only"
            onClick={cancelOnboarding}
            title="Return to default profile"
            aria-label="Close onboarding"
          >
            <X size={20} />
          </button>
        </div>

        {/* Step dots */}
        <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '2rem' }}>
          {[1, 2, 3, 4, 5].map((s) => (
            <div
              key={s}
              style={{
                flex: 1,
                height: '6px',
                borderRadius: '3px',
                backgroundColor: s <= step ? 'var(--primary-600)' : 'var(--border-subtle)',
                transition: 'background-color 250ms ease'
              }}
            />
          ))}
        </div>

        {/* STEP 1: CHOOSE ROLE */}
        {step === 1 && (
          <div>
            <h3 style={{ marginBottom: '0.5rem', color: 'var(--text-main)' }}>
              Step 1: Choose Your Role
            </h3>
            <p style={{ marginBottom: '1.75rem' }}>
              Select how you will be using MindSetu. The experience will be customized for you.
            </p>

            <div className="grid grid-cols-3 md-grid-cols-1 gap-4 mb-6">
              <div
                className={`card card-interactive ${formData.role === 'patient' ? 'card-highlight' : ''}`}
                style={{
                  textAlign: 'center',
                  padding: '1.75rem 1rem',
                  border: formData.role === 'patient' ? '3px solid var(--primary-600)' : '1.5px solid var(--border-color)'
                }}
                onClick={() => handleRoleSelect('patient')}
              >
                <div style={{ fontSize: '3rem', marginBottom: '0.75rem' }}>👴</div>
                <h4 style={{ marginBottom: '0.4rem' }}>Elderly Patient</h4>
                <p style={{ fontSize: 'var(--font-size-sm)', margin: 0 }}>
                  Calm memory games, large touch buttons, daily reminders, and voice companion.
                </p>
              </div>

              <div
                className={`card card-interactive ${formData.role === 'caregiver' ? 'card-highlight' : ''}`}
                style={{
                  textAlign: 'center',
                  padding: '1.75rem 1rem',
                  border: formData.role === 'caregiver' ? '3px solid var(--primary-600)' : '1.5px solid var(--border-color)'
                }}
                onClick={() => handleRoleSelect('caregiver')}
              >
                <div style={{ fontSize: '3rem', marginBottom: '0.75rem' }}>👩‍⚕️</div>
                <h4 style={{ marginBottom: '0.4rem' }}>Caregiver / Family</h4>
                <p style={{ fontSize: 'var(--font-size-sm)', margin: 0 }}>
                  Manage patient reminders, daily mood & sleep logs, memory photo journal.
                </p>
              </div>

              <div
                className={`card card-interactive ${formData.role === 'doctor' ? 'card-highlight' : ''}`}
                style={{
                  textAlign: 'center',
                  padding: '1.75rem 1rem',
                  border: formData.role === 'doctor' ? '3px solid var(--primary-600)' : '1.5px solid var(--border-color)'
                }}
                onClick={() => handleRoleSelect('doctor')}
              >
                <div style={{ fontSize: '3rem', marginBottom: '0.75rem' }}>👨‍⚕️</div>
                <h4 style={{ marginBottom: '0.4rem' }}>Doctor / Clinician</h4>
                <p style={{ fontSize: 'var(--font-size-sm)', margin: 0 }}>
                  Review cognitive trends, caregiver observations, and generate clinical reports.
                </p>
              </div>
            </div>
          </div>
        )}

        {/* STEP 2: PATIENT PROFILE */}
        {step === 2 && (
          <div>
            <h3 style={{ marginBottom: '0.5rem' }}>Step 2: Senior Profile</h3>
            <p style={{ marginBottom: '1.5rem' }}>
              Please provide basic personal information to personalize the elderly experience.
            </p>

            <div className="grid grid-cols-2 md-grid-cols-1 gap-4 mb-4">
              <div className="form-group">
                <label className="form-label" htmlFor="inp-name">Full Name</label>
                <input
                  id="inp-name"
                  className="form-input"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="e.g. Bhaben Borah"
                />
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="inp-age">Age</label>
                <input
                  id="inp-age"
                  type="number"
                  className="form-input"
                  value={formData.age}
                  onChange={(e) => setFormData({ ...formData, age: Number(e.target.value) })}
                  placeholder="e.g. 72"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 md-grid-cols-1 gap-4 mb-6">
              <div className="form-group">
                <label className="form-label" htmlFor="inp-gender">Gender</label>
                <select
                  id="inp-gender"
                  className="form-select"
                  value={formData.gender}
                  onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                >
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other / Prefer not to say</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="inp-dob">Date of Birth</label>
                <input
                  id="inp-dob"
                  type="date"
                  className="form-input"
                  value={formData.dob}
                  onChange={(e) => setFormData({ ...formData, dob: e.target.value })}
                />
              </div>
            </div>
          </div>
        )}

        {/* STEP 3: NER STATE SELECTION */}
        {step === 3 && (
          <div>
            <h3 style={{ marginBottom: '0.5rem' }}>
              Step 3: Select North Eastern State / Region
            </h3>
            <p style={{ marginBottom: '1.5rem' }}>
              MindSetu brings familiar cultural stories, foods, festivals, and landmarks from your homeland.
            </p>

            <div className="grid grid-cols-2 md-grid-cols-1 gap-3 mb-6" style={{ maxHeight: '340px', overflowY: 'auto' }}>
              {NER_STATES.map((state) => {
                const isSelected = formData.region === state.id;
                return (
                  <div
                    key={state.id}
                    className={`card card-interactive ${isSelected ? 'card-highlight' : ''}`}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.75rem',
                      padding: '1rem',
                      border: isSelected ? '2.5px solid var(--primary-600)' : '1.5px solid var(--border-color)'
                    }}
                    onClick={() => handleStateSelect(state.id)}
                  >
                    <span style={{ fontSize: '2rem' }}>{state.symbol}</span>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, color: 'var(--text-main)' }}>
                        {state.name}
                      </div>
                      <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
                        {state.culturalHighlights.landmarks[0]}
                      </div>
                    </div>
                    {isSelected && (
                      <CheckCircle2 size={22} color="var(--primary-600)" />
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* STEP 4: REGIONAL LANGUAGE CHOICES */}
        {step === 4 && (
          <div>
            <h3 style={{ marginBottom: '0.5rem' }}>
              Step 4: Select Preferred Language
            </h3>
            <p style={{ marginBottom: '1.5rem' }}>
              Recommended based on <strong>{selectedStateObj.name}</strong>, or choose any language you feel comfortable with.
            </p>

            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ fontSize: 'var(--font-size-sm)', fontWeight: 700, color: 'var(--primary-800)', marginBottom: '0.75rem' }}>
                ⭐ Recommended for {selectedStateObj.name}:
              </div>
              <div className="flex flex-wrap gap-2 mb-4">
                {selectedStateObj.primaryLanguages.map((lang) => (
                  <button
                    key={lang}
                    className={`btn ${formData.language === lang ? 'btn-primary' : 'btn-outline'}`}
                    style={{ minHeight: '46px' }}
                    onClick={() => setFormData({ ...formData, language: lang })}
                  >
                    {lang}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <div style={{ fontSize: 'var(--font-size-sm)', fontWeight: 700, color: 'var(--text-subtle)', marginBottom: '0.75rem' }}>
                All Supported Languages:
              </div>
              <div className="grid grid-cols-3 md-grid-cols-2 gap-2" style={{ maxHeight: '180px', overflowY: 'auto' }}>
                {ALL_LANGUAGES.map((lang) => {
                  const isSelected = formData.language === lang.name;
                  return (
                    <button
                      key={lang.code}
                      className={`btn ${isSelected ? 'btn-secondary' : 'btn-outline'}`}
                      style={{
                        minHeight: '44px',
                        padding: '0.4rem 0.75rem',
                        fontSize: 'var(--font-size-sm)',
                        borderColor: isSelected ? 'var(--primary-600)' : 'var(--border-color)'
                      }}
                      onClick={() => setFormData({ ...formData, language: lang.name })}
                    >
                      {lang.nativeName} ({lang.name})
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        )}

        {/* STEP 5: OPTIONAL PREFERENCES FOR PERSONALIZATION */}
        {step === 5 && (
          <div>
            <h3 style={{ marginBottom: '0.5rem' }}>
              Step 5: Comfort & Familiar Preferences
            </h3>
            <p style={{ marginBottom: '1.5rem' }}>
              Select a few things that bring joy and calm memories to {formData.name}.
            </p>

            <div style={{ maxHeight: '340px', overflowY: 'auto', paddingRight: '0.5rem' }}>
              {/* Activities */}
              <div style={{ marginBottom: '1.25rem' }}>
                <h4 style={{ fontSize: 'var(--font-size-base)', color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
                  🍃 Favourite Activities
                </h4>
                <div className="flex flex-wrap gap-2">
                  {PREFERENCE_OPTIONS.activities.map((act) => {
                    const active = formData.preferences.activities?.includes(act);
                    return (
                      <button
                        key={act}
                        className={`btn ${active ? 'btn-primary' : 'btn-outline'}`}
                        style={{ minHeight: '42px', fontSize: 'var(--font-size-sm)', padding: '0.4rem 0.8rem' }}
                        onClick={() => togglePreference('activities', act)}
                      >
                        {act}
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Foods */}
              <div style={{ marginBottom: '1.25rem' }}>
                <h4 style={{ fontSize: 'var(--font-size-base)', color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
                  🍲 Comfort Foods of the Region
                </h4>
                <div className="flex flex-wrap gap-2">
                  {PREFERENCE_OPTIONS.foods.map((food) => {
                    const active = formData.preferences.foods?.includes(food);
                    return (
                      <button
                        key={food}
                        className={`btn ${active ? 'btn-primary' : 'btn-outline'}`}
                        style={{ minHeight: '42px', fontSize: 'var(--font-size-sm)', padding: '0.4rem 0.8rem' }}
                        onClick={() => togglePreference('foods', food)}
                      >
                        {food}
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Familiar Places */}
              <div>
                <h4 style={{ fontSize: 'var(--font-size-base)', color: 'var(--primary-900)', marginBottom: '0.5rem' }}>
                  🏞️ Peaceful Places
                </h4>
                <div className="flex flex-wrap gap-2">
                  {PREFERENCE_OPTIONS.places.map((place) => {
                    const active = formData.preferences.places?.includes(place);
                    return (
                      <button
                        key={place}
                        className={`btn ${active ? 'btn-primary' : 'btn-outline'}`}
                        style={{ minHeight: '42px', fontSize: 'var(--font-size-sm)', padding: '0.4rem 0.8rem' }}
                        onClick={() => togglePreference('places', place)}
                      >
                        {place}
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Wizard Footer Controls */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginTop: '2rem',
            paddingTop: '1.25rem',
            borderTop: '1.5px solid var(--border-subtle)'
          }}
        >
          <button
            className="btn btn-outline"
            onClick={handleBack}
            style={{ minWidth: '120px' }}
          >
            <ArrowLeft size={18} />
            <span>{step === 1 ? 'Cancel' : 'Back'}</span>
          </button>

          <button
            className="btn btn-primary btn-lg"
            onClick={handleNext}
            style={{ minWidth: '160px' }}
          >
            <span>{step === 5 || (step === 1 && formData.role !== 'patient') ? 'Complete & Enter' : 'Next Step'}</span>
            <ArrowRight size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}
