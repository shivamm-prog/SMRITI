import React, { createContext, useContext, useState, useEffect } from 'react';
import { storageService } from '../services/storageService';

const DataContext = createContext(null);

export function DataProvider({ children }) {
  const [reminders, setReminders] = useState([]);
  const [memories, setMemories] = useState([]);
  const [dailyNotes, setDailyNotes] = useState([]);
  const [activityResults, setActivityResults] = useState([]);
  const [clinicalInsights, setClinicalInsights] = useState([]);
  const [syncQueue, setSyncQueue] = useState([]);
  
  // Offline state (Hardware listener + Manual evaluation override)
  const [isOfflineManual, setIsOfflineManual] = useState(() => storageService.getOfflineOverride());
  const [isBrowserOnline, setIsBrowserOnline] = useState(() => navigator.onLine);
  const [isSyncing, setIsSyncing] = useState(false);

  const isOffline = isOfflineManual || !isBrowserOnline;

  const reloadAllData = () => {
    storageService.initialize();
    setReminders(storageService.getReminders());
    setMemories(storageService.getMemories());
    setDailyNotes(storageService.getDailyNotes());
    setActivityResults(storageService.getActivityResults());
    setClinicalInsights(storageService.getClinicalInsights());
    setSyncQueue(storageService.getSyncQueue());
  };

  useEffect(() => {
    reloadAllData();

    const handleOnline = () => setIsBrowserOnline(true);
    const handleOffline = () => setIsBrowserOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  const toggleOfflineSimulation = () => {
    const nextVal = !isOfflineManual;
    setIsOfflineManual(nextVal);
    storageService.setOfflineOverride(nextVal);
  };

  // Reminder actions
  const toggleReminder = (reminderId) => {
    const updated = storageService.toggleReminder(reminderId);
    setReminders(updated);
    setSyncQueue(storageService.getSyncQueue());
  };

  const addReminder = (newRem) => {
    storageService.addReminder(newRem);
    setReminders(storageService.getReminders());
    setSyncQueue(storageService.getSyncQueue());
  };

  const verifyReminder = (reminderId) => {
    const updated = storageService.verifyReminder(reminderId);
    setReminders(updated);
    setSyncQueue(storageService.getSyncQueue());
  };

  // Memory actions
  const addMemory = (memoryData) => {
    storageService.addMemory(memoryData);
    setMemories(storageService.getMemories());
    setSyncQueue(storageService.getSyncQueue());
  };

  // Daily note actions (Caregiver)
  const addDailyNote = (noteData) => {
    storageService.addDailyNote(noteData);
    setDailyNotes(storageService.getDailyNotes());
    setSyncQueue(storageService.getSyncQueue());
  };

  // Cognitive Activity result recording
  const recordActivityResult = (resultData) => {
    storageService.addActivityResult(resultData);
    setActivityResults(storageService.getActivityResults());
    setSyncQueue(storageService.getSyncQueue());
  };

  // Sync Now action (flushes sync queue)
  const syncNow = async () => {
    setIsSyncing(true);
    // Simulate brief network roundtrip
    await new Promise(resolve => setTimeout(resolve, 800));
    storageService.clearSyncQueue();
    reloadAllData();
    setIsSyncing(false);
  };

  const resetAllData = () => {
    storageService.resetAll();
    reloadAllData();
  };

  return (
    <DataContext.Provider
      value={{
        reminders,
        memories,
        dailyNotes,
        activityResults,
        clinicalInsights,
        syncQueue,
        isOffline,
        isOfflineManual,
        isSyncing,
        toggleOfflineSimulation,
        toggleReminder,
        addReminder,
        verifyReminder,
        addMemory,
        addDailyNote,
        recordActivityResult,
        syncNow,
        resetAllData,
        reloadAllData
      }}
    >
      {children}
    </DataContext.Provider>
  );
}

export function useData() {
  const context = useContext(DataContext);
  if (!context) {
    throw new Error('useData must be used within a DataProvider');
  }
  return context;
}
