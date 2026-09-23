// SMRITI - Home Portal / Role Selector & Offline Coordinator
import { UI_STRINGS } from '../data/i18n.js';
import { db } from '../db/smritiStorage.js';
import { syncEngine } from '../services/syncEngine.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';

export class HomePortal {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.onSelectPortal = options.onSelectPortal || (() => {});
    this.onLanguageChange = options.onLanguageChange || (() => {});
    this.onOpenApiMonitor = options.onOpenApiMonitor || (() => {});

    this.profile = db.getPatientProfile();
    this.metrics = PersonalizationEngine.calculateMetrics(this.profile.id);
    this.progress = PersonalizationEngine.getTodayProgress(this.profile.id);
    this.pendingSyncCount = db.getPendingSyncCount();
    this.isOnline = syncEngine.isOnline();

    this.render();
  }

  render() {
    const t = UI_STRINGS[this.lang] || UI_STRINGS.en;

    this.container.innerHTML = `
      <div class="flex flex-col flex-1 p-4 sm:p-6 bg-stone-50 max-w-xl mx-auto w-full animate-fade-in">
        
        <!-- Header & Language Switcher -->
        <header class="flex items-center justify-between pb-4 border-b border-stone-200">
          <div>
            <div class="flex items-center gap-2">
              <span class="text-3xl">🪔</span>
              <h1 class="text-2xl sm:text-3xl font-black text-amber-950 tracking-tight">SMRITI</h1>
            </div>
            <p class="text-xs font-bold text-amber-900 mt-0.5">স্মৃতি / स्मृति — Cognitive Support</p>
          </div>

          <!-- Language Selector -->
          <div class="flex items-center gap-1 bg-stone-200 p-1 rounded-2xl shadow-inner">
            <button data-lang="as" class="lang-btn px-2.5 py-1.5 rounded-xl font-bold text-xs sm:text-sm transition ${this.lang === "as" ? "bg-amber-600 text-white shadow" : "text-stone-700 hover:bg-stone-300"}">
              অসমীয়া
            </button>
            <button data-lang="hi" class="lang-btn px-2.5 py-1.5 rounded-xl font-bold text-xs sm:text-sm transition ${this.lang === "hi" ? "bg-amber-600 text-white shadow" : "text-stone-700 hover:bg-stone-300"}">
              हिन्दी
            </button>
            <button data-lang="en" class="lang-btn px-2.5 py-1.5 rounded-xl font-bold text-xs sm:text-sm transition ${this.lang === "en" ? "bg-amber-600 text-white shadow" : "text-stone-700 hover:bg-stone-300"}">
              EN
            </button>
          </div>
        </header>

        <!-- Connectivity & Offline Sync Status Bar -->
        <div class="mt-4 p-3 rounded-2xl ${this.isOnline ? "bg-emerald-50 border-2 border-emerald-300 text-emerald-950" : "bg-amber-100 border-2 border-amber-400 text-amber-950"} shadow-sm flex flex-col sm:flex-row items-center justify-between gap-2.5">
          <div class="flex items-center gap-2">
            <span class="w-3 h-3 rounded-full ${this.isOnline ? "bg-emerald-500 animate-pulse" : "bg-amber-600"}"></span>
            <div>
              <span class="font-black text-xs sm:text-sm">
                ${this.isOnline ? "ONLINE MODE" : "OFFLINE MODE"}
              </span>
              <span class="text-xs font-bold text-stone-600 block sm:inline sm:ml-1">
                ${this.pendingSyncCount > 0 ? `(${this.pendingSyncCount} ${t.syncPending})` : `(All data saved locally & up to date)`}
              </span>
            </div>
          </div>

          <div class="flex items-center gap-2 w-full sm:w-auto">
            <button id="btn-toggle-network" class="flex-1 sm:flex-initial px-3 py-1.5 bg-white hover:bg-stone-100 border border-stone-300 text-stone-800 rounded-xl text-xs font-black shadow-sm transition">
              ${this.isOnline ? "Simulate Offline 📡" : "Simulate Online 🌐"}
            </button>
            ${this.pendingSyncCount > 0 ? `
              <button id="btn-sync-now" class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-black shadow transition flex items-center gap-1">
                <span>🔄</span>
                <span>${t.syncNow}</span>
              </button>
            ` : ""}
          </div>
        </div>

        <!-- Patient Quick Summary Card -->
        <div class="mt-4 p-4 rounded-3xl bg-gradient-to-br from-amber-500 to-amber-700 text-white shadow-xl">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <span class="text-4xl">${this.profile.avatar}</span>
              <div>
                <span class="text-xs uppercase font-bold tracking-wider text-amber-200">Active Senior Profile</span>
                <h2 class="text-xl sm:text-2xl font-black">${this.profile.name}</h2>
                <p class="text-xs font-medium text-amber-100">${this.profile.age} yrs • ${this.profile.location}</p>
              </div>
            </div>
            <div class="text-right">
              <span class="text-xs font-bold px-2 py-1 bg-white/20 rounded-lg text-white">
                ${this.metrics.adaptiveLevel.levelName}
              </span>
            </div>
          </div>

          <!-- Progress Bar -->
          <div class="mt-4 bg-black/20 p-3 rounded-2xl">
            <div class="flex justify-between text-xs font-bold mb-1">
              <span>${t.todaysActivities}</span>
              <span>${this.progress.completedToday} / ${this.progress.targetDaily}</span>
            </div>
            <div class="w-full bg-white/30 h-3 rounded-full overflow-hidden">
              <div class="bg-white h-full transition-all duration-500 rounded-full" style="width: ${this.progress.percentage}%"></div>
            </div>
          </div>
        </div>

        <!-- Three Role-Based Portals -->
        <div class="mt-5 space-y-3.5 flex-1">
          <div class="text-xs font-bold uppercase tracking-wider text-stone-500 px-1">
            ${t.portalSelect}
          </div>

          <!-- 1. Patient Portal -->
          <button data-portal="patient" class="portal-btn w-full p-5 bg-white hover:bg-amber-50/70 border-4 border-amber-500 rounded-3xl shadow-lg transition-all transform active:scale-98 flex items-center justify-between text-left group">
            <div class="flex items-center gap-4">
              <div class="w-14 h-14 rounded-2xl bg-amber-100 flex items-center justify-center text-3xl group-hover:scale-110 transition">
                👵
              </div>
              <div>
                <h3 class="text-xl sm:text-2xl font-black text-stone-900 group-hover:text-amber-800">
                  ${t.patientPortal}
                </h3>
                <p class="text-xs sm:text-sm font-bold text-stone-500 mt-0.5">
                  ${this.lang === "as" ? "আজিৰ খেলবোৰ আৰম্ভ কৰক (সহজ আৰু আনন্দময়)" : this.lang === "hi" ? "आज की गतिविधियाँ शुरू करें (सरल व सुखद)" : "Start today's gentle cognitive activities"}
                </p>
              </div>
            </div>
            <span class="text-2xl text-amber-600 font-black">➔</span>
          </button>

          <!-- 2. Caregiver Portal -->
          <button data-portal="caregiver" class="portal-btn w-full p-4.5 bg-white hover:bg-emerald-50/70 border-2 border-emerald-400 rounded-3xl shadow-md transition-all transform active:scale-98 flex items-center justify-between text-left group">
            <div class="flex items-center gap-3.5">
              <div class="w-12 h-12 rounded-2xl bg-emerald-100 flex items-center justify-center text-2xl group-hover:scale-110 transition">
                👨‍💼
              </div>
              <div>
                <h3 class="text-lg sm:text-xl font-black text-stone-900 group-hover:text-emerald-800">
                  ${t.caregiverPortal}
                </h3>
                <p class="text-xs font-bold text-stone-500">
                  ${this.lang === "as" ? "কাৰ্যক্ষমতা, দৈনিক অৱস্থা আৰু স্মৃতিৰ ছবি পৰিচালনা" : this.lang === "hi" ? "गतिविधि रुझान, अवलोकन व संस्मरण प्रबंधन" : "Activity trends, daily observations & memories"}
                </p>
              </div>
            </div>
            <span class="text-xl text-emerald-600 font-black">➔</span>
          </button>

          <!-- 3. Doctor Portal -->
          <button data-portal="doctor" class="portal-btn w-full p-4.5 bg-white hover:bg-blue-50/70 border-2 border-blue-400 rounded-3xl shadow-md transition-all transform active:scale-98 flex items-center justify-between text-left group">
            <div class="flex items-center gap-3.5">
              <div class="w-12 h-12 rounded-2xl bg-blue-100 flex items-center justify-center text-2xl group-hover:scale-110 transition">
                👨‍⚕️
              </div>
              <div>
                <h3 class="text-lg sm:text-xl font-black text-stone-900 group-hover:text-blue-800">
                  ${t.doctorPortal}
                </h3>
                <p class="text-xs font-bold text-stone-500">
                  ${this.lang === "as" ? "দীৰ্ঘম্যাদী প্ৰতিবেদন, গ্ৰাফ আৰু PDF ডাউনলোড" : this.lang === "hi" ? "दीर्घकालिक रिपोर्ट, ग्राफ व PDF डाउनलोड" : "Longitudinal report, domain trends & PDF export"}
                </p>
              </div>
            </div>
            <span class="text-xl text-blue-600 font-black">➔</span>
          </button>
        </div>

        <!-- Footer Info & Non-Diagnostic Disclaimer -->
        <footer class="mt-6 pt-4 border-t border-stone-200 text-center">
          <div class="flex flex-wrap items-center justify-center gap-3 mb-2">
            <button id="btn-api-monitor" class="text-xs font-bold text-stone-600 hover:text-stone-900 underline flex items-center gap-1">
              <span>🛡️</span>
              <span>Zero-API & Quota Monitor</span>
            </button>
            <span class="text-stone-300">•</span>
            <button id="btn-reset-demo" class="text-xs font-bold text-stone-500 hover:text-red-700 underline">
              Reset Demo Data
            </button>
          </div>
          <p class="text-[11px] text-stone-500 leading-tight font-medium max-w-md mx-auto">
            ${t.medicalDisclaimerShort}
          </p>
        </footer>
      </div>
    `;

    this.attachEvents();
  }

  attachEvents() {
    const langBtns = this.container.querySelectorAll(".lang-btn");
    langBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const selectedLang = btn.dataset.lang;
        this.onLanguageChange(selectedLang);
      });
    });

    const portalBtns = this.container.querySelectorAll(".portal-btn");
    portalBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const portal = btn.dataset.portal;
        this.onSelectPortal(portal);
      });
    });

    const toggleNetBtn = this.container.querySelector("#btn-toggle-network");
    if (toggleNetBtn) {
      toggleNetBtn.addEventListener("click", () => {
        syncEngine.toggleSimulatedNetwork();
        this.isOnline = syncEngine.isOnline();
        this.render();
      });
    }

    const syncNowBtn = this.container.querySelector("#btn-sync-now");
    if (syncNowBtn) {
      syncNowBtn.addEventListener("click", async () => {
        syncNowBtn.textContent = "Syncing...";
        await syncEngine.triggerSync();
        this.pendingSyncCount = db.getPendingSyncCount();
        this.render();
      });
    }

    const apiMonitorBtn = this.container.querySelector("#btn-api-monitor");
    if (apiMonitorBtn) {
      apiMonitorBtn.addEventListener("click", () => this.onOpenApiMonitor());
    }

    const resetBtn = this.container.querySelector("#btn-reset-demo");
    if (resetBtn) {
      resetBtn.addEventListener("click", () => {
        if (confirm("Reset all test data back to default demo state?")) {
          db.resetAll();
          window.location.reload();
        }
      });
    }
  }
}