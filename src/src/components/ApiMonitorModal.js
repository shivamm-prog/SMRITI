// SMRITI - Developer & Admin API Monitoring Dashboard
// Multi-Layer Shield Inspector: Daily Quota Bar, Cooldown Timer, Cache Hit Counter & Audit Log

import { db } from '../db/smritiStorage.js';

export class ApiMonitorModal {
  constructor(options = {}) {
    this.onClose = options.onClose || (() => {});
    this.render();
  }

  render() {
    const usage = db.getApiUsage();
    const settings = db.getSettings();
    const maxQuota = usage.maxDailyQuota || 5;
    const usedToday = usage.requestsToday || 0;
    const percentage = Math.min(100, Math.round((usedToday / maxQuota) * 100));

    // Calculate text progress bar
    const filledBlocks = Math.round(percentage / 10);
    const emptyBlocks = 10 - filledBlocks;
    const textProgressBar = "█".repeat(filledBlocks) + "░".repeat(emptyBlocks);

    // Cooldown elapsed
    let cooldownText = "None (Ready)";
    if (usage.lastRequestTimestamp) {
      const elapsed = Date.now() - new Date(usage.lastRequestTimestamp).getTime();
      const cooldownMs = (usage.cooldownMinutes || 15) * 60 * 1000;
      if (elapsed < cooldownMs) {
        const remainingMin = Math.ceil((cooldownMs - elapsed) / 60000);
        cooldownText = `${remainingMin} mins remaining (Active Cooldown)`;
      }
    }

    const modalEl = document.createElement("div");
    modalEl.id = "api-monitor-overlay";
    modalEl.className = "fixed inset-0 z-50 bg-stone-900/80 backdrop-blur-sm flex items-center justify-center p-4 select-none animate-fade-in";

    modalEl.innerHTML = `
      <div class="bg-stone-900 text-stone-100 rounded-3xl p-6 md:p-8 max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-stone-700">
        <!-- Header -->
        <div class="flex items-center justify-between border-b border-stone-800 pb-4 mb-6">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-2xl bg-amber-500/20 text-amber-400 border border-amber-500/40 flex items-center justify-center text-xl">
              ⚡
            </div>
            <div>
              <h2 class="text-xl font-black text-white">API Cost & Quota Protection Dashboard</h2>
              <p class="text-xs text-stone-400 font-mono">Zero-API Core Gameplay • Controlled AI Enhancement Shield</p>
            </div>
          </div>

          <button id="btn-close-monitor" class="w-10 h-10 rounded-xl bg-stone-800 hover:bg-stone-700 text-stone-300 flex items-center justify-center text-lg font-bold transition">
            ✕
          </button>
        </div>

        <!-- Live Visual Quota Gauge -->
        <div class="bg-stone-800/80 rounded-2xl p-5 border border-stone-700 mb-6">
          <div class="flex items-center justify-between mb-2">
            <span class="text-xs font-bold uppercase tracking-wider text-amber-400 font-mono">Daily AI Request Quota:</span>
            <span class="text-sm font-black font-mono text-white">${usedToday} / ${maxQuota} (${percentage}%)</span>
          </div>

          <!-- Visual Bar -->
          <div class="w-full bg-stone-950 rounded-full h-4 overflow-hidden border border-stone-700 p-0.5 mb-2">
            <div class="bg-gradient-to-r from-amber-500 to-emerald-500 h-full rounded-full transition-all duration-500" style="width: ${percentage}%"></div>
          </div>

          <!-- Console-Style Text Bar -->
          <div class="font-mono text-xs text-stone-400 flex items-center justify-between">
            <span>API Usage: <strong class="text-amber-300 font-bold">[${textProgressBar}] ${percentage}%</strong></span>
            <span>${maxQuota - usedToday} calls remaining today</span>
          </div>
        </div>

        <!-- Key Security Metrics -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6 font-mono">
          <div class="bg-stone-950 p-3.5 rounded-xl border border-stone-800">
            <span class="text-[10px] text-stone-500 uppercase font-bold block">Requests Today</span>
            <span class="text-2xl font-black text-white mt-1 block">${usedToday}</span>
          </div>

          <div class="bg-stone-950 p-3.5 rounded-xl border border-stone-800">
            <span class="text-[10px] text-stone-500 uppercase font-bold block">Weekly Total</span>
            <span class="text-2xl font-black text-stone-300 mt-1 block">${usage.requestsThisWeek || usedToday}</span>
          </div>

          <div class="bg-stone-950 p-3.5 rounded-xl border border-stone-800">
            <span class="text-[10px] text-stone-500 uppercase font-bold block">Cache Hits (Free)</span>
            <span class="text-2xl font-black text-emerald-400 mt-1 block">${usage.cachedHits || 0}</span>
          </div>

          <div class="bg-stone-950 p-3.5 rounded-xl border border-stone-800">
            <span class="text-[10px] text-stone-500 uppercase font-bold block">Failed Retries</span>
            <span class="text-2xl font-black text-stone-400 mt-1 block">${usage.failedRequests || 0}</span>
          </div>
        </div>

        <!-- Cooldown & Rule Hierarchy -->
        <div class="bg-stone-800/50 rounded-2xl p-4 border border-stone-700 mb-6 text-xs space-y-2">
          <div class="flex items-center justify-between font-mono">
            <span class="text-stone-400">Current API Cooldown State:</span>
            <span class="font-bold text-amber-300">${cooldownText}</span>
          </div>
          <div class="flex items-center justify-between font-mono">
            <span class="text-stone-400">Last Outbound Request:</span>
            <span class="text-stone-300">${usage.lastRequestTimestamp ? new Date(usage.lastRequestTimestamp).toLocaleTimeString() : 'None today'}</span>
          </div>
          <div class="flex items-center justify-between font-mono">
            <span class="text-stone-400">Local Rule-Engine Fallback:</span>
            <span class="text-emerald-400 font-bold">Always Active (Zero Latency)</span>
          </div>
        </div>

        <!-- Audit Trail Table -->
        <div class="bg-stone-950 rounded-2xl border border-stone-800 p-4 mb-6">
          <h4 class="text-xs font-black uppercase tracking-wider text-stone-400 mb-3 font-mono">Security & Request Audit Trail:</h4>
          <div class="space-y-2 max-h-[160px] overflow-y-auto font-mono text-[11px]">
            ${(usage.logs || []).map(l => `
              <div class="p-2 bg-stone-900 rounded-lg border border-stone-800 flex items-center justify-between">
                <div>
                  <span class="text-amber-400 font-bold">${l.type}</span>
                  <span class="text-stone-500 ml-2">${new Date(l.timestamp).toLocaleTimeString()}</span>
                  <p class="text-stone-400 mt-0.5">${l.details}</p>
                </div>
                <span class="px-2 py-0.5 rounded text-[10px] font-bold ${l.status.includes('SUCCESS') ? 'bg-emerald-950 text-emerald-300 border border-emerald-800' : 'bg-rose-950 text-rose-300'}">
                  ${l.status}
                </span>
              </div>
            `).join("")}
          </div>
        </div>

        <!-- Developer Configuration Actions -->
        <div class="flex flex-wrap items-center justify-between gap-3 pt-4 border-t border-stone-800">
          <button id="btn-reset-demo-db" class="px-4 py-2 bg-rose-900 hover:bg-rose-800 text-rose-200 border border-rose-700 rounded-xl text-xs font-bold transition">
            ⚠️ Reset All Demo Data
          </button>
          
          <button id="btn-done-monitor" class="px-6 py-2.5 bg-amber-600 hover:bg-amber-500 text-white rounded-xl text-xs font-bold shadow transition">
            Close Monitor
          </button>
        </div>
      </div>
    `;

    document.body.appendChild(modalEl);

    modalEl.querySelector("#btn-close-monitor")?.addEventListener("click", () => {
      modalEl.remove();
      this.onClose();
    });

    modalEl.querySelector("#btn-done-monitor")?.addEventListener("click", () => {
      modalEl.remove();
      this.onClose();
    });

    modalEl.querySelector("#btn-reset-demo-db")?.addEventListener("click", () => {
      if (confirm("Reset local database to initial demo state?")) {
        db.resetAll();
        modalEl.remove();
        location.reload();
      }
    });
  }
}