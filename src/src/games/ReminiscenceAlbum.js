// SMRITI - Game 5: Reminiscence & Memory Album (Personal & Cultural Reminiscence Stimulation)
import { ICONS } from '../data/icons.js';
import { audio } from '../services/audioService.js';
import { db } from '../db/smritiStorage.js';

export class ReminiscenceAlbumGame {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.gameData = options.gameData;
    this.onComplete = options.onComplete || (() => {});
    this.onExit = options.onExit || (() => {});

    this.memories = [];
    this.initMemories();

    this.memoryIndex = options.memoryIndex || 0;
    this.currentMemory = this.memories[this.memoryIndex % this.memories.length];
    this.currentQuestionStep = 1; // Step 1: Who is this?, Step 2: Relation/Place, Step 3: Story
    this.startTime = Date.now();
    this.isListeningVoice = false;
    this.spokenAnswerText = "";
    this.hasAnswered = false;

    this.render();
    this.playAudioInstruction();
  }

  initMemories() {
    // Merge baseline regional memories with custom memories added by Caregiver
    const baseMemories = this.gameData.memories || [];
    const customMemories = db.getMemories();

    const formattedCustom = customMemories.map(m => ({
      id: `custom_${m.id}`,
      title: m.title,
      category: m.category,
      personName: m.title.en,
      relation: "Family / Cherished Memory",
      place: m.yearApprox || "Cherished Place",
      iconKey: m.iconKey || "grandkids",
      audioPrompt: m.audioPrompt || {
        en: `Look at this special family memory: ${m.title.en}.`,
        hi: `इस विशेष पारिवारिक स्मृति को देखें: ${m.title.hi}.`,
        as: `এই বিশেষ পুৰণি স্মৃতিটো চাওক: ${m.title.as}।`
      },
      subtitleEn: m.subtitleEn || `Look at this special family memory: ${m.title.en}.`,
      question1: {
        prompt: {
          en: "Who is in this cherished photograph?",
          hi: "इस प्यारी तस्वीर में कौन हैं?",
          as: "এই মৰমৰ ছবিখনত কোন আছে?"
        },
        options: [
          { text: { en: "Family & Loved Ones", hi: "परिवार और प्रियजन", as: "পৰিয়াল আৰু আত্মীয়" }, isCorrect: true },
          { text: { en: "Neighbor", hi: "पड़ोसी", as: "চুবুৰীয়া" }, isCorrect: false },
          { text: { en: "Other", hi: "अन्य", as: "অন্যান্য" }, isCorrect: false }
        ]
      },
      question2: {
        prompt: {
          en: "What feeling or memory does this bring to you?",
          hi: "यह आपको किस प्रकार की सुखद याद दिलाता है?",
          as: "এই স্মৃতিটোৱে আপোনাৰ মনলৈ কি ভাৱ আনে?"
        },
        options: [
          { text: { en: "Joyful Family Time", hi: "आनंददायक पारिवारिक समय", as: "পৰিয়ালৰ লগত কটোৱা আনন্দৰ সময়" }, isCorrect: true },
          { text: { en: "Routine Day", hi: "सामान्य दिन", as: "সাধাৰণ দিন" }, isCorrect: false }
        ]
      },
      story: m.caption || {
        en: "A wonderful memory preserved by your loving family.",
        hi: "आपके परिवार द्वारा सहेजी गई एक सुंदर याद।",
        as: "আপোনাৰ পৰিয়ালে সাঁচি ৰখা এক মৰমৰ স্মৃতি।"
      }
    }));

    this.memories = [...baseMemories, ...formattedCustom];
  }

  playAudioInstruction() {
    const prompt = this.currentMemory.audioPrompt[this.lang] || this.currentMemory.audioPrompt.en;
    audio.speak(prompt, this.lang);
  }

  handleSelectOption(option) {
    if (this.hasAnswered) return;
    audio.playPositiveChime();

    if (this.currentQuestionStep === 1 && this.currentMemory.question2) {
      this.currentQuestionStep = 2;
      this.render();
      const q2Prompt = this.currentMemory.question2.prompt[this.lang] || this.currentMemory.question2.prompt.en;
      audio.speak(q2Prompt, this.lang);
    } else {
      // Finished all questions for this memory -> Reveal heartwarming story
      this.hasAnswered = true;
      const duration = Date.now() - this.startTime;

      const record = db.saveActivityResult({
        activityType: "reminiscence_album",
        activityTitle: `Reminiscence - ${this.currentMemory.title.en}`,
        difficultyLevel: "Level 1 (Very Easy)",
        accuracy: 100,
        responseTimeMs: duration,
        attempts: 1,
        correctMatches: 1,
        incorrectMatches: 0,
        hintsUsed: 0,
        language: this.lang
      });

      this.render();

      const storyText = this.currentMemory.story[this.lang] || this.currentMemory.story.en;
      audio.speak(storyText, this.lang);
    }
  }

  handleVoiceInput() {
    this.isListeningVoice = true;
    this.render();

    const listeningPrompt = this.lang === "as" ? "অনুগ্ৰহ কৰি কওক, মই আপোনাৰ কথা শুনি আছোঁ..." :
                           this.lang === "hi" ? "कृपया बोलें, मैं सुन रहा हूँ..." :
                           "Please speak, I am listening...";
    audio.speak(listeningPrompt, this.lang);

    // Simulate voice detection / Web Speech capture
    setTimeout(() => {
      this.isListeningVoice = false;
      this.spokenAnswerText = this.lang === "as" ? "‘মই স্পষ্টভাৱে মনত পেলাইছোঁ’" :
                              this.lang === "hi" ? "‘मुझे बहुत अच्छे से याद है’" :
                              "‘I remember this moment clearly’";
      this.handleSelectOption({ isCorrect: true });
    }, 1800);
  }

  handleNextMemory() {
    this.memoryIndex++;
    this.currentMemory = this.memories[this.memoryIndex % this.memories.length];
    this.currentQuestionStep = 1;
    this.startTime = Date.now();
    this.hasAnswered = false;
    this.spokenAnswerText = "";
    this.render();
    this.playAudioInstruction();
  }

  render() {
    const memoryTitle = this.currentMemory.title[this.lang] || this.currentMemory.title.en;
    const prompt = this.currentMemory.audioPrompt[this.lang] || this.currentMemory.audioPrompt.en;
    const subtitle = this.currentMemory.subtitleEn;
    const activeQuestion = this.currentQuestionStep === 1 
      ? this.currentMemory.question1 
      : (this.currentMemory.question2 || this.currentMemory.question1);

    const questionPrompt = activeQuestion.prompt[this.lang] || activeQuestion.prompt.en;

    this.container.innerHTML = `
      <div class="p-4 flex flex-col flex-1 max-w-xl mx-auto w-full animate-fade-in">
        <!-- Top Navigation -->
        <div class="flex items-center justify-between mb-3 border-b border-stone-200 pb-2">
          <button id="btn-exit-game" class="px-4 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-base flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${this.lang === "as" ? "বাহিৰ হওক" : this.lang === "hi" ? "बाहर निकलें" : "Exit"}</span>
          </button>
          <div class="text-xs font-bold px-2.5 py-1 bg-amber-100 text-amber-900 rounded-full border border-amber-300 flex items-center gap-1.5">
            <span>📸</span>
            <span>${this.memoryIndex + 1} / ${this.memories.length}</span>
          </div>
        </div>

        <!-- Cherished Photo Card -->
        <div class="bg-white border-4 border-amber-200 rounded-3xl p-4 shadow-xl mb-4 overflow-hidden">
          <div class="relative w-full aspect-video rounded-2xl bg-amber-50 border border-amber-200 flex items-center justify-center p-4 mb-3 overflow-hidden">
            <div class="w-24 h-24 sm:w-28 sm:h-28">
              ${ICONS[this.currentMemory.iconKey] || `<span class="text-6xl">📸</span>`}
            </div>
            <div class="absolute bottom-2 right-2 px-2.5 py-1 bg-stone-900/80 text-white rounded-lg text-xs font-bold backdrop-blur-sm">
              ${this.currentMemory.place}
            </div>
          </div>

          <div class="flex items-start justify-between gap-3">
            <div>
              <h2 class="text-2xl font-black text-stone-900">${memoryTitle}</h2>
              <p class="text-sm font-bold text-amber-900 mt-0.5">${prompt}</p>
              ${this.lang !== "en" ? `<p class="text-xs font-mono text-stone-400 mt-0.5 italic">${subtitle}</p>` : ""}
            </div>
            <button id="btn-audio-prompt" class="p-3 bg-amber-500 hover:bg-amber-600 text-white rounded-2xl shadow-md transition flex-shrink-0">
              <span class="text-2xl">🔊</span>
            </button>
          </div>
        </div>

        ${!this.hasAnswered ? `
          <!-- Question & Interactive Choices -->
          <div class="bg-amber-50/80 border-2 border-amber-200 rounded-2xl p-4 mb-4">
            <h3 class="text-lg font-black text-amber-950 mb-3">${questionPrompt}</h3>
            
            <div class="space-y-2.5">
              ${activeQuestion.options.map((opt, idx) => {
                const optText = opt.text[this.lang] || opt.text.en;
                return `
                  <button 
                    data-option-index="${idx}"
                    class="rem-opt-btn w-full bg-white hover:bg-amber-100 active:bg-amber-200 border-2 border-amber-300 rounded-2xl p-3.5 flex items-center justify-between shadow-sm transition text-left transform active:scale-98">
                    <span class="text-base sm:text-lg font-bold text-stone-900 leading-snug">
                      ${optText}
                    </span>
                    <span class="w-7 h-7 rounded-full bg-amber-200 text-amber-900 font-bold flex items-center justify-center text-sm">
                      ➔
                    </span>
                  </button>
                `;
              }).join("")}
            </div>

            <!-- Voice & Text Alternate Input Options -->
            <div class="mt-4 pt-3 border-t border-amber-200 flex items-center justify-between gap-2">
              <button id="btn-voice-input" class="flex-1 py-3 px-3 ${this.isListeningVoice ? "bg-red-600 animate-pulse text-white" : "bg-white hover:bg-stone-100 text-stone-800"} border-2 border-stone-300 rounded-xl font-bold text-sm flex items-center justify-center gap-1.5 shadow-sm transition">
                <span>🎙️</span>
                <span>${this.isListeningVoice ? "Listening..." : (this.lang === "as" ? "মুখেৰে কওক" : this.lang === "hi" ? "बोलकर बताएं" : "Voice Answer")}</span>
              </button>
            </div>
          </div>
        ` : `
          <!-- Heartwarming Story Card -->
          <div class="bg-emerald-50 border-3 border-emerald-400 rounded-2xl p-4 mb-4 shadow-md animate-fade-in">
            <div class="flex items-center gap-2 text-emerald-800 font-black text-sm uppercase tracking-wider mb-2">
              <span>🌟</span>
              <span>${this.lang === "as" ? "মৰমৰ পুৰণি কথা" : this.lang === "hi" ? "सुखद संस्मरण" : "Cherished Reminiscence"}</span>
            </div>
            <p class="text-lg font-bold text-stone-900 leading-relaxed">
              ${this.currentMemory.story[this.lang] || this.currentMemory.story.en}
            </p>
            ${this.spokenAnswerText ? `
              <div class="mt-2 text-xs font-mono text-emerald-700 bg-emerald-100 p-2 rounded-lg">
                🎙️ ${this.spokenAnswerText}
              </div>
            ` : ""}
          </div>

          <!-- Next Memory / Complete Buttons -->
          <div class="flex gap-3 mt-auto">
            <button id="btn-next-memory" class="flex-1 py-4 bg-amber-600 hover:bg-amber-700 text-white text-lg font-black rounded-2xl shadow-lg transition flex items-center justify-center gap-2">
              <span>${this.lang === "as" ? "পৰৱৰ্তী স্মৃতি চাওক" : this.lang === "hi" ? "अगली याद देखें" : "Next Memory"}</span>
              <span>➔</span>
            </button>
            <button id="btn-finish-reminiscence" class="py-4 px-6 bg-stone-200 hover:bg-stone-300 text-stone-800 text-base font-bold rounded-2xl transition">
              <span>${this.lang === "as" ? "সমাপ্তি" : this.lang === "hi" ? "पूर्ण" : "Finish"}</span>
            </button>
          </div>
        `}
      </div>
    `;

    this.attachEvents(activeQuestion);
  }

  attachEvents(activeQuestion) {
    const exitBtn = this.container.querySelector("#btn-exit-game");
    if (exitBtn) exitBtn.addEventListener("click", () => this.onExit());

    const audioBtn = this.container.querySelector("#btn-audio-prompt");
    if (audioBtn) audioBtn.addEventListener("click", () => this.playAudioInstruction());

    const optBtns = this.container.querySelectorAll(".rem-opt-btn");
    optBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const idx = parseInt(btn.dataset.optionIndex, 10);
        const opt = activeQuestion.options[idx];
        if (opt) this.handleSelectOption(opt);
      });
    });

    const voiceBtn = this.container.querySelector("#btn-voice-input");
    if (voiceBtn) voiceBtn.addEventListener("click", () => this.handleVoiceInput());

    const nextMemBtn = this.container.querySelector("#btn-next-memory");
    if (nextMemBtn) nextMemBtn.addEventListener("click", () => this.handleNextMemory());

    const finishBtn = this.container.querySelector("#btn-finish-reminiscence");
    if (finishBtn) finishBtn.addEventListener("click", () => this.onComplete());
  }
}
