// SMRITI - Game 6: Orientation Activity (Gentle Orientation & General Cognitive Stimulation)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';

export class OrientationGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});

    this.questions = this.gameData.questions || [];
    this.questionIndex = options.questionIndex || 0;
    this.currentQuestion = this.questions[this.questionIndex % this.questions.length];
    this.startTime = Date.now();
    this.attempts = 0;
    this.hasAnswered = false;

    this.render();
    this.playAudioInstruction();
  }

  playAudioInstruction() {
    const prompt = this.currentQuestion.audioPrompt[this.lang] || this.currentQuestion.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleSelectOption(option) {
    if (this.hasAnswered) return;
    this.hasAnswered = true;
    audio.playPositiveChime();

    const duration = Date.now() - this.startTime;
    
    // Save record locally (Non-diagnostic, cognitive stimulation tracking only)
    const record = db.saveActivityResult({
      activityType: "orientation_game",
      activityTitle: `Orientation - ${this.currentQuestion.id}`,
      difficultyLevel: "Level 1 (Very Easy)",
      accuracy: 100,
      responseTimeMs: duration,
      attempts: 1,
      correctMatches: 1,
      incorrectMatches: 0,
      hintsUsed: 0,
      language: this.lang
    });

    audio.speak(
      this.lang === "as" ? "ধন্যবাদ! আপোনাৰ উত্তৰ অতি সুন্দৰ।" :
      this.lang === "hi" ? "धन्यवाद! बहुत सुंदर जवाब।" :
      "Thank you! Wonderful response.",
      this.lang
    );

    this.render();

    setTimeout(() => {
      if (this.questionIndex < this.questions.length - 1) {
        this.questionIndex++;
        this.currentQuestion = this.questions[this.questionIndex];
        this.hasAnswered = false;
        this.startTime = Date.now();
        this.render();
        this.playAudioInstruction();
      } else {
        this.onComplete(record);
      }
    }, 1200);
  }

  render() {
    const prompt = this.currentQuestion.prompt[this.lang] || this.currentQuestion.prompt.en;
    const subtitle = this.currentQuestion.subtitleEn;

    this.container.innerHTML = `
      <div class="p-4 flex flex-col flex-1 max-w-xl mx-auto w-full animate-fade-in">
        <!-- Top Navigation -->
        <div class="flex items-center justify-between mb-3 border-b border-stone-200 pb-2">
          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-base flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${this.lang === "as" ? "বাহিৰ হওক" : this.lang === "hi" ? "बाहर निकलें" : "Exit"}</span>
          </button>
          <div class="text-xs font-bold px-2.5 py-1 bg-amber-100 text-amber-900 rounded-full border border-amber-300">
            ${this.questionIndex + 1} / ${this.questions.length}
          </div>
        </div>

        <!-- Question Header Card -->
        <div class="bg-amber-50 border-2 border-amber-200 p-5 rounded-3xl mb-4 shadow-sm text-center">
          <div class="w-16 h-16 mx-auto mb-2 text-amber-700">
            ${ICONS.calendar}
          </div>
          <h2 class="text-2xl sm:text-3xl font-black text-amber-950 leading-tight">
            ${prompt}
          </h2>
          ${this.lang !== "en" ? `<p class="text-xs font-mono text-stone-500 mt-1 italic">${subtitle}</p>` : ""}
          <button id="btn-audio-prompt" class="mt-3 px-4 py-2 bg-amber-500 hover:bg-amber-600 text-white rounded-xl shadow-sm transition inline-flex items-center gap-2 text-sm font-bold">
            <span>🔊</span>
            <span>${this.lang === "as" ? "পুনৰ শুনক" : this.lang === "hi" ? "फिर से सुनें" : "Listen Again"}</span>
          </button>
        </div>

        <!-- Visual Option Choice Buttons -->
        <div class="space-y-3.5 my-auto py-2">
          ${this.currentQuestion.options.map((opt, idx) => {
            const optText = opt.text[this.lang] || opt.text.en;
            return `
              <button 
                data-option-index="${idx}"
                class="orientation-opt-btn w-full bg-white hover:bg-amber-100 active:bg-amber-200 border-3 border-stone-300 hover:border-amber-500 rounded-2xl p-4 flex items-center justify-between shadow-md transition text-left transform active:scale-98">
                <span class="text-lg sm:text-xl font-black text-stone-900 leading-snug">
                  ${optText}
                </span>
                <span class="w-9 h-9 rounded-full bg-amber-200 text-amber-900 font-bold flex items-center justify-center text-base shadow-inner">
                  ➔
                </span>
              </button>
            `;
          }).join("")}
        </div>

        <!-- Non-diagnostic gentle reassurance -->
        <div class="mt-4 p-3 bg-stone-100 rounded-xl text-center text-xs text-stone-500 border border-stone-200">
          ${this.lang === "as" ? "আপোনাৰ সুবিধা অনুসৰি লাহে লাহে উত্তৰ দিয়ক।" : this.lang === "hi" ? "अपनी सुविधा के अनुसार आराम से उत्तर दें।" : "Take your time. There are no right or wrong answers here."}
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

    const optBtns = this.container.querySelectorAll(".orientation-opt-btn");
    optBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const idx = parseInt(btn.dataset.optionIndex, 10);
        const opt = this.currentQuestion.options[idx];
        if (opt) this.handleSelectOption(opt);
      });
    });
  }
}
