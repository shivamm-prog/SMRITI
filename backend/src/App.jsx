import React, { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { AccessibilityProvider } from './context/AccessibilityContext';
import { DataProvider } from './context/DataContext';

import { Header } from './components/common/Header';
import { BottomNav } from './components/common/BottomNav';
import { OnboardingFlow } from './components/onboarding/OnboardingFlow';

// Patient Views
import { PatientHome } from './components/patient/PatientHome';
import { ActivityRunner } from './components/activities/ActivityRunner';
import { PatientMemories } from './components/patient/PatientMemories';
import { PatientReminders } from './components/patient/PatientReminders';
import { PatientProgress } from './components/patient/PatientProgress';
import { PatientProfile } from './components/patient/PatientProfile';
import { AddReminderModal } from './components/caregiver/AddReminderModal';

// Caregiver Views
import { CaregiverDashboard } from './components/caregiver/CaregiverDashboard';
import { CaregiverNotesView } from './components/caregiver/CaregiverNotesView';
import { CaregiverResources } from './components/caregiver/CaregiverResources';

// Doctor Views
import { DoctorDashboard } from './components/doctor/DoctorDashboard';
import { DoctorPatientDetails } from './components/doctor/DoctorPatientDetails';
import { DoctorInsights } from './components/doctor/DoctorInsights';
import { DoctorReports } from './components/doctor/DoctorReports';

function AppContent() {
  const { role, isOnboarding } = useAuth();

  // Tab state per role
  const [patientTab, setPatientTab] = useState('home');
  const [caregiverTab, setCaregiverTab] = useState('dashboard');
  const [doctorTab, setDoctorTab] = useState('dashboard');

  // Selected cognitive activity for direct runner launch
  const [selectedActivityId, setSelectedActivityId] = useState(null);

  // Selected patient for doctor detail / report
  const [selectedDoctorPatient, setSelectedDoctorPatient] = useState(null);

  // Global Add Reminder modal trigger
  const [showAddReminderModal, setShowAddReminderModal] = useState(false);

  // Reset tab when role changes
  useEffect(() => {
    setSelectedActivityId(null);
  }, [role]);

  // If onboarding is triggered
  if (isOnboarding) {
    return <OnboardingFlow />;
  }

  // Active tab getter & setter based on active role
  const getActiveTab = () => {
    if (role === 'patient') return patientTab;
    if (role === 'caregiver') return caregiverTab;
    if (role === 'doctor') return doctorTab;
    return 'home';
  };

  const handleTabChange = (newTab) => {
    setSelectedActivityId(null);
    if (role === 'patient') setPatientTab(newTab);
    else if (role === 'caregiver') setCaregiverTab(newTab);
    else if (role === 'doctor') setDoctorTab(newTab);
  };

  const handleStartActivityFromHome = (activityId) => {
    setSelectedActivityId(activityId);
    setPatientTab('activities');
  };

  const handleSelectPatientForDoctor = (patient) => {
    setSelectedDoctorPatient(patient);
    setDoctorTab('details');
  };

  const handleGenerateReportForDoctor = (patient) => {
    setSelectedDoctorPatient(patient);
    setDoctorTab('reports');
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Header activeTab={getActiveTab()} onTabChange={handleTabChange} />

      <main className="app-main" style={{ flex: 1 }}>
        {/* PATIENT ROLE VIEWS */}
        {role === 'patient' && (
          <>
            {patientTab === 'home' && (
              <PatientHome
                onNavigateTab={handleTabChange}
                onStartActivity={handleStartActivityFromHome}
              />
            )}
            {patientTab === 'activities' && (
              <ActivityRunner initialActivityId={selectedActivityId} />
            )}
            {patientTab === 'memories' && <PatientMemories />}
            {patientTab === 'reminders' && (
              <PatientReminders onOpenAddReminder={() => setShowAddReminderModal(true)} />
            )}
            {patientTab === 'progress' && <PatientProgress />}
            {patientTab === 'profile' && <PatientProfile />}
          </>
        )}

        {/* CAREGIVER ROLE VIEWS */}
        {role === 'caregiver' && (
          <>
            {caregiverTab === 'dashboard' && (
              <CaregiverDashboard onNavigateTab={handleTabChange} />
            )}
            {caregiverTab === 'notes' && <CaregiverNotesView />}
            {caregiverTab === 'reminders' && (
              <PatientReminders onOpenAddReminder={() => setShowAddReminderModal(true)} />
            )}
            {caregiverTab === 'memories' && <PatientMemories />}
            {caregiverTab === 'resources' && <CaregiverResources />}
          </>
        )}

        {/* DOCTOR ROLE VIEWS */}
        {role === 'doctor' && (
          <>
            {doctorTab === 'dashboard' && (
              <DoctorDashboard
                onSelectPatient={handleSelectPatientForDoctor}
                onNavigateTab={handleTabChange}
              />
            )}
            {doctorTab === 'details' && (
              <DoctorPatientDetails
                patient={selectedDoctorPatient}
                onBack={() => setDoctorTab('dashboard')}
                onGenerateReport={handleGenerateReportForDoctor}
              />
            )}
            {doctorTab === 'insights' && <DoctorInsights />}
            {doctorTab === 'reports' && (
              <DoctorReports selectedPatient={selectedDoctorPatient} />
            )}
          </>
        )}
      </main>

      {/* Accessible Footer Notice for Evaluators & Users */}
      <footer
        style={{
          borderTop: '1px solid var(--border-subtle)',
          backgroundColor: 'var(--bg-card)',
          padding: '1.25rem 0',
          marginTop: 'auto'
        }}
      >
        <div className="container flex items-center justify-between flex-wrap gap-2 text-center">
          <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--text-subtle)' }}>
            MindSetu • Smart India Hackathon 2026 • North Eastern Region Senior Dementia Care
          </div>
          <div style={{ fontSize: 'var(--font-size-xs)', color: 'var(--primary-700)', fontWeight: 600 }}>
            Offline-Ready • Multi-Lingual NER Architecture • Zero Backend Dependency
          </div>
        </div>
      </footer>

      {/* Mobile / Tablet Bottom Navigation */}
      <BottomNav activeTab={getActiveTab()} onTabChange={handleTabChange} />

      {/* Global Add Reminder Modal */}
      <AddReminderModal
        isOpen={showAddReminderModal}
        onClose={() => setShowAddReminderModal(false)}
      />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AccessibilityProvider>
        <DataProvider>
          <AppContent />
        </DataProvider>
      </AccessibilityProvider>
    </AuthProvider>
  );
}
