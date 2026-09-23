// SMRITI - Game 6: Category Game (Semantic Categorization & Language Association)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';

export class CategoryGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});
    this.catIndex = options.catIndex || 0;

    this.categories = this.gameData.categories || [];
    this.currentCat = this.categories[this.catIndex] || this.categories[0];
    this.selectedItemIds = new Set();
    this.startTime = Date.now();
    this.isCompleted = false;

    this.render();
    this.playAudioInstruction();
  }

  playAudioInstruction() {
    const prompt = this.currentCat.audioPrompt[this.lang] || this.currentCat.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleToggleItem(item) {
    if (this.isCompleted) return;
    audio.playSoftTap();

    if (this.selectedItemIds.has(item.id)) {
      this.selectedItemIds.delete(item.id);
    } else {
      this.selectedItemIds.add(item.id);
    }

    this.checkCompletion();
    this.render();
  }

  checkCompletion() {
    const belongingItems = this.currentCat.items.filter(i => i.isBelonging);
    const nonBelongingItems = this.currentCat.items.filter(i => !i.isBelonging);

    const allBelongingSelected = belongingItems.every(i => this.selectedItemIds.has(i.id));
    const noNonBelongingSelected = !nonBelongingItems.some(i => this.selectedItemIds.has(i.id));

    if (allBelongingSelected && noNonBelongingSelected) {
      this.isCompleted = true;
      audio.playPositiveChime();
      const duration = Date.now() - this.startTime;

      const record = db.saveActivityResult({
        activityType: "category_game",
        activityTitle: `Category Game - ${this.currentCat.categoryName.en}`,
        difficultyLevel: "gentle",
        accuracy: 100,
        responseTimeMs: duration,
        attempts: 1,
        hintsUsed: 0,
        language: this.lang
      });

      const wellDone = this.lang === "as" ? "চমৎকার! আপুনি শ্ৰেণীটোৰ সকলো বস্তু সঠিককৈ বাছিলে।" :
                       this.lang === "hi" ? "अति उत्तम! आपने श्रेणी की सभी वस्तुएं सही चुनीं।" :
                       "Wonderful! You identified all the matching items in the category.";
      audio.speak(wellDone, this.lang);

      setTimeout(() => {
        this.onComplete({
          record,
          durationMs: duration
        });
      }, 1600);
    }
  }

  render() {
    const catTitle = this.currentCat.categoryName[this.lang] || this.currentCat.categoryName.en;
    const promptText = this.currentCat.audioPrompt[this.lang] || this.currentCat.audioPrompt.en;
    const subtitle = this.currentCat.subtitleEn;

    this.container.innerHTML = `
      <div class="flex flex-col h-full max-w-2xl mx-auto p-4 select-none">
        <!-- Top Bar -->
        <div class="flex items-center justify-between mb-3 bg-amber-50 rounded-2xl p-3 border border-amber-200">
          <button id="btn-repeat-audio" class="flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-xl font-bold shadow transition active:scale-95 text-lg">
            <span>🔊</span>
            <span>${this.lang === 'as' ? 'পুনৰ শুনক' : this.lang === 'hi' ? 'फिर से सुनें' : 'Listen'}</span>
          </button>
          
          <div class="text-center font-bold text-amber-900 text-lg">
            ${this.lang === 'as' ? 'শ্ৰেণী অনুসৰি ভাগ' : this.lang === 'hi' ? 'श्रेणी खेल' : 'Category'}
          </div>

          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 rounded-xl font-bold transition active:scale-95">
            ✕
          </button>
        </div>

        <!-- Category Banner -->
        <div class="bg-white rounded-2xl p-4 shadow-sm border border-stone-200 mb-4 text-center">
          <div class="inline-block text-xs font-bold uppercase tracking-wider text-amber-800 bg-amber-100 px-3 py-1 rounded-full mb-1">
            ${this.lang === 'as' ? 'বাছনি কৰক' : this.lang === 'hi' ? 'चुनें' : 'Select'}
          </div>
          <h2 class="text-2xl md:text-3xl font-extrabold text-stone-800 mb-1">
            ${catTitle}
          </h2>
          <p class="text-base font-bold text-stone-700 leading-snug">
            ${promptText}
          </p>
          <p class="text-xs font-medium text-stone-500 italic mt-1">
            "${subtitle}"
          </p>
        </div>

        <!-- Items Grid -->
        <div class="flex-1 flex items-center justify-center">
          <div class="grid grid-cols-2 md:grid-cols-3 gap-4 w-full justify-items-center">
            ${this.currentCat.items.map(item => {
              const isSelected = this.selectedItemIds.has(item.id);
              const itemName = item.name[this.lang] || item.name.en;

              return `
                <button data-item-id="${item.id}" class="w-32 h-36 md:w-36 md:h-40 rounded-3xl p-3 flex flex-col items-center justify-between transition-all duration-200 active:scale-95 shadow-md border-3 ${
                  isSelected
                    ? 'bg-amber-100 border-amber-500 ring-4 ring-amber-200 scale-102'
                    : 'bg-white border-stone-200 hover:border-amber-300 hover:bg-amber-50'
                }">
                  <div class="w-16 h-16 md:w-20 md:h-20 my-auto">
                    ${ICONS[item.iconKey] || ''}
                  </div>
                  <div class="w-full flex items-center justify-between pt-1 border-t border-stone-100">
                    <span class="text-sm font-bold text-stone-800 truncate">${itemName}</span>
                    <span class="w-6 h-6 rounded-full border-2 flex items-center justify-center text-xs font-bold ${
                      isSelected ? 'bg-amber-600 border-amber-600 text-white' : 'border-stone-300 text-transparent'
                    }">✓</span>
                  </div>
                </button>
              `;
            }).join("")}
          </div>
        </div>

        <!-- Hint Footer -->
        <div class="text-center py-2 text-stone-600 font-medium text-base">
          ${this.lang === 'as' ? 'সকলো মিল থকা ছবি স্পৰ্শ কৰক' : this.lang === 'hi' ? 'सभी संबंधित चित्रों को चुनें' : 'Tap on all items that match the category'}
        </div>
      </div>
    `;

    // Event handlers
    this.container.querySelector("#btn-repeat-audio")?.addEventListener("click", () => this.playAudioInstruction());
    this.container.querySelector("#btn-exit-game")?.addEventListener("click", () => this.onExit());

    this.container.querySelectorAll("[data-item-id]").forEach(btn => {
      btn.addEventListener("click", () => {
        const id = btn.getAttribute("data-item-id");
        const item = this.currentCat.items.find(i => i.id === id);
        if (item) this.handleToggleItem(item);
      });
    });
  }
}