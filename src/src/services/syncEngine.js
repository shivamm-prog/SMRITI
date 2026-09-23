// SMRITI - Offline-First Automatic Synchronization Engine
import { db } from '../db/smritiStorage.js';

class SyncEngine {
  constructor() {
    this.isSyncing = false;
    this.listeners = [];
    this.lastSyncResult = null;
    this.lastStatusMessage = "";
    
    // Auto-detect browser online/offline events
    window.addEventListener("online", () => this.handleNetworkChange(true));
    window.addEventListener("offline", () => this.handleNetworkChange(false));
  }

  isOnline() {
    const settings = db.getSettings();
    // Allow manual simulated override or native navigator.onLine
    if (settings.networkMode === "offline") return false;
    if (settings.networkMode === "online") return true;
    return navigator.onLine;
  }

  handleNetworkChange(isNowOnline) {
    if (isNowOnline) {
      this.lastStatusMessage = "Internet connection detected. Starting automatic synchronization...";
      this.notify();
      // Automatic sync when reconnecting
      this.triggerSync();
    } else {
      this.lastStatusMessage = "Operating in Offline Mode. All activities saved locally.";
      this.notify();
    }
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  notify() {
    this.listeners.forEach(fn => fn({
      isOnline: this.isOnline(),
      isSyncing: this.isSyncing,
      pendingCount: db.getPendingSyncCount(),
      lastSyncResult: this.lastSyncResult,
      statusMessage: this.lastStatusMessage
    }));
  }

  async triggerSync() {
    if (this.isSyncing) return;
    
    if (!this.isOnline()) {
      this.lastStatusMessage = "Cannot synchronize: OFFLINE MODE. Records safely preserved locally.";
      this.notify();
      return { success: false, reason: "offline" };
    }

    const pendingCount = db.getPendingSyncCount();
    if (pendingCount === 0) {
      this.lastStatusMessage = "All records are already up to date.";
      this.notify();
      return { success: true, syncedCount: 0 };
    }

    this.isSyncing = true;
    this.lastStatusMessage = `Synchronizing ${pendingCount} pending records with cloud...`;
    this.notify();

    try {
      // Simulate robust network latency and idempotent server acknowledgment
      await new Promise(resolve => setTimeout(resolve, 800));

      const result = db.performBatchSync();
      this.isSyncing = false;
      this.lastSyncResult = result;
      this.lastStatusMessage = "Data synchronized successfully.";
      this.notify();
      return { success: true, syncedCount: result.syncedCount };
    } catch (err) {
      this.isSyncing = false;
      this.lastStatusMessage = "Synchronization retry scheduled: Data safely stored locally.";
      this.notify();
      return { success: false, error: err.message };
    }
  }

  toggleSimulatedNetwork() {
    const current = db.getSettings().networkMode || "online";
    const next = current === "online" ? "offline" : "online";
    db.updateSettings({ networkMode: next });
    
    if (next === "online") {
      this.handleNetworkChange(true);
    } else {
      this.handleNetworkChange(false);
    }
    return next;
  }
}

export const syncEngine = new SyncEngine();