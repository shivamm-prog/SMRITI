// SMRITI - Healthcare Professional / Doctor Portal & Longitudinal Analytics
import { UI_STRINGS } from '../data/i18n.js';
import { db } from '../db/smritiStorage.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';

export class DoctorPortal {
  constructor(container, options = {}) {
    this.container = container;
    this.onBackHome = options.onBackHome || (() => {});
    this.lang = options.lang || "en";
    this.selectedPatientId = "pat_anita_001";
    this.showReportModal = false;

    this.render();
  }

  setLanguage(lang) {
    this.lang = lang;
    this.render();
  }

  handlePrint() {
    window.print();
  }

  render() {
    const t = UI_STRINGS[this.lang] || UI_STRINGS.en;
    const profiles = db.getProfiles();
    const doctor = profiles.doctor;
    const patient = db.getPatientProfile(this.selectedPatientId);
    const metrics = PersonalizationEngine.calculateMetrics(this.selectedPatientId);
    const domainTrends = PersonalizationEngine.calculateDomainTrends(this.selectedPatientId);
    const observations = db.getObservations(this.selectedPatientId);
    const activities = db.getActivityResults(this.selectedPatientId);

    // Calculate dates and timeline
    const sessionDates = activities.map(a => a.timestamp.split("T")[0]);
    const uniqueSessionDays = Array.from(new Set(sessionDates)).length;

    this.container.innerHTML = `
      <div class="flex flex-col flex-1 p-4 sm:p-6 bg-slate-50 max-w-4xl mx-auto w-full animate-fade-in text-slate-900">
        
        <!-- Header -->
        <header class="flex items-center justify-between pb-4 border-b border-slate-200">
          <div class="flex items-center gap-3">
            <button id="btn-doc-back" class="px-3.5 py-2 bg-slate-200 hover:bg-slate-300 text-slate-800 font-bold rounded-xl text-sm flex items-center gap-1.5 transition">
              <span>←</span>
              <span>${t.backToHome}</span>
            </button>
            <div>
              <h1 class="text-xl sm:text-2xl font-black text-slate-900">Doctor Clinical Dashboard</h1>
              <p class="text-xs font-medium text-slate-500">${doctor.name} • ${doctor.hospital}</p>
            </div>
          </div>

          <button id="btn-open-report" class="px-4 py-2.5 bg-blue-700 hover:bg-blue-800 text-white rounded-xl text-xs sm:text-sm font-black shadow-md transition flex items-center gap-2">
            <span>📄</span>
            <span>View & Print Clinical Report</span>
          </button>
        </header>

        <!-- Mandatory Non-Diagnostic Disclaimer -->
        <div class="mt-4 p-4 rounded-2xl bg-blue-50 border-2 border-blue-200 text-xs sm:text-sm text-blue-950 flex items-start gap-3 shadow-sm">
          <span class="text-2xl">⚕️</span>
          <div>
            <span class="font-black uppercase tracking-wider block mb-0.5">Clinical Positioning Disclaimer:</span>
            <p class="leading-relaxed">
              ${t.medicalDisclaimerFull}
            </p>
          </div>
        </div>

        <!-- Patient Header Card -->
        <div class="mt-4 p-5 rounded-3xl bg-white border border-slate-200 shadow-sm flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div class="flex items-center gap-4">
            <div class="w-16 h-16 rounded-2xl bg-blue-100 border border-blue-300 flex items-center justify-center text-3xl">
              ${patient.avatar}
            </div>
            <div>
              <div class="flex items-center gap-2">
                <h2 class="text-2xl font-black text-slate-900">${patient.name}</h2>
                <span class="px-2.5 py-0.5 bg-blue-100 text-blue-900 rounded-full text-xs font-black">
                  ID: ${patient.id}
                </span>
                <span class="px-2 py-0.5 bg-emerald-100 text-emerald-800 rounded-md text-[11px] font-bold">
                  ✓ Authorized Record
                </span>
              </div>
              <p class="text-xs font-medium text-slate-600 mt-1">
                Age: ${patient.age} • ${patient.location} • Primary Caregiver: Rahul Das (Son) • Emergency: ${patient.emergencyContact}
              </p>
            </div>
          </div>

          <div class="text-left sm:text-right">
            <span class="text-xs font-bold text-slate-400 uppercase">Adaptive Stage</span>
            <span class="text-sm font-black text-blue-800 block">${metrics.adaptiveLevel.levelName}</span>
          </div>
        </div>

        <!-- Longitudinal Performance Metrics Grid -->
        <div class="mt-4 grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Total Sessions</span>
            <p class="text-3xl font-black text-blue-900 mt-1">${metrics.totalActivities}</p>
            <span class="text-[11px] text-emerald-700 font-bold">100% Completion Rate</span>
          </div>
          <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Mean Accuracy</span>
            <p class="text-3xl font-black text-blue-900 mt-1">${metrics.averageAccuracy}%</p>
            <span class="text-[11px] text-slate-500 font-medium">Activity Performance</span>
          </div>
          <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Session Days</span>
            <p class="text-3xl font-black text-blue-900 mt-1">${uniqueSessionDays}</p>
            <span class="text-[11px] text-slate-500 font-medium">Consistent engagement</span>
          </div>
          <div class="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm">
            <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Observations</span>
            <p class="text-3xl font-black text-blue-900 mt-1">${observations.length}</p>
            <span class="text-[11px] text-emerald-700 font-bold">Caregiver logs active</span>
          </div>
        </div>

        <!-- Graphs Section: Line Chart & Domain Bar Chart -->
        <div class="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
          
          <!-- Graph 1: Performance Over Time (Line / Progression Chart) -->
          <div class="bg-white p-5 rounded-3xl border border-slate-200 shadow-sm">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h3 class="text-base font-black text-slate-900">Performance Over Time</h3>
                <p class="text-xs text-slate-500">Session-by-session task accuracy</p>
              </div>
              <span class="text-xs font-bold px-2 py-0.5 bg-blue-100 text-blue-800 rounded-md">Line Trend</span>
            </div>

            <!-- Visual Line Chart Simulation -->
            <div class="h-44 flex items-end justify-between gap-2 pt-6 pb-2 border-b border-slate-200 px-2 bg-slate-50/50 rounded-2xl">
              ${activities.slice(0, 6).reverse().map((act, idx) => {
                const heightPercent = Math.max(30, act.accuracy);
                return `
                  <div class="flex-1 flex flex-col items-center gap-1.5 h-full justify-end group">
                    <span class="text-[10px] font-bold text-blue-800">${act.accuracy}%</span>
                    <div class="w-full max-w-[28px] bg-gradient-to-t from-blue-600 to-blue-400 rounded-t-lg transition-all duration-500 group-hover:from-blue-700 group-hover:to-blue-500" style="height: ${heightPercent}%"></div>
                    <span class="text-[9px] font-bold text-slate-400 mt-1 truncate max-w-[42px]">${act.activityType.split("_")[0]}</span>
                  </div>
                `;
              }).join("")}
            </div>
            <div class="mt-2 text-right">
              <span class="text-[11px] font-bold text-emerald-700">✓ Positive stability maintained</span>
            </div>
          </div>

          <!-- Graph 2: Performance by Cognitive Domain (Bar Chart) -->
          <div class="bg-white p-5 rounded-3xl border border-slate-200 shadow-sm">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h3 class="text-base font-black text-slate-900">Activity Performance by Domain</h3>
                <p class="text-xs text-slate-500">Stimulation domain breakdown</p>
              </div>
              <span class="text-xs font-bold px-2 py-0.5 bg-blue-100 text-blue-800 rounded-md">6 Domains</span>
            </div>

            <div class="space-y-2.5">
              ${Object.keys(domainTrends).map(key => {
                const d = domainTrends[key];
                return `
                  <div>
                    <div class="flex justify-between text-xs font-bold mb-0.5">
                      <span class="text-slate-700">${d.name}</span>
                      <span class="text-blue-900 font-black">${d.avgAccuracy}%</span>
                    </div>
                    <div class="w-full bg-slate-100 h-2.5 rounded-full overflow-hidden">
                      <div class="bg-blue-600 h-full rounded-full" style="width: ${d.avgAccuracy}%"></div>
                    </div>
                  </div>
                `;
              }).join("")}
            </div>
          </div>
        </div>

        <!-- Activity Frequency Calendar Heatmap -->
        <div class="mt-4 p-5 rounded-3xl bg-white border border-slate-200 shadow-sm">
          <div class="flex items-center justify-between mb-3">
            <div>
              <h3 class="text-base font-black text-slate-900">Session Frequency Calendar</h3>
              <p class="text-xs text-slate-500">Consistency of daily cognitive stimulation</p>
            </div>
            <span class="text-xs font-bold text-slate-500">August – September 2026</span>
          </div>

          <!-- 14-day Calendar Grid Simulation -->
          <div class="grid grid-cols-7 gap-2 text-center text-xs">
            ${["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map(day => `
              <div class="font-bold text-slate-400 text-[11px] pb-1">${day}</div>
            `).join("")}

            ${[
              { day: 24, sessions: 0 }, { day: 25, sessions: 0 }, { day: 26, sessions: 1 }, { day: 27, sessions: 0 }, { day: 28, sessions: 2 }, { day: 29, sessions: 1 }, { day: 30, sessions: 3 },
              { day: 31, sessions: 2 }, { day: 1, sessions: 4 }, { day: 2, sessions: 0 }, { day: 3, sessions: 0 }, { day: 4, sessions: 0 }, { day: 5, sessions: 0 }, { day: 6, sessions: 0 }
            ].map(cell => {
              const bgClass = cell.sessions >= 3 ? "bg-blue-600 text-white font-black" :
                              cell.sessions >= 1 ? "bg-blue-200 text-blue-950 font-bold" :
                              "bg-slate-100 text-slate-400";
              return `
                <div class="p-2.5 rounded-xl ${bgClass} flex flex-col items-center justify-center aspect-square shadow-sm">
                  <span class="text-xs">${cell.day}</span>
                  ${cell.sessions > 0 ? `<span class="text-[9px] mt-0.5 opacity-90">${cell.sessions} act</span>` : `<span class="text-[9px] opacity-40">-</span>`}
                </div>
              `;
            }).join("")}
          </div>
        </div>

        <!-- Caregiver Longitudinal Observations Table -->
        <div class="mt-4 p-5 rounded-3xl bg-white border border-slate-200 shadow-sm">
          <h3 class="text-base font-black text-slate-900 mb-1">Caregiver Observations Longitudinal Log</h3>
          <p class="text-xs text-slate-500 mb-4">Recorded daily by Rahul Das (Son / Primary Caregiver)</p>

          <div class="overflow-x-auto">
            <table class="w-full text-left text-xs border-collapse">
              <thead>
                <tr class="border-b border-slate-200 text-slate-500 uppercase font-black tracking-wider">
                  <th class="py-2 px-3">Date</th>
                  <th class="py-2 px-3">Mood</th>
                  <th class="py-2 px-3">Sleep</th>
                  <th class="py-2 px-3">Appetite</th>
                  <th class="py-2 px-3">Physical Activity</th>
                  <th class="py-2 px-3">Memory Concerns</th>
                  <th class="py-2 px-3">Caregiver Clinical Notes</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100 font-medium">
                ${observations.map(obs => `
                  <tr>
                    <td class="py-3 px-3 font-bold text-slate-900 whitespace-nowrap">${obs.date}</td>
                    <td class="py-3 px-3"><span class="px-2 py-0.5 bg-emerald-100 text-emerald-800 rounded-md font-bold">${obs.mood}</span></td>
                    <td class="py-3 px-3">${obs.sleep}</td>
                    <td class="py-3 px-3">${obs.appetite}</td>
                    <td class="py-3 px-3">${obs.dailyActivity}</td>
                    <td class="py-3 px-3">${obs.memoryConcerns}</td>
                    <td class="py-3 px-3 text-slate-600 max-w-xs italic">"${obs.notes}"</td>
                  </tr>
                `).join("")}
              </tbody>
            </table>
          </div>
        </div>

        <!-- Full SMRITI Clinical Report Modal / Print View -->
        <div id="report-modal" class="${this.showReportModal ? "fixed inset-0 z-50 bg-black/60 flex items-center justify-center p-4 overflow-y-auto" : "hidden"}">
          <div class="bg-white rounded-3xl max-w-3xl w-full max-h-[90vh] overflow-y-auto p-6 sm:p-8 shadow-2xl relative">
            
            <!-- Modal Actions (Hidden in Print) -->
            <div class="flex items-center justify-between pb-4 border-b border-slate-200 mb-6 print:hidden">
              <div class="flex items-center gap-2">
                <span class="text-2xl">📄</span>
                <span class="font-black text-lg text-slate-900">SMRITI Cognitive Activity Report</span>
              </div>
              <div class="flex items-center gap-2">
                <button id="btn-print-report" class="px-4 py-2 bg-blue-700 hover:bg-blue-800 text-white rounded-xl text-xs font-black shadow transition flex items-center gap-1.5">
                  <span>🖨️</span>
                  <span>Print / PDF Export</span>
                </button>
                <button id="btn-close-report" class="p-2 text-slate-400 hover:text-slate-800 rounded-lg text-lg font-bold">
                  ✕
                </button>
              </div>
            </div>

            <!-- SMRITI COGNITIVE ACTIVITY REPORT CONTENT -->
            <div id="printable-report-content" class="text-slate-900 font-sans space-y-6">
              
              <!-- Report Title Header -->
              <div class="text-center border-b-2 border-slate-800 pb-4">
                <h1 class="text-2xl font-black uppercase tracking-tight text-slate-950">SMRITI COGNITIVE ACTIVITY REPORT</h1>
                <p class="text-xs font-bold text-slate-600 mt-1">
                  Supportive Cognitive Stimulation & Reminiscence Longitudinal Activity Summary
                </p>
                <div class="mt-3 flex flex-wrap justify-between text-xs font-bold bg-slate-100 p-3 rounded-xl">
                  <span><strong>Patient:</strong> ${patient.name}</span>
                  <span><strong>Patient ID:</strong> ${patient.id}</span>
                  <span><strong>Age/Gender:</strong> ${patient.age} / Female</span>
                  <span><strong>Reporting Period:</strong> 30 Aug 2026 – 01 Sep 2026</span>
                </div>
              </div>

              <!-- 1. Activity Summary -->
              <section>
                <h3 class="text-sm font-black uppercase tracking-wider text-blue-950 border-b border-slate-200 pb-1 mb-2">
                  1. Activity Summary
                </h3>
                <p class="text-xs text-slate-700 leading-relaxed">
                  During this reporting period, the patient engaged in <strong>${metrics.totalActivities} structured cognitive stimulation sessions</strong> across trilingual interfaces (Assamese, Hindi, English). The patient maintained a <strong>${metrics.completionRate}% completion rate</strong> with an average task accuracy of <strong>${metrics.averageAccuracy}%</strong> and an average response latency of <strong>${metrics.averageResponseTimeSec} seconds</strong>.
                </p>
              </section>

              <!-- 2-6. Domain Performances -->
              <section class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-200">
                  <h4 class="text-xs font-black text-slate-900 mb-1">2. Memory Activity Performance</h4>
                  <p class="text-xs text-slate-600">Accuracy: <strong>${domainTrends.memory.avgAccuracy}%</strong> across ${domainTrends.memory.sessions} sessions. High familiarity with domestic and cultural icons.</p>
                </div>
                <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-200">
                  <h4 class="text-xs font-black text-slate-900 mb-1">3. Attention Activity Performance</h4>
                  <p class="text-xs text-slate-600">Accuracy: <strong>${domainTrends.attention.avgAccuracy}%</strong> across ${domainTrends.attention.sessions} sessions. Successfully remembered object sets with minimal distractors.</p>
                </div>
                <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-200">
                  <h4 class="text-xs font-black text-slate-900 mb-1">4. Language Activity Performance</h4>
                  <p class="text-xs text-slate-600">Accuracy: <strong>${domainTrends.language.avgAccuracy}%</strong> across ${domainTrends.language.sessions} sessions. Fluent semantic categorizations in Assamese and Hindi.</p>
                </div>
                <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-200">
                  <h4 class="text-xs font-black text-slate-900 mb-1">5. Sequencing Activity Performance</h4>
                  <p class="text-xs text-slate-600">Accuracy: <strong>${domainTrends.sequencing.avgAccuracy}%</strong> across ${domainTrends.sequencing.sessions} sessions. Correctly ordered tea-making and walking routines.</p>
                </div>
              </section>

              <!-- 6-7. Orientation & Reminiscence -->
              <section class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-200">
                  <h4 class="text-xs font-black text-slate-900 mb-1">6. Orientation Activity Performance</h4>
                  <p class="text-xs text-slate-600">Accuracy: <strong>${domainTrends.orientation.avgAccuracy}%</strong>. Responsive to day, month, season, and immediate helper orientation questions.</p>
                </div>
                <div class="bg-slate-50 p-3.5 rounded-xl border border-slate-200">
                  <h4 class="text-xs font-black text-slate-900 mb-1">7. Reminiscence Activity Engagement</h4>
                  <p class="text-xs text-slate-600">Engagement: <strong>100%</strong>. High spontaneous engagement with Tezpur ancestral home and granddaughter birthday memories.</p>
                </div>
              </section>

              <!-- 8. Caretaker Observations -->
              <section>
                <h3 class="text-sm font-black uppercase tracking-wider text-blue-950 border-b border-slate-200 pb-1 mb-2">
                  8. Caretaker Observations
                </h3>
                <p class="text-xs text-slate-700 leading-relaxed">
                  Caregiver Rahul Das reports stable positive mood ("Happy" on 2/3 logged days, "Neutral" on 1/3), consistent 7.1-hour average sleep, good appetite, and active physical engagement. Memory concerns were recorded as "None" to "Mild".
                </p>
              </section>

              <!-- 9-11. Trends, Changes & Frequency -->
              <section class="space-y-3">
                <div>
                  <h3 class="text-sm font-black uppercase tracking-wider text-blue-950 border-b border-slate-200 pb-1 mb-1">
                    9. Activity Trends
                  </h3>
                  <p class="text-xs text-slate-700">Adaptive engine maintains Level 1 (Very Easy) with consistent $\ge 80\%$ performance, ensuring positive reinforcement and zero cognitive frustration.</p>
                </div>
                <div>
                  <h3 class="text-sm font-black uppercase tracking-wider text-blue-950 border-b border-slate-200 pb-1 mb-1">
                    10. Notable Changes
                  </h3>
                  <p class="text-xs text-slate-700">No sudden decline or agitation noted. Strong emotional response and spontaneous verbalization during Assamese Bihu folk tunes and tea garden memories.</p>
                </div>
                <div>
                  <h3 class="text-sm font-black uppercase tracking-wider text-blue-950 border-b border-slate-200 pb-1 mb-1">
                    11. Session Frequency
                  </h3>
                  <p class="text-xs text-slate-700">Session frequency averaged 1 to 2 sessions per active day, meeting recommended non-pharmacological engagement benchmarks.</p>
                </div>
              </section>

              <!-- Mandatory Clinical Disclaimer -->
              <div class="p-4 bg-amber-50 border-2 border-amber-300 rounded-xl text-xs text-amber-950 leading-relaxed">
                <strong>MANDATORY CLINICAL DISCLAIMER:</strong><br>
                “This report summarizes performance during SMRITI activities. It is not a diagnostic tool and should not be used alone to diagnose dementia or determine disease progression. Clinical decisions should be made by qualified healthcare professionals.”
              </div>

              <!-- Sign-off Block -->
              <div class="pt-6 border-t border-slate-300 flex justify-between text-xs text-slate-600">
                <div>
                  <p><strong>Generated By:</strong> SMRITI Autonomous Platform v2.0</p>
                  <p>Guwahati Geriatric Care Network</p>
                </div>
                <div class="text-right">
                  <p><strong>Attending Clinician:</strong> Dr. Mehta, MD, DM</p>
                  <p>Reg No: MC-ASM-51204</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;

    this.attachEvents();
  }

  attachEvents() {
    const backBtn = this.container.querySelector("#btn-doc-back");
    if (backBtn) backBtn.addEventListener("click", () => this.onBackHome());

    const openReportBtn = this.container.querySelector("#btn-open-report");
    if (openReportBtn) {
      openReportBtn.addEventListener("click", () => {
        this.showReportModal = true;
        this.render();
      });
    }

    const closeReportBtn = this.container.querySelector("#btn-close-report");
    if (closeReportBtn) {
      closeReportBtn.addEventListener("click", () => {
        this.showReportModal = false;
        this.render();
      });
    }

    const printBtn = this.container.querySelector("#btn-print-report");
    if (printBtn) {
      printBtn.addEventListener("click", () => this.handlePrint());
    }
  }
}