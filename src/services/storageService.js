// Storage Service - Offline-first LocalStorage persistence for MindSetu

import {
  INITIAL_USERS,
  INITIAL_REMINDERS,
  INITIAL_MEMORIES,
  INITIAL_DAILY_NOTES,
  INITIAL_ACTIVITY_RESULTS,
  INITIAL_CLINICAL_INSIGHTS
} from '../data/initialMockData';

const KEYS = {
  USERS: 'mindsetu_users_v1',
  CURRENT_USER: 'mindsetu_current_user_v1',
  REMINDERS: 'mindsetu_reminders_v1',
  MEMORIES: 'mindsetu_memories_v1',
  DAILY_NOTES: 'mindsetu_daily_notes_v1',
  ACTIVITY_RESULTS: 'mindsetu_activity_results_v1',
  CLINICAL_INSIGHTS: 'mindsetu_clinical_insights_v1',
  SYNC_QUEUE: 'mindsetu_sync_queue_v1',
  OFFLINE_OVERRIDE: 'mindsetu_offline_override_v1',
  ACCESSIBILITY_SETTINGS: 'mindsetu_accessibility_v1'
};

export const storageService = {
  // Initialize storage with defaults if not present
  initialize() {
    if (!localStorage.getItem(KEYS.USERS)) {
      localStorage.setItem(KEYS.USERS, JSON.stringify(INITIAL_USERS));
    }
    if (!localStorage.getItem(KEYS.CURRENT_USER)) {
      // Default to the first patient (Bhaben Borah)
      localStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(INITIAL_USERS[0]));
    }
    if (!localStorage.getItem(KEYS.REMINDERS)) {
      localStorage.setItem(KEYS.REMINDERS, JSON.stringify(INITIAL_REMINDERS));
    }
    if (!localStorage.getItem(KEYS.MEMORIES)) {
      localStorage.setItem(KEYS.MEMORIES, JSON.stringify(INITIAL_MEMORIES));
    }
    if (!localStorage.getItem(KEYS.DAILY_NOTES)) {
      localStorage.setItem(KEYS.DAILY_NOTES, JSON.stringify(INITIAL_DAILY_NOTES));
    }
    if (!localStorage.getItem(KEYS.ACTIVITY_RESULTS)) {
      localStorage.setItem(KEYS.ACTIVITY_RESULTS, JSON.stringify(INITIAL_ACTIVITY_RESULTS));
    }
    if (!localStorage.getItem(KEYS.CLINICAL_INSIGHTS)) {
      localStorage.setItem(KEYS.CLINICAL_INSIGHTS, JSON.stringify(INITIAL_CLINICAL_INSIGHTS));
    }
    if (!localStorage.getItem(KEYS.SYNC_QUEUE)) {
      localStorage.setItem(KEYS.SYNC_QUEUE, JSON.stringify([]));
    }
  },

  // Reset all to clean initial state
  resetAll() {
    localStorage.removeItem(KEYS.USERS);
    localStorage.removeItem(KEYS.CURRENT_USER);
    localStorage.removeItem(KEYS.REMINDERS);
    localStorage.removeItem(KEYS.MEMORIES);
    localStorage.removeItem(KEYS.DAILY_NOTES);
    localStorage.removeItem(KEYS.ACTIVITY_RESULTS);
    localStorage.removeItem(KEYS.CLINICAL_INSIGHTS);
    localStorage.removeItem(KEYS.SYNC_QUEUE);
    this.initialize();
  },

  // USER MANAGEMENT
  getUsers() {
    return JSON.parse(localStorage.getItem(KEYS.USERS) || '[]');
  },

  getCurrentUser() {
    return JSON.parse(localStorage.getItem(KEYS.CURRENT_USER) || JSON.stringify(INITIAL_USERS[0]));
  },

  setCurrentUser(user) {
    localStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(user));
  },

  addUser(user) {
    const users = this.getUsers();
    const existingIndex = users.findIndex(u => u.id === user.id);
    if (existingIndex >= 0) {
      users[existingIndex] = user;
    } else {
      users.push(user);
    }
    localStorage.setItem(KEYS.USERS, JSON.stringify(users));
    this.addToSyncQueue('USER_SAVED', { userId: user.id, name: user.name });
    return user;
  },

  updateUserProfile(updatedData) {
    const currentUser = this.getCurrentUser();
    const updated = { ...currentUser, ...updatedData };
    this.setCurrentUser(updated);

    const users = this.getUsers();
    const index = users.findIndex(u => u.id === updated.id);
    if (index >= 0) {
      users[index] = updated;
      localStorage.setItem(KEYS.USERS, JSON.stringify(users));
    }
    this.addToSyncQueue('USER_PROFILE_UPDATED', { userId: updated.id });
    return updated;
  },

  // REMINDERS
  getReminders(patientId = null) {
    const reminders = JSON.parse(localStorage.getItem(KEYS.REMINDERS) || '[]');
    if (patientId) {
      return reminders.filter(r => r.patientId === patientId);
    }
    return reminders;
  },

  addReminder(reminder) {
    const reminders = this.getReminders();
    const newReminder = {
      ...reminder,
      id: `rem-${Date.now()}`,
      completed: false,
      completedAt: null,
      verifiedByCaregiver: false,
      syncStatus: 'Pending Sync'
    };
    reminders.unshift(newReminder);
    localStorage.setItem(KEYS.REMINDERS, JSON.stringify(reminders));
    this.addToSyncQueue('REMINDER_ADDED', { reminderId: newReminder.id, title: newReminder.title });
    return newReminder;
  },

  toggleReminder(reminderId) {
    const reminders = this.getReminders();
    const updated = reminders.map(rem => {
      if (rem.id === reminderId) {
        const nextState = !rem.completed;
        return {
          ...rem,
          completed: nextState,
          completedAt: nextState ? `Today, ${new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}` : null,
          syncStatus: 'Pending Sync'
        };
      }
      return rem;
    });
    localStorage.setItem(KEYS.REMINDERS, JSON.stringify(updated));
    this.addToSyncQueue('REMINDER_TOGGLED', { reminderId });
    return updated;
  },

  verifyReminder(reminderId) {
    const reminders = this.getReminders();
    const updated = reminders.map(rem => {
      if (rem.id === reminderId) {
        return {
          ...rem,
          verifiedByCaregiver: true,
          syncStatus: 'Pending Sync'
        };
      }
      return rem;
    });
    localStorage.setItem(KEYS.REMINDERS, JSON.stringify(updated));
    this.addToSyncQueue('REMINDER_VERIFIED', { reminderId });
    return updated;
  },

  // MEMORIES
  getMemories(patientId = null) {
    const memories = JSON.parse(localStorage.getItem(KEYS.MEMORIES) || '[]');
    if (patientId) {
      return memories.filter(m => m.patientId === patientId);
    }
    return memories;
  },

  addMemory(memory) {
    const memories = this.getMemories();
    const newMemory = {
      ...memory,
      id: `mem-${Date.now()}`,
      syncStatus: 'Pending Sync'
    };
    memories.unshift(newMemory);
    localStorage.setItem(KEYS.MEMORIES, JSON.stringify(memories));
    this.addToSyncQueue('MEMORY_CREATED', { memoryId: newMemory.id, title: newMemory.title });
    return newMemory;
  },

  // DAILY NOTES (CAREGIVER)
  getDailyNotes(patientId = null) {
    const notes = JSON.parse(localStorage.getItem(KEYS.DAILY_NOTES) || '[]');
    if (patientId) {
      return notes.filter(n => n.patientId === patientId);
    }
    return notes;
  },

  addDailyNote(note) {
    const notes = this.getDailyNotes();
    const newNote = {
      ...note,
      id: `note-${Date.now()}`,
      date: `Today, ${new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`,
      timestamp: new Date().toISOString(),
      syncStatus: 'Pending Sync'
    };
    notes.unshift(newNote);
    localStorage.setItem(KEYS.DAILY_NOTES, JSON.stringify(notes));
    this.addToSyncQueue('DAILY_NOTE_LOGGED', { noteId: newNote.id, author: newNote.author });
    return newNote;
  },

  // ACTIVITY RESULTS / COGNITIVE HISTORY
  getActivityResults(patientId = null) {
    const results = JSON.parse(localStorage.getItem(KEYS.ACTIVITY_RESULTS) || '[]');
    if (patientId) {
      return results.filter(r => r.patientId === patientId);
    }
    return results;
  },

  addActivityResult(result) {
    const results = this.getActivityResults();
    const newResult = {
      ...result,
      id: `res-${Date.now()}`,
      completedAt: `Today, ${new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`,
      timestamp: new Date().toISOString(),
      syncStatus: 'Pending Sync'
    };
    results.unshift(newResult);
    localStorage.setItem(KEYS.ACTIVITY_RESULTS, JSON.stringify(results));
    this.addToSyncQueue('ACTIVITY_RECORDED', {
      resultId: newResult.id,
      activityTitle: newResult.activityTitle,
      score: newResult.score
    });
    return newResult;
  },

  // CLINICAL INSIGHTS
  getClinicalInsights(patientId = null) {
    const insights = JSON.parse(localStorage.getItem(KEYS.CLINICAL_INSIGHTS) || '[]');
    if (patientId) {
      return insights.filter(i => i.patientId === patientId);
    }
    return insights;
  },

  // SYNC QUEUE & OFFLINE PREPARATION
  getSyncQueue() {
    return JSON.parse(localStorage.getItem(KEYS.SYNC_QUEUE) || '[]');
  },

  addToSyncQueue(action, payload) {
    const queue = this.getSyncQueue();
    const item = {
      id: `sync-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
      action,
      payload,
      createdAt: new Date().toISOString(),
      status: 'pending'
    };
    queue.push(item);
    localStorage.setItem(KEYS.SYNC_QUEUE, JSON.stringify(queue));
    return item;
  },

  clearSyncQueue() {
    localStorage.setItem(KEYS.SYNC_QUEUE, JSON.stringify([]));
    // Also remove 'Pending Sync' markers
    const markSynced = key => {
      const items = JSON.parse(localStorage.getItem(key) || '[]');
      const updated = items.map(i => ({ ...i, syncStatus: 'Synced' }));
      localStorage.setItem(key, JSON.stringify(updated));
    };
    markSynced(KEYS.REMINDERS);
    markSynced(KEYS.MEMORIES);
    markSynced(KEYS.DAILY_NOTES);
    markSynced(KEYS.ACTIVITY_RESULTS);
  },

  // ACCESSIBILITY SETTINGS
  getAccessibilitySettings() {
    return JSON.parse(localStorage.getItem(KEYS.ACCESSIBILITY_SETTINGS) || JSON.stringify({
      largeText: false,
      highContrast: false,
      soundFeedback: true,
      simpleLanguage: true
    }));
  },

  saveAccessibilitySettings(settings) {
    localStorage.setItem(KEYS.ACCESSIBILITY_SETTINGS, JSON.stringify(settings));
  },

  // MANUAL OFFLINE SIMULATION
  getOfflineOverride() {
    const val = localStorage.getItem(KEYS.OFFLINE_OVERRIDE);
    return val !== null ? JSON.parse(val) : false;
  },

  setOfflineOverride(isOffline) {
    localStorage.setItem(KEYS.OFFLINE_OVERRIDE, JSON.stringify(isOffline));
  }
};
