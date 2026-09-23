// SMRITI - Game 3: Daily Life Sequence (Sequencing, Planning & Everyday Cognition)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';

export class DailyLifeSequencingGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});

    // Adaptive selection of routine
    const adaptive = PersonalizationEngine.getAdaptiveLevel("pat_anita_001", "daily_life_sequencing");
    this.routineIndex = options.routineIndex !== undefined ? options.routineIndex : ((adaptive.level - 1) % this.gameData.routines.length);
    this.currentRoutine = this.gameData.routines[this.routineIndex] || this.gameData.routines[0];

    this.orderedSteps = [];
    this.availableSteps = [];
    this.startTime = Date.now();
    this.attempts = 0;
    this.hasCompleted = false;

    this.initRoutine();
    this.render();
    this.playAudioInstruction();
  }

  initRoutine() {
    // Copy steps and randomize available pool
    const steps = this.currentRoutine.steps.map(s => ({ ...s }));
    this.availableSteps = [...steps].sort(() => Math.random() - 0.5);
    this.orderedSteps = [];
  }

  playAudioInstruction() {
    const prompt = this.currentRoutine.audioPrompt[this.lang] || this.currentRoutine.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleSelectStep(step) {
    if (this.hasCompleted) return;
    audio.playSoftTap();

    // Move from available to ordered
    this.availableSteps = this.availableSteps.filter(s => s.stepNumber !== step.stepNumber);
    this.orderedSteps.push(step);
    this.render();

    // Check when all steps are ordered
    if (this.availableSteps.length === 0) {
      this.attempts++;
      this.checkSequence();
    }
  }

  handleRemoveStep(step) {
    if (this.hasCompleted) return;
    audio.playSoftTap();

    // Move back from ordered to available
    this.orderedSteps = this.orderedSteps.filter(s => s.stepNumber !== step.stepNumber);
    this.availableSteps.push(step);
    this.render();
  }

  checkSequence() {
    let isCorrect = true;
    for (let i = 0; i < this.orderedSteps.length; i++) {
      if (this.orderedSteps[i].stepNumber !== (i + 1)) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      this.hasCompleted = true;
      audio.playPositiveChime();
      const duration = Date.now() - this.startTime;
      const accuracy = this.attempts === 1 ? 100 : Math.max(60, 100 - (this.attempts - 1) * 15);

      const record = db.saveActivityResult({
        activityType: "daily_life_sequencing",
        activityTitle: `Daily Life Sequence - ${this.currentRoutine.title.en}`,
        difficultyLevel: `Level ${this.routineIndex + 1}`,
        accuracy: accuracy,
        responseTimeMs: duration,
        attempts: this.attempts,
        correctMatches: this.currentRoutine.steps.length,
        incorrectMatches: 0,
        hintsUsed: 0,
        language: this.lang
      });

      audio.speak(
        this.lang === "as" ? "অসম্ভৱ সুন্দৰ! আপুনি সকলো খোজ সঠিক ক্ৰমত সজালে।" :
        this.lang === "hi" ? "बहुत सुंदर! आपने सभी चरणों को बिल्कुल सही क्रम में लगाया।" :
        "Wonderful! You arranged all the steps in the correct order.",
        this.lang
      );

      setTimeout(() => {
        this.onComplete(record);
      }, 1000);
    } else {
      // Gentle encouragement to retry
      audio.speak(
        this.lang === "as" ? "আহক আকৌ এবাৰ চেষ্টা কৰোঁ। কাৰ্যবোৰৰ ক্ৰম মনত পেলাওক।" :
        this.lang === "hi" ? "आइए एक बार फिर कोशिश करते हैं। चरणों के सही क्रम को याद करें।" :
        "Let’s try one more time. Think about the comforting daily routine.",
        this.lang
      );

      setTimeout(() => {
        this.initRoutine();
        this.render(true);
      }, 1400);
    }
  }

  render(showTryAgain = false) {
    const routineTitle = this.currentRoutine.title[this.lang] || this.currentRoutine.title.en;
    const prompt = this.currentRoutine.audioPrompt[this.lang] || this.currentRoutine.audioPrompt.en;
    const subtitle = this.currentRoutine.subtitleEn;

    this.container.innerHTML = `
      <div class="p-4 flex flex-col flex-1 max-w-xl mx-auto w-full animate-fade-in">
        <!-- Top Navigation -->
        <div class="flex items-center justify-between mb-3 border-b border-stone-200 pb-2">
          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-base flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${this.lang === "as" ? "বাহিৰ হওক" : this.lang === "hi" ? "बाहर निकलें" : "Exit"}</span>
          </button>
          <div class="text-xs font-bold px-2.5 py-1 bg-amber-100 text-amber-900 rounded-full border border-amber-300">
            ${this.lang === "as" ? "দৈনন্দিন ক্ৰম" : this.lang === "hi" ? "दैनिक क्रम" : "Daily Sequencing"}
          </div>
        </div>

        <!-- Activity Title & Instructions -->
        <div class="bg-amber-50 border-2 border-amber-200 p-4 rounded-2xl mb-4 shadow-sm">
          <div class="flex items-start justify-between gap-3">
            <div>
              <div class="text-xs font-bold text-amber-800 uppercase tracking-wider mb-0.5">
                ${routineTitle}
              </div>
              <h2 class="text-xl font-black text-stone-900">${prompt}</h2>
              ${this.lang !== "en" ? `<p class="text-xs font-mono text-stone-500 mt-0.5 italic">${subtitle}</p>` : ""}
            </div>
            <button id="btn-audio-prompt" class="p-3 bg-amber-500 hover:bg-amber-600 text-white rounded-2xl shadow-md transition flex-shrink-0">
              <span class="text-2xl">🔊</span>
            </button>
          </div>
          ${showTryAgain ? `
            <div class="mt-2 p-2 bg-amber-200 border border-amber-300 text-amber-950 rounded-xl text-sm font-bold flex items-center gap-2">
              <span>🌸</span>
              <span>${this.lang === "as" ? "আহক আকৌ এবাৰ চেষ্টা কৰোঁ। আপুনি নিশ্চয় পাৰিব!" : this.lang === "hi" ? "आइए एक बार फिर कोशिश करते हैं। अपना समय लें!" : "Let’s try once more. Take your time!"}</span>
            </div>
          ` : ""}
        </div>

        <!-- Target Sequence Slots (1 -> 2 -> 3) -->
        <div class="mb-5">
          <div class="text-xs font-bold text-stone-600 uppercase tracking-wider mb-2 flex items-center justify-between">
            <span>${this.lang === "as" ? "আপোনাৰ সজোৱা ক্ৰম" : this.lang === "hi" ? "आपका व्यवस्थित क्रम" : "Your Ordered Steps"}:</span>
            <span class="text-amber-800">${this.orderedSteps.length} / ${this.currentRoutine.steps.length}</span>
          </div>

          <div class="space-y-2.5">
            ${[0, 1, 2].slice(0, this.currentRoutine.steps.length).map(idx => {
              const step = this.orderedSteps[idx];
              if (step) {
                const label = step.label[this.lang] || step.label.en;
                return `
                  <div class="bg-amber-100 border-2 border-amber-500 rounded-2xl p-3 flex items-center justify-between shadow-sm animate-fade-in">
                    <div class="flex items-center gap-3">
                      <span class="w-8 h-8 rounded-full bg-amber-700 text-white font-black flex items-center justify-center text-sm shadow">
                        ${idx + 1}
                      </span>
                      <div class="w-10 h-10 flex-shrink-0">
                        ${ICONS[step.iconKey] || `<span class="text-2xl">☕</span>`}
                      </div>
                      <span class="text-base font-bold text-stone-900 leading-snug">
                        ${label}
                      </span>
                    </div>
                    <button 
                      data-remove-step="${step.stepNumber}"
                      class="btn-remove-step p-2 text-stone-400 hover:text-red-600 rounded-lg text-lg font-bold" title="Remove">
                      ✕
                    </button>
                  </div>
                `;
              } else {
                return `
                  <div class="border-2 border-dashed border-stone-300 rounded-2xl p-3 flex items-center gap-3 bg-stone-50/50">
                    <span class="w-8 h-8 rounded-full bg-stone-200 text-stone-600 font-bold flex items-center justify-center text-sm">
                      ${idx + 1}
                    </span>
                    <span class="text-sm font-semibold text-stone-400 italic">
                      ${this.lang === "as" ? `খোজ ${idx + 1} তলৰ পৰা বাছক` : this.lang === "hi" ? `चरण ${idx + 1} नीचे से चुनें` : `Tap step ${idx + 1} below`}
                    </span>
                  </div>
                `;
              }
            }).join("")}
          </div>
        </div>

        <!-- Available Steps Pool -->
        <div class="my-auto">
          <div class="text-xs font-bold text-stone-600 uppercase tracking-wider mb-2">
            ${this.lang === "as" ? "তলৰ খোজবোৰ স্পৰ্শ কৰক:" : this.lang === "hi" ? "नीचे दिए गए चरणों पर स्पर्श करें:" : "Tap a step to place it in order:"}
          </div>

          <div class="space-y-2.5">
            ${this.availableSteps.map(step => {
              const label = step.label[this.lang] || step.label.en;
              return `
                <button 
                  data-step-number="${step.stepNumber}"
                  class="btn-select-step w-full bg-white hover:bg-amber-50 active:bg-amber-100 border-2 border-stone-300 hover:border-amber-500 rounded-2xl p-3.5 flex items-center gap-3 shadow-md transition text-left transform active:scale-98">
                  <div class="w-12 h-12 flex-shrink-0">
                    ${ICONS[step.iconKey] || `<span class="text-3xl">☕</span>`}
                  </div>
                  <span class="text-base sm:text-lg font-bold text-stone-900 leading-snug flex-1">
                    ${label}
                  </span>
                  <span class="text-amber-600 font-black text-xl">➔</span>
                </button>
              `;
            }).join("")}
          </div>
        </div>
      </div>
    `;

    this.attachEvents();
  }

  attachEvents() {
    const exitBtn = this.container.querySelector("#btn-exit-game");
    if (exitBtn) exitBtn.addEventListener("click", () => this.onExit());

    const audioBtn = this.container.querySelector("#btn-audio-prompt");
    if (audioBtn) audioBtn.addEventListener("click", () => this.playAudioInstruction());

    const selectBtns = this.container.querySelectorAll(".btn-select-step");
    selectBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const stepNum = parseInt(btn.dataset.stepNumber, 10);
        const step = this.availableSteps.find(s => s.stepNumber === stepNum);
        if (step) this.handleSelectStep(step);
      });
    });

    const removeBtns = this.container.querySelectorAll(".btn-remove-step");
    removeBtns.forEach(btn => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const stepNum = parseInt(btn.dataset.removeStep, 10);
        const step = this.orderedSteps.find(s => s.stepNumber === stepNum);
        if (step) this.handleRemoveStep(step);
      });
    });
  }
}