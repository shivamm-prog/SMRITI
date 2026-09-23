// SMRITI - Game 4: Find the Object (Visual Attention & Scanning)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';

export class FindTheObjectGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});
    this.sceneIndex = options.sceneIndex || 0;

    this.scenes = this.gameData.scenes || [];
    this.currentScene = this.scenes[this.sceneIndex] || this.scenes[0];
    this.startTime = Date.now();
    this.attempts = 0;
    this.hintsUsed = 0;
    this.showHintPulse = false;
    this.isFound = false;

    this.render();
    this.playAudioInstruction();
  }

  playAudioInstruction() {
    const prompt = this.currentScene.audioPrompt[this.lang] || this.currentScene.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleItemClick(item) {
    if (this.isFound) return;
    this.attempts++;

    if (item.isTarget) {
      this.isFound = true;
      audio.playPositiveChime();
      const duration = Date.now() - this.startTime;

      const record = db.saveActivityResult({
        activityType: "find_the_object",
        activityTitle: `Find the Object - ${this.currentScene.targetName.en}`,
        difficultyLevel: "gentle",
        accuracy: Math.max(75, 100 - (this.attempts - 1) * 15),
        responseTimeMs: duration,
        attempts: this.attempts,
        hintsUsed: this.hintsUsed,
        language: this.lang
      });

      this.render();

      const wellDone = this.lang === "as" ? "অসীম সুন্দৰ! আপুনি বস্তুটো সঠিককৈ বিচাৰি পালে।" :
                       this.lang === "hi" ? "बहुत खूब! आपने सही वस्तु ढूँढ ली।" :
                       "Wonderful job! You found the object.";
      audio.speak(wellDone, this.lang);

      setTimeout(() => {
        this.onComplete({
          record,
          durationMs: duration
        });
      }, 1600);
    } else {
      audio.playSoftTap();
      const tryAgain = this.lang === "as" ? "আন এখন ছবি চাওক।" :
                       this.lang === "hi" ? "कृपया दोबारा ध्यान से देखें।" :
                       "Let's look around again.";
      audio.speak(tryAgain, this.lang);
    }
  }

  handleGiveHint() {
    this.hintsUsed++;
    this.showHintPulse = true;
    audio.playSoftTap();
    this.render();
  }

  render() {
    const targetName = this.currentScene.targetName[this.lang] || this.currentScene.targetName.en;
    const subtitle = this.currentScene.subtitleEn;

    this.container.innerHTML = `
      <div class="flex flex-col h-full max-w-2xl mx-auto p-4 select-none">
        <!-- Top Bar -->
        <div class="flex items-center justify-between mb-3 bg-amber-50 rounded-2xl p-3 border border-amber-200">
          <button id="btn-repeat-audio" class="flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-xl font-bold shadow transition active:scale-95 text-lg">
            <span>🔊</span>
            <span>${this.lang === 'as' ? 'পুনৰ শুনক' : this.lang === 'hi' ? 'फिर से सुनें' : 'Listen'}</span>
          </button>
          
          <button id="btn-hint" class="px-3 py-2 bg-amber-100 hover:bg-amber-200 text-amber-900 border border-amber-300 rounded-xl font-bold text-sm transition active:scale-95 flex items-center gap-1">
            <span>💡</span>
            <span>${this.lang === 'as' ? 'ইংগিত' : this.lang === 'hi' ? 'संकेत' : 'Hint'}</span>
          </button>

          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 rounded-xl font-bold transition active:scale-95">
            ✕
          </button>
        </div>

        <!-- Target Prompt Banner -->
        <div class="bg-white rounded-2xl p-4 shadow-sm border border-stone-200 mb-4 text-center">
          <div class="inline-block text-xs font-bold uppercase tracking-wider text-amber-800 bg-amber-100 px-3 py-1 rounded-full mb-1">
            ${this.lang === 'as' ? 'মনোযোগ আৰু সন্ধান' : this.lang === 'hi' ? 'खोजिए' : 'Visual Search'}
          </div>
          <h2 class="text-2xl md:text-3xl font-extrabold text-stone-800 mb-1">
            ${targetName}
          </h2>
          <p class="text-sm font-medium text-stone-500 italic">
            "${subtitle}"
          </p>
        </div>

        <!-- Visual Attention Scene Canvas/Grid -->
        <div class="flex-1 bg-gradient-to-b from-amber-50/60 to-orange-50/40 rounded-3xl p-6 border-2 border-amber-200 flex items-center justify-center relative min-h-[300px]">
          <div class="grid grid-cols-3 gap-6 w-full max-w-md items-center justify-items-center">
            ${this.currentScene.itemsInScene.map(item => {
              const isTargetItem = item.isTarget;
              const shouldHighlight = isTargetItem && (this.showHintPulse || this.isFound);

              return `
                <button data-item-key="${item.key}" class="w-24 h-24 md:w-28 md:h-28 bg-white rounded-3xl p-3 shadow-md border-2 ${
                  this.isFound && isTargetItem
                    ? 'border-emerald-500 ring-4 ring-emerald-300 bg-emerald-50 scale-110'
                    : shouldHighlight
                    ? 'border-amber-500 animate-bounce ring-4 ring-amber-300 bg-amber-50'
                    : 'border-stone-200 hover:border-amber-300 hover:bg-amber-50'
                } transition-all duration-200 active:scale-95 flex flex-col items-center justify-center">
                  <div class="w-14 h-14 md:w-16 md:h-16">
                    ${ICONS[item.key] || ''}
                  </div>
                  <span class="text-[11px] font-bold text-stone-700 mt-1">${item.label[this.lang] || item.label.en}</span>
                </button>
              `;
            }).join("")}
          </div>
        </div>

        <!-- Bottom Guidance -->
        <div class="text-center py-3 text-stone-600 font-medium text-base">
          ${this.lang === 'as' ? 'বস্তুটো দেখা পালে স্পৰ্শ কৰক' : this.lang === 'hi' ? 'दिखाई देने पर वस्तु को छुएं' : 'Tap on the item when you spot it'}
        </div>
      </div>
    `;

    // Event handlers
    this.container.querySelector("#btn-repeat-audio")?.addEventListener("click", () => this.playAudioInstruction());
    this.container.querySelector("#btn-hint")?.addEventListener("click", () => this.handleGiveHint());
    this.container.querySelector("#btn-exit-game")?.addEventListener("click", () => this.onExit());

    this.container.querySelectorAll("[data-item-key]").forEach(btn => {
      btn.addEventListener("click", () => {
        const key = btn.getAttribute("data-item-key");
        const item = this.currentScene.itemsInScene.find(i => i.key === key);
        if (item) this.handleItemClick(item);
      });
    });
  }
}