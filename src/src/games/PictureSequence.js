// SMRITI - Game 3: Picture Sequence (Executive Function & Daily Routine Sequencing)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';

export class PictureSequenceGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});
    this.seqIndex = options.seqIndex || 0;

    this.sequences = this.gameData.sequences || [];
    this.currentSeq = this.sequences[this.seqIndex] || this.sequences[0];
    this.originalSteps = [...this.currentSeq.steps];
    
    // Scrambled pool
    this.pool = [...this.originalSteps].sort(() => Math.random() - 0.5);
    this.placedSteps = []; // User selected sequence
    this.startTime = Date.now();
    this.isCompleted = false;

    this.render();
    this.playAudioInstruction();
  }

  playAudioInstruction() {
    const prompt = this.gameData.audioPrompt[this.lang] || this.gameData.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleSelectCardFromPool(step) {
    if (this.isCompleted) return;
    audio.playSoftTap();
    this.pool = this.pool.filter(s => s.stepNumber !== step.stepNumber);
    this.placedSteps.push(step);
    this.checkProgress();
    this.render();
  }

  handleRemoveCardFromSlot(index) {
    if (this.isCompleted) return;
    audio.playSoftTap();
    const removed = this.placedSteps.splice(index, 1)[0];
    this.pool.push(removed);
    this.render();
  }

  checkProgress() {
    if (this.placedSteps.length === this.originalSteps.length) {
      // Check if order is correct
      const isCorrect = this.placedSteps.every((step, idx) => step.stepNumber === (idx + 1));
      if (isCorrect) {
        this.isCompleted = true;
        audio.playPositiveChime();
        const duration = Date.now() - this.startTime;

        const record = db.saveActivityResult({
          activityType: "picture_sequence",
          activityTitle: `Picture Sequence - ${this.currentSeq.title.en}`,
          difficultyLevel: "gentle",
          accuracy: 100,
          responseTimeMs: duration,
          attempts: 1,
          hintsUsed: 0,
          language: this.lang
        });

        const wellDone = this.lang === "as" ? "অসম্ভৱ ধুনীয়া! আপুনি চাহ বনোৱাৰ সকলো খোজ সঠিক ক্ৰমত সজালে।" :
                         this.lang === "hi" ? "बहुत खूब! आपने सभी चरणों को सही क्रम में लगाया।" :
                         "Excellent work! You arranged all the steps in perfect order.";
        audio.speak(wellDone, this.lang);

        setTimeout(() => {
          this.onComplete({
            record,
            durationMs: duration
          });
        }, 1800);
      } else {
        // Subtle hint
        const hintText = this.lang === "as" ? "কোনো এটা খোজ পুনৰ ভাবি চাওক।" :
                         this.lang === "hi" ? "कृपया क्रम को दोबारा देखें।" :
                         "Let's look at the sequence again.";
        audio.speak(hintText, this.lang);
      }
    }
  }

  render() {
    const seqTitle = this.currentSeq.title[this.lang] || this.currentSeq.title.en;
    const promptText = this.gameData.description[this.lang] || this.gameData.description.en;
    const subtitle = this.gameData.subtitleEn;

    this.container.innerHTML = `
      <div class="flex flex-col h-full max-w-2xl mx-auto p-4 select-none">
        <!-- Top Bar -->
        <div class="flex items-center justify-between mb-3 bg-amber-50 rounded-2xl p-3 border border-amber-200">
          <button id="btn-repeat-audio" class="flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-xl font-bold shadow transition active:scale-95 text-lg">
            <span>🔊</span>
            <span>${this.lang === 'as' ? 'পুনৰ শুনক' : this.lang === 'hi' ? 'फिर से सुनें' : 'Listen'}</span>
          </button>
          
          <div class="text-center font-bold text-amber-900 text-lg">
            ${this.lang === 'as' ? 'ক্ৰম সজোৱা' : this.lang === 'hi' ? 'चित्र क्रम' : 'Sequence'}
          </div>

          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 rounded-xl font-bold transition active:scale-95">
            ✕
          </button>
        </div>

        <!-- Banner -->
        <div class="bg-white rounded-2xl p-4 shadow-sm border border-stone-200 mb-3 text-center">
          <h2 class="text-lg md:text-xl font-extrabold text-amber-900 mb-1">${seqTitle}</h2>
          <p class="text-base md:text-lg font-bold text-stone-700 leading-snug">
            ${promptText}
          </p>
          <p class="text-xs font-medium text-stone-500 italic mt-1">
            "${subtitle}"
          </p>
        </div>

        <!-- Placed Sequence Slots (Target Area) -->
        <div class="mb-4">
          <div class="text-xs font-bold text-stone-500 uppercase tracking-wider mb-2 text-center">
            ${this.lang === 'as' ? 'আপোনাৰ ক্ৰম (১, ২, ৩)' : this.lang === 'hi' ? 'आपका क्रम (1, 2, 3)' : 'Your Ordered Steps'}
          </div>
          <div class="grid grid-cols-3 gap-3">
            ${Array.from({ length: this.originalSteps.length }).map((_, idx) => {
              const placed = this.placedSteps[idx];
              if (placed) {
                return `
                  <button data-placed-idx="${idx}" class="min-h-[110px] md:min-h-[130px] bg-amber-50 border-2 border-amber-400 rounded-2xl p-2 flex flex-col items-center justify-between shadow-sm active:scale-95 transition">
                    <span class="w-6 h-6 rounded-full bg-amber-600 text-white font-bold text-xs flex items-center justify-center">${idx + 1}</span>
                    <div class="w-12 h-12 md:w-14 md:h-14">
                      ${ICONS[placed.iconKey] || ''}
                    </div>
                    <span class="text-xs font-bold text-stone-800 text-center leading-tight line-clamp-2">${placed.label[this.lang] || placed.label.en}</span>
                  </button>
                `;
              } else {
                return `
                  <div class="min-h-[110px] md:min-h-[130px] border-2 border-dashed border-stone-300 rounded-2xl p-2 flex flex-col items-center justify-center text-stone-400 bg-stone-50">
                    <span class="w-8 h-8 rounded-full bg-stone-200 text-stone-500 font-bold text-sm flex items-center justify-center mb-1">${idx + 1}</span>
                    <span class="text-xs font-semibold text-stone-400">${this.lang === 'as' ? 'খোজ ' + (idx + 1) : this.lang === 'hi' ? 'चरण ' + (idx + 1) : 'Step ' + (idx + 1)}</span>
                  </div>
                `;
              }
            }).join("")}
          </div>
        </div>

        <!-- Available Cards Pool -->
        <div class="flex-1 flex flex-col justify-end">
          <div class="text-xs font-bold text-stone-500 uppercase tracking-wider mb-2 text-center">
            ${this.lang === 'as' ? 'তলৰ ছবিবোৰ স্পৰ্শ কৰি ক্ৰমত ৰাখক' : this.lang === 'hi' ? 'चित्रों को छूकर क्रम में लगाएं' : 'Tap Cards to Place in Order'}
          </div>
          <div class="grid grid-cols-3 gap-3">
            ${this.pool.map((step) => `
              <button data-pool-step="${step.stepNumber}" class="min-h-[110px] md:min-h-[130px] bg-white hover:bg-amber-50 border-2 border-stone-200 hover:border-amber-300 rounded-2xl p-2 flex flex-col items-center justify-between shadow active:scale-95 transition">
                <div class="w-12 h-12 md:w-14 md:h-14 my-1">
                  ${ICONS[step.iconKey] || ''}
                </div>
                <span class="text-xs font-bold text-stone-800 text-center leading-tight line-clamp-2">${step.label[this.lang] || step.label.en}</span>
              </button>
            `).join("")}
          </div>
        </div>
      </div>
    `;

    // Event handlers
    this.container.querySelector("#btn-repeat-audio")?.addEventListener("click", () => this.playAudioInstruction());
    this.container.querySelector("#btn-exit-game")?.addEventListener("click", () => this.onExit());

    this.container.querySelectorAll("[data-pool-step]").forEach(btn => {
      btn.addEventListener("click", () => {
        const stepNum = parseInt(btn.getAttribute("data-pool-step"), 10);
        const step = this.pool.find(s => s.stepNumber === stepNum);
        if (step) this.handleSelectCardFromPool(step);
      });
    });

    this.container.querySelectorAll("[data-placed-idx]").forEach(btn => {
      btn.addEventListener("click", () => {
        const idx = parseInt(btn.getAttribute("data-placed-idx"), 10);
        this.handleRemoveCardFromSlot(idx);
      });
    });
  }
}