// SMRITI - Game 5: Word & Picture Match (Semantic & Language Engagement)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';

export class WordPictureMatchGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});
    this.questionIndex = options.questionIndex || 0;

    this.questions = this.gameData.questions || [];
    this.currentQuestion = this.questions[this.questionIndex] || this.questions[0];
    this.startTime = Date.now();
    this.attempts = 0;
    this.selectedOptionId = null;
    this.isFinished = false;

    this.render();
    this.playAudioInstruction();
  }

  playAudioInstruction() {
    const prompt = this.currentQuestion.audioPrompt[this.lang] || this.currentQuestion.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleOptionClick(opt) {
    if (this.isFinished) return;
    this.attempts++;
    this.selectedOptionId = opt.id;

    if (opt.id === this.currentQuestion.correctOptionId) {
      this.isFinished = true;
      audio.playPositiveChime();
      const duration = Date.now() - this.startTime;

      const record = db.saveActivityResult({
        activityType: "word_picture_match",
        activityTitle: "Word & Picture Match",
        difficultyLevel: "gentle",
        accuracy: Math.max(70, 100 - (this.attempts - 1) * 20),
        responseTimeMs: duration,
        attempts: this.attempts,
        hintsUsed: 0,
        language: this.lang
      });

      this.render();

      const wellDone = this.lang === "as" ? "চমৎকার! আপুনি শুদ্ধ শব্দটো বাছিলে।" :
                       this.lang === "hi" ? "बहुत खूब! सही शब्द चुना।" :
                       "Excellent! That is the correct word.";
      audio.speak(wellDone, this.lang);

      setTimeout(() => {
        this.onComplete({
          record,
          durationMs: duration
        });
      }, 1600);
    } else {
      audio.playSoftTap();
      this.render();
      const tryAnother = this.lang === "as" ? "আন এটা শব্দ বাছি চাওক।" :
                          this.lang === "hi" ? "कोई अन्य विकल्प चुनकर देखें।" :
                          "Let's try another choice.";
      audio.speak(tryAnother, this.lang);
    }
  }

  pronounceWord(text) {
    audio.speak(text, this.lang);
  }

  render() {
    const q = this.currentQuestion;
    const promptText = q.audioPrompt[this.lang] || q.audioPrompt.en;
    const subtitle = q.subtitleEn;

    this.container.innerHTML = `
      <div class="flex flex-col h-full max-w-2xl mx-auto p-4 select-none">
        <!-- Top Bar -->
        <div class="flex items-center justify-between mb-3 bg-amber-50 rounded-2xl p-3 border border-amber-200">
          <button id="btn-repeat-audio" class="flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-xl font-bold shadow transition active:scale-95 text-lg">
            <span>🔊</span>
            <span>${this.lang === 'as' ? 'পুনৰ শুনক' : this.lang === 'hi' ? 'फिर से सुनें' : 'Listen'}</span>
          </button>
          
          <div class="text-center font-bold text-amber-900 text-lg">
            ${this.lang === 'as' ? 'শব্দ আৰু ছবি' : this.lang === 'hi' ? 'शब्द-चित्र' : 'Word Match'}
          </div>

          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 rounded-xl font-bold transition active:scale-95">
            ✕
          </button>
        </div>

        <!-- Focal Image -->
        <div class="bg-white rounded-3xl p-6 shadow-sm border border-stone-200 mb-4 flex flex-col items-center">
          <div class="w-36 h-36 md:w-44 md:h-44 mb-3 bg-amber-50 rounded-2xl p-4 border border-amber-100 flex items-center justify-center">
            ${ICONS[q.imageKey] || ''}
          </div>
          <h2 class="text-xl md:text-2xl font-extrabold text-stone-800 text-center mb-1">
            ${promptText}
          </h2>
          <p class="text-sm font-medium text-stone-500 italic text-center">
            "${subtitle}"
          </p>
        </div>

        <!-- Word Options Grid -->
        <div class="flex flex-col gap-3">
          ${q.options.map(opt => {
            const isCorrect = opt.id === q.correctOptionId;
            const isSelected = opt.id === this.selectedOptionId;
            const optText = opt.text[this.lang] || opt.text.en;

            let btnStyle = "bg-white border-stone-300 hover:bg-amber-50 hover:border-amber-400 text-stone-800";
            if (this.isFinished && isCorrect) {
              btnStyle = "bg-emerald-100 border-emerald-500 text-emerald-950 ring-4 ring-emerald-200 scale-102";
            } else if (isSelected && !isCorrect) {
              btnStyle = "bg-amber-100 border-amber-400 text-amber-900";
            }

            return `
              <div class="flex items-center gap-2">
                <button data-opt-id="${opt.id}" class="flex-1 min-h-[64px] p-4 rounded-2xl border-2 font-extrabold text-xl md:text-2xl shadow-sm transition active:scale-98 flex items-center justify-between ${btnStyle}">
                  <span>${optText}</span>
                  ${this.isFinished && isCorrect ? '<span class="text-emerald-700 text-2xl">✓</span>' : ''}
                </button>
                <button data-pronounce="${optText}" class="w-14 h-16 bg-amber-100 hover:bg-amber-200 rounded-2xl border border-amber-300 flex items-center justify-center text-xl active:scale-95 transition" title="Pronounce">
                  🔊
                </button>
              </div>
            `;
          }).join("")}
        </div>
      </div>
    `;

    // Event handlers
    this.container.querySelector("#btn-repeat-audio")?.addEventListener("click", () => this.playAudioInstruction());
    this.container.querySelector("#btn-exit-game")?.addEventListener("click", () => this.onExit());

    this.container.querySelectorAll("[data-opt-id]").forEach(btn => {
      btn.addEventListener("click", () => {
        const id = btn.getAttribute("data-opt-id");
        const opt = q.options.find(o => o.id === id);
        if (opt) this.handleOptionClick(opt);
      });
    });

    this.container.querySelectorAll("[data-pronounce]").forEach(btn => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const text = btn.getAttribute("data-pronounce");
        this.pronounceWord(text);
      });
    });
  }
}