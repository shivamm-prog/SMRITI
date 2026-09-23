// SMRITI - Game 2: Remember & Recall (Updated with Voice Answering & Dynamic Caregiver Memory Integration)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';

export class RememberRecallGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});
    this.questionIndex = options.questionIndex || 0;

    this.initQuestions();
    this.currentQuestion = this.questions[this.questionIndex % this.questions.length];
    this.startTime = Date.now();
    this.hasAnswered = false;
    this.isListeningVoice = false;
    this.spokenAnswerText = "";

    this.render();
    this.playAudioInstruction();
  }

  initQuestions() {
    const baseQuestions = this.gameData.questions || [];
    const personalMemories = db.getMemories();

    // Map personal memories into playable Remember & Recall activities
    const dynamicFromMemories = personalMemories.map((m, idx) => ({
      id: `dynamic_rr_${m.id}`,
      imageKey: m.iconKey,
      titleEn: m.title.en,
      prompt: {
        en: `Do you remember this special memory: ${m.title.en}?`,
        hi: `क्या आपको यह विशेष याद है: ${m.title.hi}?`,
        as: `আপোনাৰ এই বিশেষ স্মৃতিটো মনত আছেনে: ${m.title.as}?`
      },
      audioPrompt: {
        en: `Do you remember this special memory: ${m.title.en}?`,
        hi: `क्या आपको यह विशेष याद है: ${m.title.hi}?`,
        as: `আপোনাৰ এই বিশেষ স্মৃতিটো মনত আছেনে: ${m.title.as}?`
      },
      subtitleEn: `Do you remember this special memory: ${m.title.en}?`,
      options: [
        { id: "opt_yes", text: { en: "YES (I remember)", hi: "हाँ (मुझे याद है)", as: "হয় (মনত আছে)" }, isCorrect: true },
        { id: "opt_no", text: { en: "NO (Tell me more)", hi: "नहीं (और बताएं)", as: "মনত নাই (আৰু কওক)" }, isCorrect: true }
      ],
      reminiscenceStory: m.caption
    }));

    this.questions = [...baseQuestions, ...dynamicFromMemories];
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

    const record = db.saveActivityResult({
      activityType: "remember_recall",
      activityTitle: `Remember & Recall - ${this.currentQuestion.titleEn}`,
      difficultyLevel: "gentle",
      accuracy: 100,
      responseTimeMs: duration,
      attempts: 1,
      hintsUsed: 0,
      language: this.lang
    });

    this.render();

    const story = this.currentQuestion.reminiscenceStory[this.lang] || this.currentQuestion.reminiscenceStory.en;
    audio.speak(story, this.lang);
  }

  handleVoiceInput() {
    this.isListeningVoice = true;
    this.render();

    const listeningPrompt = this.lang === "as" ? "অনুগ্ৰহ কৰি কওক, মই শুনি আছোঁ..." :
                           this.lang === "hi" ? "कृपया बोलें, मैं सुन रहा हूँ..." :
                           "Please speak, I am listening...";
    audio.speak(listeningPrompt, this.lang);

    // Simulated speech capture with gentle timeout
    setTimeout(() => {
      this.isListeningVoice = false;
      this.spokenAnswerText = this.lang === "as" ? "‘মই ভালদৰে মনত পেলাইছোঁ’" :
                              this.lang === "hi" ? "‘मुझे बहुत अच्छे से याद है’" :
                              "‘I remember this cherished moment clearly’";
      this.handleSelectOption({ id: "voice_answer", isCorrect: true });
    }, 2800);
  }

  render() {
    const q = this.currentQuestion;
    const promptText = q.prompt[this.lang] || q.prompt.en;
    const subtitle = q.subtitleEn;
    const story = q.reminiscenceStory[this.lang] || q.reminiscenceStory.en;

    this.container.innerHTML = `
      <div class="flex flex-col h-full max-w-2xl mx-auto p-4 select-none">
        <!-- Top Bar -->
        <div class="flex items-center justify-between mb-3 bg-amber-50 rounded-2xl p-3 border border-amber-200">
          <button id="btn-repeat-audio" class="flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-xl font-bold shadow transition active:scale-95 text-lg">
            <span>🔊</span>
            <span>${this.lang === 'as' ? 'পুনৰ শুনক' : this.lang === 'hi' ? 'फिर से सुनें' : 'Listen'}</span>
          </button>
          
          <div class="text-center font-bold text-amber-900 text-lg">
            ${this.lang === 'as' ? 'স্মৰণ আৰু চিনাকি' : this.lang === 'hi' ? 'संस्मरण' : 'Reminiscence'}
          </div>

          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 rounded-xl font-bold transition active:scale-95">
            ✕
          </button>
        </div>

        <!-- Focal Reminiscence Image -->
        <div class="bg-white rounded-3xl p-6 shadow-sm border border-stone-200 mb-4 flex flex-col items-center">
          <div class="w-36 h-36 md:w-44 md:h-44 mb-3 bg-amber-50 rounded-2xl p-3 border border-amber-100 flex items-center justify-center">
            ${ICONS[q.imageKey] || ''}
          </div>
          <div class="text-xs uppercase tracking-wider font-bold text-amber-800 bg-amber-100 px-3 py-1 rounded-full mb-2">
            ${q.titleEn}
          </div>
          <h2 class="text-xl md:text-2xl font-bold text-stone-800 text-center leading-snug">
            ${promptText}
          </h2>
          <p class="text-sm font-medium text-stone-500 italic mt-1 text-center">
            "${subtitle}"
          </p>
        </div>

        <!-- Answering Interface -->
        ${!this.hasAnswered ? `
          <div class="flex flex-col gap-3">
            <!-- Voice Answer Button -->
            <button id="btn-voice-answer" class="w-full min-h-[58px] p-3.5 bg-gradient-to-r from-emerald-600 to-teal-700 hover:from-emerald-700 hover:to-teal-800 text-white rounded-2xl font-extrabold text-lg shadow transition active:scale-98 flex items-center justify-center gap-3 ${this.isListeningVoice ? 'animate-pulse ring-4 ring-emerald-300' : ''}">
              <span class="text-2xl">🎙️</span>
              <span>${this.isListeningVoice ? (this.lang === 'as' ? 'শুনো আছোঁ...' : this.lang === 'hi' ? 'सुन रहा हूँ...' : 'Listening...') : (this.lang === 'as' ? 'কথাৰে উত্তৰ দিয়ক (Voice)' : this.lang === 'hi' ? 'बोलकर उत्तर दें (Voice)' : 'Speak My Answer (Voice)')}</span>
            </button>

            <!-- Touch Options -->
            ${q.options.map(opt => `
              <button data-opt-id="${opt.id}" class="w-full min-h-[58px] p-4 bg-amber-50 hover:bg-amber-100 border-2 border-amber-300 rounded-2xl text-left font-bold text-base md:text-lg text-stone-800 shadow-sm transition active:scale-98 flex items-center justify-between">
                <span>${opt.text[this.lang] || opt.text.en}</span>
                <span class="text-amber-600 text-xl font-bold">➔</span>
              </button>
            `).join("")}
          </div>
        ` : `
          <!-- Reminiscence Story Card -->
          <div class="bg-emerald-50 border-2 border-emerald-300 rounded-3xl p-5 shadow-sm mb-4 animate-fade-in">
            ${this.spokenAnswerText ? `
              <div class="bg-white/80 rounded-xl p-2.5 mb-3 border border-emerald-200 text-xs font-bold text-emerald-900 flex items-center gap-2">
                <span>🎙️ Spoken Response:</span>
                <span class="italic">${this.spokenAnswerText}</span>
              </div>
            ` : ''}
            <div class="flex items-center gap-2 text-emerald-800 font-bold text-lg mb-2">
              <span>🌟</span>
              <span>${this.lang === 'as' ? 'সুন্দৰ স্মৃতি' : this.lang === 'hi' ? 'सुखद संस्मरण' : 'Cherished Memory'}</span>
            </div>
            <p class="text-lg md:text-xl font-medium text-emerald-950 leading-relaxed">
              ${story}
            </p>
            <div class="mt-4 pt-3 border-t border-emerald-200 flex justify-end">
              <button id="btn-next-action" class="px-6 py-3 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-lg rounded-2xl shadow transition active:scale-95">
                ${this.lang === 'as' ? 'পৰৱৰ্তী খেললৈ যাওক ➔' : this.lang === 'hi' ? 'अगली गतिविधि ➔' : 'Next Activity ➔'}
              </button>
            </div>
          </div>
        `}
      </div>
    `;

    // Event handlers
    this.container.querySelector("#btn-repeat-audio")?.addEventListener("click", () => this.playAudioInstruction());
    this.container.querySelector("#btn-exit-game")?.addEventListener("click", () => this.onExit());
    this.container.querySelector("#btn-voice-answer")?.addEventListener("click", () => this.handleVoiceInput());

    this.container.querySelectorAll("[data-opt-id]").forEach(btn => {
      btn.addEventListener("click", () => {
        const optId = btn.getAttribute("data-opt-id");
        const opt = q.options.find(o => o.id === optId);
        if (opt) this.handleSelectOption(opt);
      });
    });

    this.container.querySelector("#btn-next-action")?.addEventListener("click", () => {
      this.onComplete({
        questionId: q.id,
        durationMs: Date.now() - this.startTime
      });
    });
  }
}