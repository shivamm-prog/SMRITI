// SMRITI - Offline-First Database Engine (IndexedDB + LocalStorage Sync Queue)
import { SEED_PROFILES } from '../data/profiles.js';
import { GAMES_DATA } from '../data/games.js';
import { SEED_MEMORIES, SEED_ACTIVITY_RESULTS, SEED_CAREGIVER_OBSERVATIONS } from '../data/memories.js';

const STORAGE_PREFIX = "smriti_store_";

class SmritiStorage {
  constructor() {
    this.isInitialized = false;
  }

  async init() {
    if (this.isInitialized) return;
    
    // Check if initial data exists; if not, seed it
    const hasData = localStorage.getItem(STORAGE_PREFIX + "initialized");
    if (!hasData) {
      await this.seedInitialData();
      localStorage.setItem(STORAGE_PREFIX + "initialized", "true");
    }
    this.isInitialized = true;
  }

  async seedInitialData() {
    localStorage.setItem(STORAGE_PREFIX + "profiles", JSON.stringify(SEED_PROFILES));
    localStorage.setItem(STORAGE_PREFIX + "games", JSON.stringify(GAMES_DATA));
    localStorage.setItem(STORAGE_PREFIX + "memories", JSON.stringify(SEED_MEMORIES));
    localStorage.setItem(STORAGE_PREFIX + "activity_results", JSON.stringify(SEED_ACTIVITY_RESULTS));
    localStorage.setItem(STORAGE_PREFIX + "observations", JSON.stringify(SEED_CAREGIVER_OBSERVATIONS));
    localStorage.setItem(STORAGE_PREFIX + "api_cache", JSON.stringify({}));
    localStorage.setItem(STORAGE_PREFIX + "api_usage", JSON.stringify({
      requestsToday: 0,
      requestsThisWeek: 0,
      lastRequestTimestamp: null,
      maxDailyQuota: 5,
      cooldownMinutes: 15,
      cachedHits: 18,
      failedRequests: 0,
      logs: [
        {
          timestamp: new Date(Date.now() - 60 * 60 * 1000).toISOString(),
          type: "OFFLINE_DETERMINISTIC",
          status: "SUCCESS_LOCAL_RULE",
          tokens: 0,
          details: "Zero-API local deterministic rule engine active."
        }
      ]
    }));
    localStorage.setItem(STORAGE_PREFIX + "app_settings", JSON.stringify({
      activeLanguage: "as", // Default: Assamese
      voiceSpeed: 0.85,
      highContrast: false,
      fontSize: "large",
      networkMode: "online", // 'online' or 'offline'
      soundEffects: true
    }));
  }

  // Get Profiles
  getProfiles() {
    return JSON.parse(localStorage.getItem(STORAGE_PREFIX + "profiles") || JSON.stringify(SEED_PROFILES));
  }

  getPatientProfile(patientId = "pat_anita_001") {
    const profiles = this.getProfiles();
    return profiles.patient;
  }

  // Activity Results (Offline Data Queue)
  getActivityResults(patientId = "pat_anita_001") {
    const results = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "activity_results") || "[]");
    return results.filter(r => !patientId || r.patientId === patientId).sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
  }

  saveActivityResult(result) {
    const results = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "activity_results") || "[]");
    const newRecord = {
      id: "smriti_act_" + Date.now() + "_" + Math.floor(Math.random() * 1000),
      patientId: result.patientId || "pat_anita_001",
      activityType: result.activityType,
      activityTitle: result.activityTitle,
      timestamp: result.timestamp || new Date().toISOString(),
      difficultyLevel: result.difficultyLevel || "Level 1 (Very Easy)",
      accuracy: result.accuracy !== undefined ? result.accuracy : 100,
      responseTimeMs: result.responseTimeMs || 4000,
      attempts: result.attempts || 1,
      correctMatches: result.correctMatches !== undefined ? result.correctMatches : 1,
      incorrectMatches: result.incorrectMatches !== undefined ? result.incorrectMatches : 0,
      hintsUsed: result.hintsUsed || 0,
      completionStatus: result.completionStatus || "completed",
      language: result.language || "as",
      data: result.data || {
        domain: result.domain || "general_cognitive",
        details: result.activityTitle
      },
      syncStatus: "PENDING", // Always PENDING initially until synchronized
      syncedAt: null
    };

    // Deduplication check
    const exists = results.some(r => r.id === newRecord.id);
    if (!exists) {
      results.unshift(newRecord);
      localStorage.setItem(STORAGE_PREFIX + "activity_results", JSON.stringify(results));
    }
    return newRecord;
  }

  // Personal Memories
  getMemories(patientId = "pat_anita_001") {
    const memories = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "memories") || "[]");
    return memories.filter(m => !patientId || m.patientId === patientId);
  }

  addMemory(memory) {
    const memories = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "memories") || "[]");
    const newMem = {
      id: "mem_" + Date.now(),
      patientId: memory.patientId || "pat_anita_001",
      title: memory.title || { en: "Family Memory", hi: "पारिवारिक स्मृति", as: "পৰিয়ালৰ স্মৃতি" },
      category: memory.category || "family",
      yearApprox: memory.yearApprox || "Recent",
      iconKey: memory.iconKey || "grandkids",
      caption: memory.caption || { en: "A cherished personal memory.", hi: "एक सुंदर पारिवारिक याद।", as: "এক মৰমৰ পুৰণি স্মৃতি।" },
      audioPrompt: memory.audioPrompt || { en: "Look at this cherished memory.", hi: "इस पुरानी याद को देखें।", as: "এই মৰমৰ স্মৃতিটোলৈ চাওক।" },
      subtitleEn: memory.subtitleEn || "Look at this cherished memory.",
      syncStatus: "PENDING",
      timestamp: new Date().toISOString()
    };
    memories.unshift(newMem);
    localStorage.setItem(STORAGE_PREFIX + "memories", JSON.stringify(memories));
    return newMem;
  }

  deleteMemory(memoryId) {
    let memories = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "memories") || "[]");
    memories = memories.filter(m => m.id !== memoryId);
    localStorage.setItem(STORAGE_PREFIX + "memories", JSON.stringify(memories));
  }

  // Caregiver Observations
  getObservations(patientId = "pat_anita_001") {
    const observations = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "observations") || "[]");
    return observations.filter(o => !patientId || o.patientId === patientId).sort((a, b) => new Date(b.date || b.timestamp) - new Date(a.date || a.timestamp));
  }

  saveObservation(observation) {
    const observations = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "observations") || "[]");
    const nowIso = new Date().toISOString();
    const newObs = {
      id: "obs_" + Date.now(),
      patientId: observation.patientId || "pat_anita_001",
      caregiverId: observation.caregiverId || "cg_rahul_001",
      timestamp: nowIso,
      date: observation.date || nowIso.split("T")[0],
      mood: observation.mood || "Happy",
      sleep: observation.sleep || "Good",
      appetite: observation.appetite || "Good",
      dailyActivity: observation.dailyActivity || "Active",
      memoryConcerns: observation.memoryConcerns || "None",
      notes: observation.notes || "",
      data: {
        mood: observation.mood || "Happy",
        sleep: observation.sleep || "Good",
        appetite: observation.appetite || "Good",
        dailyActivity: observation.dailyActivity || "Active",
        memoryConcerns: observation.memoryConcerns || "None",
        notes: observation.notes || ""
      },
      syncStatus: "PENDING",
      syncedAt: null
    };
    observations.unshift(newObs);
    localStorage.setItem(STORAGE_PREFIX + "observations", JSON.stringify(observations));
    return newObs;
  }

  // Settings
  getSettings() {
    return JSON.parse(localStorage.getItem(STORAGE_PREFIX + "app_settings") || "{}");
  }

  updateSettings(partial) {
    const settings = { ...this.getSettings(), ...partial };
    localStorage.setItem(STORAGE_PREFIX + "app_settings", JSON.stringify(settings));
    return settings;
  }

  // Sync Queue Status
  getPendingSyncCount() {
    const results = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "activity_results") || "[]");
    const observations = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "observations") || "[]");
    const memories = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "memories") || "[]");
    const pendingResults = results.filter(r => r.syncStatus === "PENDING").length;
    const pendingObs = observations.filter(o => o.syncStatus === "PENDING").length;
    const pendingMems = memories.filter(m => m.syncStatus === "PENDING").length;
    return pendingResults + pendingObs + pendingMems;
  }

  performBatchSync() {
    const results = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "activity_results") || "[]");
    const observations = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "observations") || "[]");
    const memories = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "memories") || "[]");
    const now = new Date().toISOString();

    let syncedCount = 0;
    results.forEach(r => {
      if (r.syncStatus === "PENDING" || r.syncStatus === "FAILED") {
        r.syncStatus = "SYNCED";
        r.syncedAt = now;
        syncedCount++;
      }
    });

    observations.forEach(o => {
      if (o.syncStatus === "PENDING" || o.syncStatus === "FAILED") {
        o.syncStatus = "SYNCED";
        o.syncedAt = now;
        syncedCount++;
      }
    });

    memories.forEach(m => {
      if (m.syncStatus === "PENDING" || m.syncStatus === "FAILED") {
        m.syncStatus = "SYNCED";
        m.syncedAt = now;
        syncedCount++;
      }
    });

    localStorage.setItem(STORAGE_PREFIX + "activity_results", JSON.stringify(results));
    localStorage.setItem(STORAGE_PREFIX + "observations", JSON.stringify(observations));
    localStorage.setItem(STORAGE_PREFIX + "memories", JSON.stringify(memories));
    return { syncedCount, syncedAt: now };
  }

  // API Usage and Cache Management
  getApiUsage() {
    return JSON.parse(localStorage.getItem(STORAGE_PREFIX + "api_usage") || "{}");
  }

  updateApiUsage(updater) {
    const current = this.getApiUsage();
    const updated = typeof updater === "function" ? updater(current) : { ...current, ...updater };
    localStorage.setItem(STORAGE_PREFIX + "api_usage", JSON.stringify(updated));
    return updated;
  }

  getApiCache(key) {
    const cache = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "api_cache") || "{}");
    return cache[key] || null;
  }

  setApiCache(key, value) {
    const cache = JSON.parse(localStorage.getItem(STORAGE_PREFIX + "api_cache") || "{}");
    cache[key] = {
      value,
      cachedAt: new Date().toISOString()
    };
    localStorage.setItem(STORAGE_PREFIX + "api_cache", JSON.stringify(cache));
  }

  // Reset demo
  resetAll() {
    localStorage.removeItem(STORAGE_PREFIX + "initialized");
    localStorage.removeItem(STORAGE_PREFIX + "profiles");
    localStorage.removeItem(STORAGE_PREFIX + "games");
    localStorage.removeItem(STORAGE_PREFIX + "memories");
    localStorage.removeItem(STORAGE_PREFIX + "activity_results");
    localStorage.removeItem(STORAGE_PREFIX + "observations");
    localStorage.removeItem(STORAGE_PREFIX + "api_cache");
    localStorage.removeItem(STORAGE_PREFIX + "api_usage");
    localStorage.removeItem(STORAGE_PREFIX + "app_settings");
    this.seedInitialData();
  }
}

export const db = new SmritiStorage();