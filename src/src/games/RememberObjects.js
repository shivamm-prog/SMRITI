// SMRITI - Game 2: Remember the Objects (Attention & Working Memory Stimulation)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';

export class RememberObjectsGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});

    // Adaptive difficulty
    const adaptive = PersonalizationEngine.getAdaptiveLevel("pat_anita_001", "remember_objects");
    this.setIndex = options.setIndex !== undefined ? options.setIndex : Math.min(adaptive.level - 1, this.gameData.sets.length - 1);
    this.currentSet = this.gameData.sets[this.setIndex] || this.gameData.sets[0];

    // Phases: 'memorize' -> 'recall' -> 'feedback'
    this.phase = "memorize";
    this.selectedKeys = new Set();
    this.startTime = Date.now();
    this.attempts = 0;
    this.isChecking = false;

    this.render();
    this.playAudioInstruction();
  }

  playAudioInstruction() {
    if (this.phase === "memorize") {
      const prompt = this.gameData.audioPrompt[this.lang] || this.gameData.audioPrompt.en;
      audio.speak(prompt, this.lang);
    } else {
      const prompt = this.gameData.questionPrompt[this.lang] || this.gameData.questionPrompt.en;
      audio.speak(prompt, this.lang);
    }
  }

  handleStartRecall() {
    this.phase = "recall";
    this.selectedKeys.clear();
    this.render();
    this.playAudioInstruction();
  }

  handleToggleOption(key) {
    if (this.selectedKeys.has(key)) {
      this.selectedKeys.delete(key);
    } else {
      this.selectedKeys.add(key);
    }
    audio.playSoftTap();
    this.render();
  }

  handleCheckAnswers() {
    if (this.selectedKeys.size === 0) return;
    this.attempts++;
    
    const targetKeys = new Set(this.currentSet.targets.map(t => t.key));
    let correctCount = 0;
    let incorrectCount = 0;

    this.selectedKeys.forEach(k => {
      if (targetKeys.has(k)) {
        correctCount++;
      } else {
        incorrectCount++;
      }
    });

    const isAllCorrect = (correctCount === targetKeys.size) && (incorrectCount === 0);

    if (isAllCorrect) {
      audio.playPositiveChime();
      const duration = Date.now() - this.startTime;
      const accuracy = Math.max(60, Math.round((correctCount / (correctCount + incorrectCount + (this.attempts - 1))) * 100));

      const record = db.saveActivityResult({
        activityType: "remember_objects",
        activityTitle: `Remember the Objects (Level ${this.currentSet.level})`,
        difficultyLevel: `Level ${this.currentSet.level}`,
        accuracy: accuracy,
        responseTimeMs: duration,
        attempts: this.attempts,
        correctMatches: correctCount,
        incorrectMatches: incorrectCount,
        hintsUsed: 0,
        language: this.lang
      });

      audio.speak(
        this.lang === "as" ? "অসাধাৰণ! আপুনি সকলো কেইটা চিনাকি বস্তু সঠিকভাৱে মনত পেলালে।" :
        this.lang === "hi" ? "अद्भुत! आपने सभी दिखाई गई वस्तुओं को बिल्कुल सही पहचाना।" :
        "Wonderful! You correctly identified all the objects you saw.",
        this.lang
      );

      this.onComplete(record);
    } else {
      // Gentle encouragement
      audio.speak(
        this.lang === "as" ? "আহক আকৌ এবাৰ চেষ্টা কৰোঁ। লাহে লাহে মনত পেলাওক।" :
        this.lang === "hi" ? "आइए एक बार फिर कोशिश करते हैं। आराम से याद करें।" :
        "Let’s try one more time. Take your time to remember.",
        this.lang
      );
      this.render(true); // render with gentle feedback note
    }
  }

  render(showHint = false) {
    const title = this.gameData.title[this.lang] || this.gameData.title.en;
    
    this.container.innerHTML = `
      <div class="p-4 flex flex-col flex-1 max-w-xl mx-auto w-full animate-fade-in">
        <!-- Top Navigation -->
        <div class="flex items-center justify-between mb-3 border-b border-stone-200 pb-2">
          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-base flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${this.lang === "as" ? "বাহিৰ হওক" : this.lang === "hi" ? "बाहर निकलें" : "Exit"}</span>
          </button>
          <div>
            <span class="text-xs font-bold px-2.5 py-1 bg-amber-100 text-amber-900 rounded-full border border-amber-300">
              Level ${this.currentSet.level}
            </span>
          </div>
        </div>

        ${this.phase === "memorize" ? `
          <!-- Phase 1: Memorize the Objects -->
          <div class="bg-amber-50 border-2 border-amber-200 p-4 rounded-2xl mb-4 shadow-sm">
            <div class="flex items-start justify-between gap-3">
              <div>
                <h2 class="text-2xl font-black text-amber-950">${title}</h2>
                <p class="text-lg font-bold text-stone-800 mt-1 leading-snug">
                  ${this.gameData.audioPrompt[this.lang] || this.gameData.audioPrompt.en}
                </p>
                ${this.lang !== "en" ? `<p class="text-xs font-mono text-stone-500 mt-0.5 italic">${this.gameData.subtitleEn}</p>` : ""}
              </div>
              <button id="btn-audio-prompt" class="p-3 bg-amber-500 hover:bg-amber-600 text-white rounded-2xl shadow-md transition transform active:scale-95 flex-shrink-0" title="Listen Again">
                <span class="text-2xl">🔊</span>
              </button>
            </div>
          </div>

          <!-- Target Items Showcase -->
          <div class="my-auto py-4">
            <div class="text-center text-xs font-bold text-stone-500 uppercase tracking-wider mb-3">
              ${this.lang === "as" ? "এই বস্তুবোৰ মনত ৰাখক" : this.lang === "hi" ? "इन वस्तुओं को याद रखें" : "Remember these objects"} (${this.currentSet.targets.length})
            </div>
            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
              ${this.currentSet.targets.map(target => {
                const label = target.label[this.lang] || target.label.en;
                return `
                  <div class="bg-white border-4 border-amber-400 rounded-2xl p-4 flex flex-col items-center justify-center shadow-lg transform scale-105">
                    <div class="w-16 h-16 sm:w-20 sm:h-20 mb-2">
                      ${ICONS[target.key] || `<span class="text-4xl">🍎</span>`}
                    </div>
                    <span class="text-base sm:text-lg font-black text-stone-900 text-center leading-tight">
                      ${label}
                    </span>
                  </div>
                `;
              }).join("")}
            </div>
          </div>

          <!-- Proceed Button -->
          <div class="mt-6">
            <button id="btn-start-recall" class="w-full py-4 bg-amber-600 hover:bg-amber-700 active:bg-amber-800 text-white text-xl font-black rounded-2xl shadow-lg transition flex items-center justify-center gap-2">
              <span>${this.lang === "as" ? "মই মনত ৰাখিলোঁ (সাজু)" : this.lang === "hi" ? "मुझे याद है (आगे बढ़ें)" : "I am Ready (Continue)"}</span>
              <span>➔</span>
            </button>
          </div>
        ` : `
          <!-- Phase 2: Recall / Which objects did you see? -->
          <div class="bg-amber-50 border-2 border-amber-200 p-4 rounded-2xl mb-3 shadow-sm">
            <div class="flex items-start justify-between gap-3">
              <div>
                <h2 class="text-xl font-black text-amber-950">${this.gameData.questionPrompt[this.lang] || this.gameData.questionPrompt.en}</h2>
                <p class="text-sm font-bold text-stone-700 mt-0.5">
                  ${this.lang === "as" ? `পূৰ্বে দেখা ${this.currentSet.targets.length} টা বস্তু বাছক` : this.lang === "hi" ? `पहले देखी गई ${this.currentSet.targets.length} वस्तुएँ चुनें` : `Select the ${this.currentSet.targets.length} items shown earlier`}
                </p>
                ${this.lang !== "en" ? `<p class="text-xs font-mono text-stone-500 mt-0.5 italic">${this.gameData.questionSubtitleEn}</p>` : ""}
              </div>
              <button id="btn-audio-prompt" class="p-3 bg-amber-500 hover:bg-amber-600 text-white rounded-2xl shadow-md transition flex-shrink-0">
                <span class="text-2xl">🔊</span>
              </button>
            </div>
            ${showHint ? `
              <div class="mt-2 p-2 bg-amber-200 border border-amber-300 text-amber-950 rounded-xl text-sm font-bold flex items-center gap-2">
                <span>🌸</span>
                <span>${this.lang === "as" ? "লাহে লাহে পুনৰ চেষ্টা কৰক। আপুনি নিশ্চয় পাৰিব!" : this.lang === "hi" ? "आराम से फिर कोशिश करें। आप बहुत अच्छा कर रहे हैं!" : "Take your time. Let’s try once more!"}</span>
              </div>
            ` : ""}
          </div>

          <!-- Options Grid -->
          <div class="grid grid-cols-2 sm:grid-cols-3 gap-3 my-auto py-2">
            ${this.currentSet.options.map(opt => {
              const isSelected = this.selectedKeys.has(opt.key);
              const label = opt.label[this.lang] || opt.label.en;
              return `
                <button 
                  data-option-key="${opt.key}"
                  class="option-btn aspect-square rounded-2xl p-3 flex flex-col items-center justify-center transition-all duration-200 shadow-md transform active:scale-95 relative
                  ${isSelected 
                    ? "bg-amber-100 border-4 border-amber-600 shadow-xl ring-2 ring-amber-400" 
                    : "bg-white border-2 border-stone-300 hover:border-amber-400"}">
                  <div class="w-14 h-14 sm:w-16 sm:h-16 mb-1 pointer-events-none">
                    ${ICONS[opt.key] || `<span class="text-3xl">📦</span>`}
                  </div>
                  <span class="text-xs sm:text-sm font-bold text-stone-900 text-center leading-tight pointer-events-none">
                    ${label}
                  </span>
                  ${isSelected ? `
                    <div class="absolute top-2 right-2 w-6 h-6 bg-amber-600 text-white rounded-full flex items-center justify-center text-xs font-black shadow">
                      ✓
                    </div>
                  ` : ""}
                </button>
              `;
            }).join("")}
          </div>

          <!-- Submit / Check Button -->
          <div class="mt-4">
            <button 
              id="btn-check-answers" 
              class="w-full py-4 ${this.selectedKeys.size > 0 ? "bg-emerald-600 hover:bg-emerald-700 text-white shadow-lg" : "bg-stone-300 text-stone-500 cursor-not-allowed"} text-xl font-black rounded-2xl transition flex items-center justify-center gap-2"
              ${this.selectedKeys.size === 0 ? "disabled" : ""}>
              <span>${this.lang === "as" ? "উত্তৰ নিশ্চিত কৰক" : this.lang === "hi" ? "उत्तर जांचें" : "Check My Answers"} (${this.selectedKeys.size} / ${this.currentSet.targets.length})</span>
            </button>
          </div>
        `}
      </div>
    `;

    this.attachEvents();
  }

  attachEvents() {
    const exitBtn = this.container.querySelector("#btn-exit-game");
    if (exitBtn) exitBtn.addEventListener("click", () => this.onExit());

    const audioBtn = this.container.querySelector("#btn-audio-prompt");
    if (audioBtn) audioBtn.addEventListener("click", () => this.playAudioInstruction());

    const startRecallBtn = this.container.querySelector("#btn-start-recall");
    if (startRecallBtn) startRecallBtn.addEventListener("click", () => this.handleStartRecall());

    const optionBtns = this.container.querySelectorAll(".option-btn");
    optionBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const key = btn.dataset.optionKey;
        this.handleToggleOption(key);
      });
    });

    const checkBtn = this.container.querySelector("#btn-check-answers");
    if (checkBtn) checkBtn.addEventListener("click", () => this.handleCheckAnswers());
  }
}
