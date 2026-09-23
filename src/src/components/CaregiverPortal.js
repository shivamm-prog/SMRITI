// SMRITI - Caregiver Portal & Observation System
import { UI_STRINGS } from '../data/i18n.js';
import { db } from '../db/smritiStorage.js';
import { syncEngine } from '../services/syncEngine.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';
import { ICONS } from '../data/icons.js';

export class CaregiverPortal {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.onBackHome = options.onBackHome || (() => {});

    this.profile = db.getPatientProfile();
    this.activeTab = "overview"; // 'overview' | 'observations' | 'memories' | 'activities'
    this.pendingSyncCount = db.getPendingSyncCount();

    this.render();
  }

  setLanguage(lang) {
    this.lang = lang;
    db.updateSettings({ activeLanguage: lang });
    this.render();
  }

  handleSaveObservation(formData) {
    db.saveObservation(formData);
    this.pendingSyncCount = db.getPendingSyncCount();
    alert("Daily Observation safely saved locally in offline storage.");
    this.activeTab = "observations";
    this.render();
  }

  handleAddMemory(memoryData) {
    db.addMemory(memoryData);
    this.pendingSyncCount = db.getPendingSyncCount();
    alert("New Personal Memory added to album and saved locally.");
    this.activeTab = "memories";
    this.render();
  }

  handleDeleteMemory(memoryId) {
    if (confirm("Remove this memory from patient album?")) {
      db.deleteMemory(memoryId);
      this.render();
    }
  }

  render() {
    const t = UI_STRINGS[this.lang] || UI_STRINGS.en;
    const metrics = PersonalizationEngine.calculateMetrics(this.profile.id);
    const domainTrends = PersonalizationEngine.calculateDomainTrends(this.profile.id);
    const activities = db.getActivityResults(this.profile.id);
    const observations = db.getObservations(this.profile.id);
    const memories = db.getMemories(this.profile.id);

    this.container.innerHTML = `
      <div class="flex flex-col flex-1 p-4 sm:p-6 bg-stone-50 max-w-2xl mx-auto w-full animate-fade-in">
        
        <!-- Header & Nav -->
        <header class="flex items-center justify-between pb-3 border-b border-stone-200">
          <button id="btn-back-home" class="px-3.5 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-sm flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${t.backToHome}</span>
          </button>

          <!-- Language Selector -->
          <div class="flex items-center gap-1 bg-stone-200 p-1 rounded-2xl">
            <button data-lang="as" class="lang-btn px-2.5 py-1 rounded-xl font-bold text-xs ${this.lang === "as" ? "bg-amber-600 text-white shadow" : "text-stone-700"}">
              অসমীয়া
            </button>
            <button data-lang="hi" class="lang-btn px-2.5 py-1 rounded-xl font-bold text-xs ${this.lang === "hi" ? "bg-amber-600 text-white shadow" : "text-stone-700"}">
              हिन्दी
            </button>
            <button data-lang="en" class="lang-btn px-2.5 py-1 rounded-xl font-bold text-xs ${this.lang === "en" ? "bg-amber-600 text-white shadow" : "text-stone-700"}">
              EN
            </button>
          </div>
        </header>

        <!-- Caregiver Title & Patient Profile Summary -->
        <div class="mt-4 p-5 rounded-3xl bg-emerald-800 text-white shadow-xl">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div class="flex items-center gap-3.5">
              <span class="text-4xl">${this.profile.avatar}</span>
              <div>
                <span class="text-xs uppercase font-black tracking-wider text-emerald-200">
                  ${t.caregiverPortal}
                </span>
                <h1 class="text-2xl font-black">${this.profile.name} (${this.profile.age} yrs)</h1>
                <p class="text-xs font-medium text-emerald-100 mt-0.5">
                  ${this.profile.location} • Primary Caregiver: Rahul Das
                </p>
              </div>
            </div>
            <div class="text-left sm:text-right">
              <span class="text-xs font-bold px-3 py-1 bg-emerald-700 rounded-full border border-emerald-500 inline-block">
                ${metrics.adaptiveLevel.levelName}
              </span>
            </div>
          </div>
        </div>

        <!-- Navigation Tabs -->
        <div class="mt-4 flex gap-1.5 bg-stone-200 p-1 rounded-2xl">
          <button data-tab="overview" class="tab-btn flex-1 py-2 rounded-xl text-xs sm:text-sm font-bold transition ${this.activeTab === "overview" ? "bg-white text-emerald-900 shadow" : "text-stone-600 hover:text-stone-900"}">
            📊 Trends
          </button>
          <button data-tab="observations" class="tab-btn flex-1 py-2 rounded-xl text-xs sm:text-sm font-bold transition ${this.activeTab === "observations" ? "bg-white text-emerald-900 shadow" : "text-stone-600 hover:text-stone-900"}">
            📝 Observations (${observations.length})
          </button>
          <button data-tab="memories" class="tab-btn flex-1 py-2 rounded-xl text-xs sm:text-sm font-bold transition ${this.activeTab === "memories" ? "bg-white text-emerald-900 shadow" : "text-stone-600 hover:text-stone-900"}">
            📸 Album (${memories.length})
          </button>
          <button data-tab="activities" class="tab-btn flex-1 py-2 rounded-xl text-xs sm:text-sm font-bold transition ${this.activeTab === "activities" ? "bg-white text-emerald-900 shadow" : "text-stone-600 hover:text-stone-900"}">
            📋 Sessions (${activities.length})
          </button>
        </div>

        <!-- Tab 1: Overview & Cognitive Domain Trends -->
        ${this.activeTab === "overview" ? `
          <div class="mt-4 space-y-4 animate-fade-in">
            <!-- Key Stats Grid -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
              <div class="bg-white p-3.5 rounded-2xl border border-stone-200 shadow-sm">
                <span class="text-xs font-bold text-stone-500">Activities Done</span>
                <p class="text-2xl font-black text-emerald-800 mt-1">${metrics.totalActivities}</p>
                <span class="text-[11px] text-stone-400">Total sessions</span>
              </div>
              <div class="bg-white p-3.5 rounded-2xl border border-stone-200 shadow-sm">
                <span class="text-xs font-bold text-stone-500">Avg Accuracy</span>
                <p class="text-2xl font-black text-emerald-800 mt-1">${metrics.averageAccuracy}%</p>
                <span class="text-[11px] text-emerald-600 font-bold">Stable trend</span>
              </div>
              <div class="bg-white p-3.5 rounded-2xl border border-stone-200 shadow-sm">
                <span class="text-xs font-bold text-stone-500">Avg Response</span>
                <p class="text-2xl font-black text-stone-800 mt-1">${metrics.averageResponseTimeSec}s</p>
                <span class="text-[11px] text-stone-400">Calm pacing</span>
              </div>
              <div class="bg-white p-3.5 rounded-2xl border border-stone-200 shadow-sm">
                <span class="text-xs font-bold text-stone-500">Sync Status</span>
                <p class="text-lg font-black text-amber-700 mt-1">${db.getPendingSyncCount()} Pending</p>
                <span class="text-[11px] text-stone-400">Offline safe</span>
              </div>
            </div>

            <!-- Cognitive Domain Trends (Non-diagnostic) -->
            <div class="bg-white p-5 rounded-3xl border border-stone-200 shadow-sm">
              <div class="flex items-center justify-between mb-4">
                <div>
                  <h3 class="text-lg font-black text-stone-900">Cognitive Activity Trends</h3>
                  <p class="text-xs font-medium text-stone-500">Domains stimulated across SMRITI sessions (Non-diagnostic tracking)</p>
                </div>
                <span class="text-xs font-bold px-2.5 py-1 bg-stone-100 text-stone-700 rounded-lg">
                  6 Domains
                </span>
              </div>

              <div class="space-y-3.5">
                ${Object.keys(domainTrends).map(key => {
                  const d = domainTrends[key];
                  return `
                    <div>
                      <div class="flex justify-between text-xs font-bold mb-1">
                        <span class="text-stone-800">${d.name} (${d.sessions} sessions)</span>
                        <span class="text-emerald-800">${d.avgAccuracy}%</span>
                      </div>
                      <div class="w-full bg-stone-100 h-3.5 rounded-full overflow-hidden border border-stone-200">
                        <div class="bg-emerald-600 h-full rounded-full transition-all duration-500" style="width: ${d.avgAccuracy}%"></div>
                      </div>
                    </div>
                  `;
                }).join("")}
              </div>
            </div>

            <!-- Caregiver Action Shortcut -->
            <div class="p-4 bg-emerald-50 border-2 border-emerald-300 rounded-3xl flex items-center justify-between">
              <div>
                <h4 class="text-sm font-black text-emerald-950">Record Today's Observation</h4>
                <p class="text-xs text-emerald-800 font-medium">Log mood, sleep quality, and daily notes</p>
              </div>
              <button id="btn-goto-obs-form" class="px-4 py-2 bg-emerald-700 hover:bg-emerald-800 text-white rounded-xl text-xs font-black shadow transition">
                + Log Now
              </button>
            </div>
          </div>
        ` : ""}

        <!-- Tab 2: Caregiver Observation System -->
        ${this.activeTab === "observations" ? `
          <div class="mt-4 space-y-4 animate-fade-in">
            
            <!-- Observation Logging Form -->
            <div class="bg-white p-5 rounded-3xl border border-stone-200 shadow-sm">
              <h3 class="text-lg font-black text-stone-900 mb-1">Log Daily Observation</h3>
              <p class="text-xs font-medium text-stone-500 mb-4">Record senior's wellbeing, sleep, mood, and memory signs</p>

              <form id="form-observation" class="space-y-4">
                <!-- Mood -->
                <div>
                  <label class="block text-xs font-bold text-stone-700 uppercase mb-1.5">${t.moodLabel}</label>
                  <div class="grid grid-cols-4 gap-2">
                    <label class="p-2.5 border-2 border-stone-200 rounded-xl flex flex-col items-center text-xs font-bold cursor-pointer hover:border-emerald-500 has-[:checked]:border-emerald-600 has-[:checked]:bg-emerald-50">
                      <input type="radio" name="mood" value="Happy" checked class="hidden">
                      <span class="text-xl mb-0.5">😊</span>
                      <span>${t.moodHappy}</span>
                    </label>
                    <label class="p-2.5 border-2 border-stone-200 rounded-xl flex flex-col items-center text-xs font-bold cursor-pointer hover:border-emerald-500 has-[:checked]:border-emerald-600 has-[:checked]:bg-emerald-50">
                      <input type="radio" name="mood" value="Neutral" class="hidden">
                      <span class="text-xl mb-0.5">😐</span>
                      <span>${t.moodNeutral}</span>
                    </label>
                    <label class="p-2.5 border-2 border-stone-200 rounded-xl flex flex-col items-center text-xs font-bold cursor-pointer hover:border-emerald-500 has-[:checked]:border-emerald-600 has-[:checked]:bg-emerald-50">
                      <input type="radio" name="mood" value="Sad" class="hidden">
                      <span class="text-xl mb-0.5">😔</span>
                      <span>${t.moodSad}</span>
                    </label>
                    <label class="p-2.5 border-2 border-stone-200 rounded-xl flex flex-col items-center text-xs font-bold cursor-pointer hover:border-emerald-500 has-[:checked]:border-emerald-600 has-[:checked]:bg-emerald-50">
                      <input type="radio" name="mood" value="Irritated" class="hidden">
                      <span class="text-xl mb-0.5">😠</span>
                      <span>${t.moodIrritated}</span>
                    </label>
                  </div>
                </div>

                <!-- Sleep & Appetite -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label class="block text-xs font-bold text-stone-700 uppercase mb-1">${t.sleepLabel}</label>
                    <select name="sleep" class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-bold text-stone-800">
                      <option value="Good">${t.sleepGood}</option>
                      <option value="Average">${t.sleepAvg}</option>
                      <option value="Poor">${t.sleepPoor}</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-stone-700 uppercase mb-1">${t.appetiteLabel}</label>
                    <select name="appetite" class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-bold text-stone-800">
                      <option value="Good">${t.appetiteGood}</option>
                      <option value="Average">${t.appetiteAvg}</option>
                      <option value="Poor">${t.appetitePoor}</option>
                    </select>
                  </div>
                </div>

                <!-- Daily Physical Activity & Memory Concerns -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label class="block text-xs font-bold text-stone-700 uppercase mb-1">${t.dailyActivityLabel}</label>
                    <select name="dailyActivity" class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-bold text-stone-800">
                      <option value="Active">${t.actActive}</option>
                      <option value="Moderate">${t.actModerate}</option>
                      <option value="Low">${t.actLow}</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-stone-700 uppercase mb-1">${t.memConcernsLabel}</label>
                    <select name="memoryConcerns" class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-bold text-stone-800">
                      <option value="None">${t.memNone}</option>
                      <option value="Mild">${t.memMild}</option>
                      <option value="Frequent">${t.memFrequent}</option>
                    </select>
                  </div>
                </div>

                <!-- Free Text Notes -->
                <div>
                  <label class="block text-xs font-bold text-stone-700 uppercase mb-1">${t.notesLabel}</label>
                  <textarea name="notes" rows="2" placeholder="e.g. Maa enjoyed morning tea and listened happily to Bihu songs today..." class="w-full p-3 bg-stone-50 border border-stone-300 rounded-xl text-sm font-medium text-stone-900"></textarea>
                </div>

                <button type="submit" class="w-full py-3.5 bg-emerald-700 hover:bg-emerald-800 text-white font-black rounded-xl shadow-md transition">
                  ${t.saveObservation}
                </button>
              </form>
            </div>

            <!-- Historical Observations List -->
            <div class="space-y-3">
              <h4 class="text-xs font-black uppercase tracking-wider text-stone-500 px-1">Logged Observations History</h4>
              ${observations.map(obs => `
                <div class="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm">
                  <div class="flex items-center justify-between border-b border-stone-100 pb-2 mb-2">
                    <span class="text-xs font-black text-emerald-900">${obs.date}</span>
                    <div class="flex items-center gap-2">
                      <span class="text-xs px-2 py-0.5 bg-emerald-100 text-emerald-800 rounded-md font-bold">
                        Mood: ${obs.mood}
                      </span>
                      <span class="text-xs px-2 py-0.5 ${obs.syncStatus === "SYNCED" ? "bg-emerald-50 text-emerald-700" : "bg-amber-100 text-amber-800"} rounded-md font-bold">
                        ${obs.syncStatus === "SYNCED" ? "✓ Synced" : "⏳ Pending"}
                      </span>
                    </div>
                  </div>
                  <div class="grid grid-cols-3 gap-2 text-xs font-medium text-stone-600 mb-2">
                    <span>Sleep: <strong>${obs.sleep}</strong></span>
                    <span>Appetite: <strong>${obs.appetite}</strong></span>
                    <span>Activity: <strong>${obs.dailyActivity}</strong></span>
                  </div>
                  <p class="text-xs text-stone-800 font-medium italic">
                    "${obs.notes || "No extra notes"}"
                  </p>
                </div>
              `).join("")}
            </div>
          </div>
        ` : ""}

        <!-- Tab 3: Personal Memory Album Manager -->
        ${this.activeTab === "memories" ? `
          <div class="mt-4 space-y-4 animate-fade-in">
            <!-- Add Memory Card -->
            <div class="bg-white p-5 rounded-3xl border border-stone-200 shadow-sm">
              <h3 class="text-lg font-black text-stone-900 mb-1">Add Family Photo / Memory</h3>
              <p class="text-xs font-medium text-stone-500 mb-4">Upload family pictures, places, festivals, or voice memories</p>

              <form id="form-add-memory" class="space-y-3">
                <div>
                  <label class="block text-xs font-bold text-stone-700 uppercase mb-1">Memory Title</label>
                  <input type="text" name="titleEn" placeholder="e.g. Priyam's Dance at Bihu Festival" required class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-bold text-stone-900">
                </div>

                <div class="grid grid-cols-2 gap-3">
                  <div>
                    <label class="block text-xs font-bold text-stone-700 uppercase mb-1">Category</label>
                    <select name="category" class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-bold text-stone-800">
                      <option value="family">Family & Children</option>
                      <option value="festival">Festival & Bihu</option>
                      <option value="places">Sacred Places / Nature</option>
                      <option value="food">Tea & Food</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-xs font-bold text-stone-700 uppercase mb-1">Associated Year / Era</label>
                    <input type="text" name="yearApprox" placeholder="e.g. 2019" class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-bold text-stone-900">
                  </div>
                </div>

                <div>
                  <label class="block text-xs font-bold text-stone-700 uppercase mb-1">Memory Story / Caption</label>
                  <textarea name="captionEn" rows="2" placeholder="e.g. You gifted Priyam her first red Gamosa and enjoyed warm pitha together." required class="w-full p-2.5 bg-stone-50 border border-stone-300 rounded-xl text-sm font-medium text-stone-900"></textarea>
                </div>

                <button type="submit" class="w-full py-3 bg-amber-600 hover:bg-amber-700 text-white font-black rounded-xl shadow transition">
                  + Add to Senior's Memory Album
                </button>
              </form>
            </div>

            <!-- Existing Memories List -->
            <div class="space-y-3">
              <h4 class="text-xs font-black uppercase tracking-wider text-stone-500 px-1">Preserved Memories in Album (${memories.length})</h4>
              ${memories.map(m => {
                const titleText = m.title[this.lang] || m.title.en;
                const captionText = m.caption[this.lang] || m.caption.en;
                return `
                  <div class="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm flex items-start justify-between gap-3">
                    <div class="w-14 h-14 bg-amber-100 rounded-xl p-2 flex items-center justify-center flex-shrink-0">
                      ${ICONS[m.iconKey] || `<span class="text-3xl">📸</span>`}
                    </div>
                    <div class="flex-1">
                      <div class="flex items-center justify-between">
                        <h5 class="text-base font-black text-stone-900">${titleText}</h5>
                        <span class="text-[11px] font-bold text-stone-400">${m.yearApprox}</span>
                      </div>
                      <p class="text-xs font-medium text-stone-600 mt-1 leading-snug">
                        ${captionText}
                      </p>
                    </div>
                    <button data-delete-memory="${m.id}" class="btn-delete-mem text-stone-300 hover:text-red-600 p-1 text-base font-bold" title="Delete">
                      ✕
                    </button>
                  </div>
                `;
              }).join("")}
            </div>
          </div>
        ` : ""}

        <!-- Tab 4: Session History -->
        ${this.activeTab === "activities" ? `
          <div class="mt-4 space-y-3 animate-fade-in">
            <h4 class="text-xs font-black uppercase tracking-wider text-stone-500 px-1">Recent Activity Sessions</h4>
            ${activities.map(act => `
              <div class="bg-white p-4 rounded-2xl border border-stone-200 shadow-sm flex items-center justify-between">
                <div>
                  <h5 class="text-sm font-black text-stone-900">${act.activityTitle}</h5>
                  <p class="text-xs font-medium text-stone-500 mt-0.5">
                    ${new Date(act.timestamp).toLocaleString()} • ${act.difficultyLevel}
                  </p>
                </div>
                <div class="text-right">
                  <span class="text-base font-black text-emerald-700 block">${act.accuracy}%</span>
                  <span class="text-[10px] font-black px-2 py-0.5 ${act.syncStatus === "SYNCED" ? "bg-emerald-100 text-emerald-800" : "bg-amber-100 text-amber-800"} rounded-full">
                    ${act.syncStatus}
                  </span>
                </div>
              </div>
            `).join("")}
          </div>
        ` : ""}
      </div>
    `;

    this.attachEvents();
  }

  attachEvents() {
    const backBtn = this.container.querySelector("#btn-back-home");
    if (backBtn) backBtn.addEventListener("click", () => this.onBackHome());

    const langBtns = this.container.querySelectorAll(".lang-btn");
    langBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const lang = btn.dataset.lang;
        this.setLanguage(lang);
      });
    });

    const tabBtns = this.container.querySelectorAll(".tab-btn");
    tabBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        this.activeTab = btn.dataset.tab;
        this.render();
      });
    });

    const gotoObsBtn = this.container.querySelector("#btn-goto-obs-form");
    if (gotoObsBtn) {
      gotoObsBtn.addEventListener("click", () => {
        this.activeTab = "observations";
        this.render();
      });
    }

    const obsForm = this.container.querySelector("#form-observation");
    if (obsForm) {
      obsForm.addEventListener("submit", (e) => {
        e.preventDefault();
        const fd = new FormData(obsForm);
        this.handleSaveObservation({
          mood: fd.get("mood"),
          sleep: fd.get("sleep"),
          appetite: fd.get("appetite"),
          dailyActivity: fd.get("dailyActivity"),
          memoryConcerns: fd.get("memoryConcerns"),
          notes: fd.get("notes")
        });
      });
    }

    const memForm = this.container.querySelector("#form-add-memory");
    if (memForm) {
      memForm.addEventListener("submit", (e) => {
        e.preventDefault();
        const fd = new FormData(memForm);
        const titleEn = fd.get("titleEn");
        const captionEn = fd.get("captionEn");
        this.handleAddMemory({
          title: { en: titleEn, hi: titleEn, as: titleEn },
          category: fd.get("category"),
          yearApprox: fd.get("yearApprox") || "Recent",
          iconKey: "grandkids",
          caption: { en: captionEn, hi: captionEn, as: captionEn }
        });
      });
    }

    const delMemBtns = this.container.querySelectorAll(".btn-delete-mem");
    delMemBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const id = btn.dataset.deleteMemory;
        this.handleDeleteMemory(id);
      });
    });
  }
}