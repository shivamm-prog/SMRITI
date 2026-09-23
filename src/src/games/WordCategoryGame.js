// SMRITI - Game 4: Word & Category Game (Language & Semantic Memory Stimulation)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';

export class WordCategoryGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});

    // Adaptive category index
    const adaptive = PersonalizationEngine.getAdaptiveLevel("pat_anita_001", "word_category_game");
    this.catIndex = options.catIndex !== undefined ? options.catIndex : ((adaptive.level - 1) % this.gameData.categories.length);
    this.currentCat = this.gameData.categories[this.catIndex] || this.gameData.categories[0];

    this.selectedItemIds = new Set();
    this.startTime = Date.now();
    this.attempts = 0;
    this.hasCompleted = false;

    this.render();
    this.playAudioInstruction();
  }

  playAudioInstruction() {
    const prompt = this.currentCat.audioPrompt[this.lang] || this.currentCat.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleToggleCategoryItem(item) {
    if (this.hasCompleted) return;
    audio.playSoftTap();

    if (this.selectedItemIds.has(item.id)) {
      this.selectedItemIds.delete(item.id);
    } else {
      this.selectedItemIds.add(item.id);
    }
    this.render();
  }

  handleSelectWordGenOption(option) {
    if (this.hasCompleted) return;
    this.attempts++;

    if (option.isCorrect) {
      this.hasCompleted = true;
      audio.playPositiveChime();
      const duration = Date.now() - this.startTime;

      const record = db.saveActivityResult({
        activityType: "word_category_game",
        activityTitle: `Word Association - ${this.currentCat.promptText.en}`,
        difficultyLevel: `Level ${this.catIndex + 1}`,
        accuracy: 100,
        responseTimeMs: duration,
        attempts: this.attempts,
        correctMatches: 1,
        incorrectMatches: this.attempts - 1,
        hintsUsed: 0,
        language: this.lang
      });

      audio.speak(
        this.lang === "as" ? "অতি সুন্দৰ! আপুনি সঠিক শব্দটো বাছি ল’লে।" :
        this.lang === "hi" ? "बहुत सुंदर! आपने सही शब्द चुना।" :
        "Wonderful! You picked the correct word.",
        this.lang
      );

      setTimeout(() => {
        this.onComplete(record);
      }, 1000);
    } else {
      // Gentle encouragement
      audio.speak(
        this.lang === "as" ? "আহক আকৌ এবাৰ চেষ্টা কৰোঁ। লাহে লাহে বাছক।" :
        this.lang === "hi" ? "आइए एक बार फिर कोशिश करते हैं। आराम से चुनें।" :
        "Let’s try one more time. Take your time.",
        this.lang
      );
      this.render(true);
    }
  }

  handleCheckCategorySelection() {
    if (this.hasCompleted) return;
    this.attempts++;

    const correctItems = this.currentCat.items.filter(i => i.isBelonging);
    let correctCount = 0;
    let incorrectCount = 0;

    this.selectedItemIds.forEach(id => {
      const item = this.currentCat.items.find(i => i.id === id);
      if (item && item.isBelonging) {
        correctCount++;
      } else {
        incorrectCount++;
      }
    });

    const isAllCorrect = (correctCount === correctItems.length) && (incorrectCount === 0);

    if (isAllCorrect) {
      this.hasCompleted = true;
      audio.playPositiveChime();
      const duration = Date.now() - this.startTime;
      const accuracy = this.attempts === 1 ? 100 : Math.max(65, 100 - (this.attempts - 1) * 15);

      const record = db.saveActivityResult({
        activityType: "word_category_game",
        activityTitle: `Category Selection - ${this.currentCat.categoryName.en}`,
        difficultyLevel: `Level ${this.catIndex + 1}`,
        accuracy: accuracy,
        responseTimeMs: duration,
        attempts: this.attempts,
        correctMatches: correctCount,
        incorrectMatches: incorrectCount,
        hintsUsed: 0,
        language: this.lang
      });

      audio.speak(
        this.lang === "as" ? "অতি উত্তম! আপুনি এই শ্ৰেণীৰ সকলো বস্তু সঠিকভাৱে চিনাক্ত কৰিলে।" :
        this.lang === "hi" ? "बहुत ही उत्तम! आपने इस श्रेणी की सभी वस्तुओं को सही पहचाना।" :
        "Excellent! You identified all items in this category.",
        this.lang
      );

      setTimeout(() => {
        this.onComplete(record);
      }, 1000);
    } else {
      // Gentle encouragement
      audio.speak(
        this.lang === "as" ? "আহক আকৌ এবাৰ চাওঁ। এই শ্ৰেণীৰ সকলো বস্তু চিনাক্ত কৰক।" :
        this.lang === "hi" ? "आइए एक बार फिर देखते हैं। केवल सही वस्तुओं को चुनें।" :
        "Let’s try once more. Select the items that belong to the category.",
        this.lang
      );
      this.render(true);
    }
  }

  render(showHint = false) {
    const isWordGen = this.currentCat.type === "word_generation";
    const prompt = isWordGen 
      ? (this.currentCat.promptText[this.lang] || this.currentCat.promptText.en)
      : (this.currentCat.audioPrompt[this.lang] || this.currentCat.audioPrompt.en);
    const subtitle = this.currentCat.subtitleEn;

    this.container.innerHTML = `
      <div class="p-4 flex flex-col flex-1 max-w-xl mx-auto w-full animate-fade-in">
        <!-- Top Navigation -->
        <div class="flex items-center justify-between mb-3 border-b border-stone-200 pb-2">
          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-base flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${this.lang === "as" ? "বাহিৰ হওক" : this.lang === "hi" ? "बाहर निकलें" : "Exit"}</span>
          </button>
          <div class="text-xs font-bold px-2.5 py-1 bg-amber-100 text-amber-900 rounded-full border border-amber-300">
            ${isWordGen ? "Word Task" : "Category Task"}
          </div>
        </div>

        <!-- Activity Header -->
        <div class="bg-amber-50 border-2 border-amber-200 p-4 rounded-2xl mb-4 shadow-sm">
          <div class="flex items-start justify-between gap-3">
            <div>
              ${!isWordGen ? `
                <div class="inline-block px-3 py-1 bg-amber-600 text-white rounded-lg text-sm font-black tracking-wider uppercase mb-1.5 shadow-sm">
                  ${this.currentCat.categoryName[this.lang] || this.currentCat.categoryName.en}
                </div>
              ` : ""}
              <h2 class="text-xl sm:text-2xl font-black text-amber-950">${prompt}</h2>
              ${this.lang !== "en" ? `<p class="text-xs font-mono text-stone-500 mt-0.5 italic">${subtitle}</p>` : ""}
            </div>
            <button id="btn-audio-prompt" class="p-3 bg-amber-500 hover:bg-amber-600 text-white rounded-2xl shadow-md transition flex-shrink-0">
              <span class="text-2xl">🔊</span>
            </button>
          </div>
          ${showHint ? `
            <div class="mt-2 p-2 bg-amber-200 border border-amber-300 text-amber-950 rounded-xl text-sm font-bold flex items-center gap-2">
              <span>🌸</span>
              <span>${this.lang === "as" ? "আহক আকৌ এবাৰ চেষ্টা কৰোঁ। লাহে লাহে বাছক!" : this.lang === "hi" ? "आइए एक बार फिर कोशिश करते हैं। आराम से चुनें!" : "Let’s try once more. Take your time!"}</span>
            </div>
          ` : ""}
        </div>

        ${!isWordGen ? `
          <!-- Category Grid Selection -->
          <div class="grid grid-cols-2 sm:grid-cols-3 gap-3.5 my-auto py-2">
            ${this.currentCat.items.map(item => {
              const isSelected = this.selectedItemIds.has(item.id);
              const label = item.name[this.lang] || item.name.en;
              return `
                <button 
                  data-item-id="${item.id}"
                  class="cat-item-btn aspect-square rounded-2xl p-3 flex flex-col items-center justify-center transition-all duration-200 shadow-md transform active:scale-95 relative
                  ${isSelected 
                    ? "bg-amber-100 border-4 border-amber-600 ring-2 ring-amber-400 shadow-xl" 
                    : "bg-white border-2 border-stone-300 hover:border-amber-400"}">
                  <div class="w-14 h-14 sm:w-16 sm:h-16 mb-1 pointer-events-none">
                    ${ICONS[item.iconKey] || `<span class="text-3xl">📦</span>`}
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

          <!-- Submit Button -->
          <div class="mt-4">
            <button 
              id="btn-check-category" 
              class="w-full py-4 ${this.selectedItemIds.size > 0 ? "bg-emerald-600 hover:bg-emerald-700 text-white shadow-lg" : "bg-stone-300 text-stone-500 cursor-not-allowed"} text-xl font-black rounded-2xl transition flex items-center justify-center gap-2"
              ${this.selectedItemIds.size === 0 ? "disabled" : ""}>
              <span>${this.lang === "as" ? "বাছনি সম্পূৰ্ণ কৰক" : this.lang === "hi" ? "चयन की पुष्टि करें" : "Confirm Selection"} (${this.selectedItemIds.size})</span>
            </button>
          </div>
        ` : `
          <!-- Word Generation Choice Buttons -->
          <div class="my-auto space-y-3.5 py-3">
            ${this.currentCat.options.map(opt => {
              const text = opt.text[this.lang] || opt.text.en;
              return `
                <button 
                  data-option-id="${opt.id}"
                  class="word-opt-btn w-full bg-white hover:bg-amber-50 active:bg-amber-100 border-3 border-stone-300 hover:border-amber-500 rounded-2xl p-4 flex items-center gap-4 shadow-md transition text-left transform active:scale-98">
                  <div class="w-14 h-14 flex-shrink-0">
                    ${ICONS[opt.iconKey] || `<span class="text-3xl">🔤</span>`}
                  </div>
                  <span class="text-xl font-black text-stone-900 leading-snug flex-1">
                    ${text}
                  </span>
                  <span class="text-2xl text-amber-600 font-black">➔</span>
                </button>
              `;
            }).join("")}
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

    const catItemBtns = this.container.querySelectorAll(".cat-item-btn");
    catItemBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const itemId = btn.dataset.itemId;
        const item = this.currentCat.items.find(i => i.id === itemId);
        if (item) this.handleToggleCategoryItem(item);
      });
    });

    const checkCatBtn = this.container.querySelector("#btn-check-category");
    if (checkCatBtn) checkCatBtn.addEventListener("click", () => this.handleCheckCategorySelection());

    const wordOptBtns = this.container.querySelectorAll(".word-opt-btn");
    wordOptBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const optId = btn.dataset.optionId;
        const opt = this.currentCat.options.find(o => o.id === optId);
        if (opt) this.handleSelectWordGenOption(opt);
      });
    });
  }
}
