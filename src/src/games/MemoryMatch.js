// SMRITI - Game 1: Memory Match (Offline-First Cognitive Stimulation)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';

export class MemoryMatchGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});
    
    // Adaptive difficulty
    const adaptive = PersonalizationEngine.getAdaptiveLevel("pat_anita_001", "memory_match");
    this.levelIndex = options.levelIndex !== undefined ? options.levelIndex : (adaptive.level - 1);
    this.currentLevel = this.gameData.levels[this.levelIndex] || this.gameData.levels[0];
    
    this.cards = [];
    this.flippedIndices = [];
    this.matchedPairs = [];
    this.startTime = Date.now();
    this.attempts = 0;
    this.correctMatches = 0;
    this.incorrectMatches = 0;
    this.isLocked = false;
    this.isPreviewing = true;

    this.initCards();
    this.render();
    this.playAudioInstruction();

    // Brief initial preview: show cards for 2.5s then hide so patient can memorize
    setTimeout(() => {
      this.isPreviewing = false;
      this.cards.forEach(c => c.isFlipped = false);
      this.render();
    }, 2400);
  }

  initCards() {
    const pairs = [...this.currentLevel.pairs];
    const labels = { ...this.currentLevel.labels };

    const deck = [];
    pairs.forEach((pairKey, pairId) => {
      deck.push({ 
        id: `c_${pairKey}_1`, 
        pairKey, 
        pairId, 
        isFlipped: true, // Initially flipped during preview
        isMatched: false, 
        label: labels[pairKey] || { en: pairKey, hi: pairKey, as: pairKey }
      });
      deck.push({ 
        id: `c_${pairKey}_2`, 
        pairKey, 
        pairId, 
        isFlipped: true, 
        isMatched: false, 
        label: labels[pairKey] || { en: pairKey, hi: pairKey, as: pairKey }
      });
    });

    // Shuffle deck
    this.cards = deck.sort(() => Math.random() - 0.5);
  }

  playAudioInstruction() {
    const prompt = this.gameData.audioPrompt[this.lang] || this.gameData.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleCardClick(index) {
    if (this.isLocked || this.isPreviewing) return;
    const card = this.cards[index];
    if (card.isFlipped || card.isMatched) return;

    audio.playSoftTap();
    card.isFlipped = true;
    this.flippedIndices.push(index);
    this.render();

    if (this.flippedIndices.length === 2) {
      this.attempts++;
      const [idx1, idx2] = this.flippedIndices;
      const card1 = this.cards[idx1];
      const card2 = this.cards[idx2];

      if (card1.pairKey === card2.pairKey) {
        // Matched!
        card1.isMatched = true;
        card2.isMatched = true;
        this.matchedPairs.push(card1.pairKey);
        this.correctMatches++;
        this.flippedIndices = [];
        audio.playPositiveChime();

        const uniquePairsCount = this.cards.length / 2;
        if (this.matchedPairs.length === uniquePairsCount) {
          const duration = Date.now() - this.startTime;
          this.handleFinish(duration);
        } else {
          this.render();
        }
      } else {
        // Not matched - gentle encouragement
        this.incorrectMatches++;
        this.isLocked = true;
        setTimeout(() => {
          card1.isFlipped = false;
          card2.isFlipped = false;
          this.flippedIndices = [];
          this.isLocked = false;
          this.render();
        }, 1100);
      }
    }
  }

  handleFinish(durationMs) {
    const accuracy = Math.max(50, Math.min(100, Math.round((this.correctMatches / (this.attempts || 1)) * 100)));
    
    // Save result locally (Offline-First)
    const record = db.saveActivityResult({
      activityType: "memory_match",
      activityTitle: `Memory Match (${this.currentLevel.name})`,
      difficultyLevel: this.currentLevel.name,
      accuracy: accuracy,
      responseTimeMs: durationMs,
      attempts: this.attempts,
      correctMatches: this.correctMatches,
      incorrectMatches: this.incorrectMatches,
      hintsUsed: 0,
      language: this.lang
    });

    audio.speak(
      this.lang === "as" ? "অসম্ভৱ সুন্দৰ প্ৰয়াস! আপুনি সকলো ছবি মিলাই দিলে।" :
      this.lang === "hi" ? "बहुत सुंदर प्रयास! आपने सभी जोड़े मिला दिए।" :
      "Wonderful effort! You matched all the pairs.",
      this.lang
    );

    this.onComplete(record);
  }

  render() {
    const title = this.gameData.title[this.lang] || this.gameData.title.en;
    const prompt = this.gameData.audioPrompt[this.lang] || this.gameData.audioPrompt.en;
    const subtitle = this.gameData.subtitleEn;

    this.container.innerHTML = `
      <div class="p-4 flex flex-col flex-1 max-w-xl mx-auto w-full animate-fade-in">
        <!-- Top Bar Navigation -->
        <div class="flex items-center justify-between mb-3 border-b border-stone-200 pb-2">
          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-base flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${this.lang === "as" ? "বাহিৰ হওক" : this.lang === "hi" ? "बाहर निकलें" : "Exit"}</span>
          </button>
          <div class="text-right">
            <span class="text-xs font-bold px-2.5 py-1 bg-amber-100 text-amber-900 rounded-full border border-amber-300">
              ${this.currentLevel.name}
            </span>
          </div>
        </div>

        <!-- Activity Title & Instructions -->
        <div class="bg-amber-50 border-2 border-amber-200 p-4 rounded-2xl mb-4 shadow-sm">
          <div class="flex items-start justify-between gap-3">
            <div>
              <h2 class="text-2xl font-black text-amber-950">${title}</h2>
              <p class="text-lg font-bold text-stone-800 mt-1 leading-snug">${prompt}</p>
              ${this.lang !== "en" ? `<p class="text-xs font-mono text-stone-500 mt-0.5 italic">${subtitle}</p>` : ""}
            </div>
            <button id="btn-audio-prompt" class="p-3 bg-amber-500 hover:bg-amber-600 text-white rounded-2xl shadow-md transition transform active:scale-95 flex-shrink-0" title="Listen Again">
              <span class="text-2xl">🔊</span>
            </button>
          </div>
          ${this.isPreviewing ? `
            <div class="mt-2 py-1 px-3 bg-amber-200 text-amber-900 rounded-lg text-sm font-bold text-center animate-pulse">
              ${this.lang === "as" ? "👀 ছবিবোৰ চাই মনত ৰাখক..." : this.lang === "hi" ? "👀 चित्रों को देखकर याद रखें..." : "👀 Memorize the pictures..."}
            </div>
          ` : ""}
        </div>

        <!-- Cards Grid -->
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3.5 my-auto py-2">
          ${this.cards.map((card, idx) => {
            const isFlippedOrMatched = card.isFlipped || card.isMatched;
            const labelText = card.label[this.lang] || card.label.en;
            return `
              <button 
                data-card-index="${idx}"
                class="card-btn aspect-square rounded-2xl p-2.5 flex flex-col items-center justify-center transition-all duration-300 shadow-md transform active:scale-95
                ${card.isMatched 
                  ? "bg-emerald-100 border-4 border-emerald-500 opacity-95 scale-[0.98]" 
                  : isFlippedOrMatched 
                    ? "bg-amber-100 border-4 border-amber-500 shadow-lg" 
                    : "bg-white border-4 border-stone-300 hover:border-amber-400"}">
                ${isFlippedOrMatched ? `
                  <div class="w-14 h-14 sm:w-16 sm:h-16 mb-1 pointer-events-none">
                    ${ICONS[card.pairKey] || `<span class="text-3xl">🪔</span>`}
                  </div>
                  <span class="text-xs sm:text-sm font-bold text-stone-900 text-center leading-tight line-clamp-1 pointer-events-none">
                    ${labelText}
                  </span>
                ` : `
                  <div class="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center border-2 border-dashed border-amber-300 pointer-events-none">
                    <span class="text-2xl text-amber-700">❓</span>
                  </div>
                  <span class="text-xs font-bold text-stone-400 mt-1 pointer-events-none">
                    ${this.lang === "as" ? "চাওক" : this.lang === "hi" ? "खोलें" : "Tap"}
                  </span>
                `}
              </button>
            `;
          }).join("")}
        </div>

        <!-- Status & Reassurance Bar -->
        <div class="mt-4 bg-stone-100 p-3 rounded-xl flex items-center justify-between text-stone-700 text-sm font-bold border border-stone-200">
          <span>${this.lang === "as" ? "চেষ্টা" : this.lang === "hi" ? "प्रयास" : "Attempts"}: <strong class="text-amber-800 text-base">${this.attempts}</strong></span>
          <span>${this.lang === "as" ? "মিলা জোৰা" : this.lang === "hi" ? "मिले जोड़े" : "Matched"}: <strong class="text-emerald-700 text-base">${this.matchedPairs.length} / ${this.cards.length / 2}</strong></span>
          <span class="text-xs text-stone-500 font-medium">${this.lang === "as" ? "শান্তভাৱে খেলক" : this.lang === "hi" ? "आराम से खेलें" : "Unlimited tries"}</span>
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

    const cardButtons = this.container.querySelectorAll(".card-btn");
    cardButtons.forEach(btn => {
      btn.addEventListener("click", () => {
        const idx = parseInt(btn.dataset.cardIndex, 10);
        this.handleCardClick(idx);
      });
    });
  }
}