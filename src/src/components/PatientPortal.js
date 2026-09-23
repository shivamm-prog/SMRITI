// SMRITI - Patient Interface (Elderly-Friendly Cognitive Stimulation Portal)
import { UI_STRINGS } from '../data/i18n.js';
import { GAMES_DATA } from '../data/games.js';
import { ICONS } from '../data/icons.js';
import { db } from '../db/smritiStorage.js';
import { audio } from '../services/audioService.js';
import { PersonalizationEngine } from '../services/personalizationEngine.js';

import { MemoryMatchGame } from '../games/MemoryMatch.js';
import { RememberObjectsGame } from '../games/RememberObjects.js';
import { DailyLifeSequencingGame } from '../games/DailyLifeSequencing.js';
import { WordCategoryGame } from '../games/WordCategoryGame.js';
import { ReminiscenceAlbumGame } from '../games/ReminiscenceAlbum.js';
import { OrientationGame } from '../games/OrientationGame.js';

export class PatientPortal {
  constructor(container, options = {}) {
    this.container = container;
    this.lang = options.lang || "as";
    this.onBackHome = options.onBackHome || (() => {});

    this.profile = db.getPatientProfile();
    this.activeGameKey = null;
    this.activeGameInstance = null;
    this.lastResult = null;

    this.render();
  }

  setLanguage(lang) {
    this.lang = lang;
    db.updateSettings({ activeLanguage: lang });
    if (this.activeGameKey) {
      this.launchGame(this.activeGameKey);
    } else {
      this.render();
    }
  }

  launchGame(gameKey) {
    audio.stop();
    this.activeGameKey = gameKey;
    this.lastResult = null;
    this.container.innerHTML = `<div id="game-mount" class="flex-1 flex flex-col"></div>`;
    const mount = this.container.querySelector("#game-mount");

    const onComplete = (result) => {
      this.lastResult = result;
      this.renderCelebration(result);
    };

    const onExit = () => {
      audio.stop();
      this.activeGameKey = null;
      this.activeGameInstance = null;
      this.render();
    };

    const gameData = GAMES_DATA[gameKey];

    switch (gameKey) {
      case "memory_match":
        this.activeGameInstance = new MemoryMatchGame(mount, {
          lang: this.lang,
          gameData,
          onComplete,
          onExit
        });
        break;

      case "remember_objects":
        this.activeGameInstance = new RememberObjectsGame(mount, {
          lang: this.lang,
          gameData,
          onComplete,
          onExit
        });
        break;

      case "daily_life_sequencing":
        this.activeGameInstance = new DailyLifeSequencingGame(mount, {
          lang: this.lang,
          gameData,
          onComplete,
          onExit
        });
        break;

      case "word_category_game":
        this.activeGameInstance = new WordCategoryGame(mount, {
          lang: this.lang,
          gameData,
          onComplete,
          onExit
        });
        break;

      case "reminiscence_album":
        this.activeGameInstance = new ReminiscenceAlbumGame(mount, {
          lang: this.lang,
          gameData,
          onComplete,
          onExit
        });
        break;

      case "orientation_game":
        this.activeGameInstance = new OrientationGame(mount, {
          lang: this.lang,
          gameData,
          onComplete,
          onExit
        });
        break;

      default:
        this.render();
        break;
    }
  }

  renderCelebration(result) {
    audio.stop();
    const t = UI_STRINGS[this.lang] || UI_STRINGS.en;

    this.container.innerHTML = `
      <div class="flex flex-col flex-1 p-6 bg-amber-50 max-w-xl mx-auto w-full items-center justify-center text-center animate-fade-in">
        <div class="w-24 h-24 rounded-full bg-amber-200 border-4 border-amber-500 flex items-center justify-center text-5xl mb-4 shadow-xl animate-bounce">
          🌟
        </div>

        <h2 class="text-3xl sm:text-4xl font-black text-amber-950 mb-2">
          ${t.wellDone}
        </h2>
        
        <p class="text-xl font-bold text-stone-800 mb-6 max-w-md">
          ${t.goodEffort}
        </p>

        <!-- Score / Performance Summary Box -->
        <div class="w-full bg-white border-3 border-amber-300 rounded-3xl p-5 shadow-lg mb-6 text-left">
          <div class="flex items-center justify-between border-b border-stone-100 pb-3 mb-3">
            <span class="text-sm font-bold text-stone-600">${t.activityDifficulty}</span>
            <span class="text-base font-black text-amber-900">${result ? result.difficultyLevel : "Level 1"}</span>
          </div>
          <div class="flex items-center justify-between border-b border-stone-100 pb-3 mb-3">
            <span class="text-sm font-bold text-stone-600">${t.responseAccuracy}</span>
            <span class="text-xl font-black text-emerald-700">${result ? result.accuracy : 100}%</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm font-bold text-stone-600">Storage Status</span>
            <span class="text-xs font-black px-2.5 py-1 bg-amber-100 text-amber-900 rounded-full border border-amber-300">
              💾 Saved Locally (Offline)
            </span>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="w-full space-y-3">
          <button id="btn-next-activity" class="w-full py-4.5 bg-amber-600 hover:bg-amber-700 active:bg-amber-800 text-white text-xl font-black rounded-2xl shadow-xl transition flex items-center justify-center gap-2 transform active:scale-98">
            <span>${t.nextActivity}</span>
            <span>➔</span>
          </button>
          <button id="btn-return-home" class="w-full py-3.5 bg-stone-200 hover:bg-stone-300 text-stone-800 text-lg font-bold rounded-2xl transition">
            ${t.backToHome}
          </button>
        </div>
      </div>
    `;

    const nextBtn = this.container.querySelector("#btn-next-activity");
    if (nextBtn) {
      nextBtn.addEventListener("click", () => {
        this.activeGameKey = null;
        this.render();
      });
    }

    const returnBtn = this.container.querySelector("#btn-return-home");
    if (returnBtn) {
      returnBtn.addEventListener("click", () => this.onBackHome());
    }
  }

  render() {
    audio.stop();
    const t = UI_STRINGS[this.lang] || UI_STRINGS.en;
    const progress = PersonalizationEngine.getTodayProgress(this.profile.id);
    const adaptive = PersonalizationEngine.getAdaptiveLevel(this.profile.id);

    const gamesList = [
      { key: "memory_match", title: t.games.game1_title, desc: t.games.game1_desc, icon: "tea_cup", color: "from-amber-400 to-amber-600" },
      { key: "remember_objects", title: t.games.game2_title, desc: t.games.game2_desc, icon: "spectacles", color: "from-orange-400 to-orange-600" },
      { key: "daily_life_sequencing", title: t.games.game3_title, desc: t.games.game3_desc, icon: "morning_walk", color: "from-emerald-400 to-emerald-600" },
      { key: "word_category_game", title: t.games.game4_title, desc: t.games.game4_desc, icon: "banana", color: "from-yellow-400 to-amber-600" },
      { key: "reminiscence_album", title: t.games.game5_title, desc: t.games.game5_desc, icon: "grandkids", color: "from-rose-400 to-pink-600" },
      { key: "orientation_game", title: t.games.game6_title, desc: t.games.game6_desc, icon: "calendar", color: "from-sky-400 to-blue-600" }
    ];

    this.container.innerHTML = `
      <div class="flex flex-col flex-1 p-4 sm:p-6 bg-stone-50 max-w-xl mx-auto w-full animate-fade-in">
        
        <!-- Header -->
        <header class="flex items-center justify-between pb-3 border-b border-stone-200">
          <button id="btn-back-home" class="px-3.5 py-2 bg-stone-200 hover:bg-stone-300 text-stone-800 font-bold rounded-xl text-sm flex items-center gap-1.5 transition">
            <span>←</span>
            <span>${t.backToHome}</span>
          </button>

          <!-- Language Selector -->
          <div class="flex items-center gap-1 bg-stone-200 p-1 rounded-2xl">
            <button data-lang="as" class="lang-btn px-2.5 py-1 rounded-xl font-bold text-xs sm:text-sm ${this.lang === "as" ? "bg-amber-600 text-white shadow" : "text-stone-700"}">
              অসমীয়া
            </button>
            <button data-lang="hi" class="lang-btn px-2.5 py-1 rounded-xl font-bold text-xs sm:text-sm ${this.lang === "hi" ? "bg-amber-600 text-white shadow" : "text-stone-700"}">
              हिन्दी
            </button>
            <button data-lang="en" class="lang-btn px-2.5 py-1 rounded-xl font-bold text-xs sm:text-sm ${this.lang === "en" ? "bg-amber-600 text-white shadow" : "text-stone-700"}">
              EN
            </button>
          </div>
        </header>

        <!-- Greeting & Encouragement Banner -->
        <div class="mt-4 p-5 rounded-3xl bg-amber-500 text-white shadow-lg">
          <div class="flex items-center justify-between">
            <div>
              <span class="text-xs uppercase font-black tracking-wider text-amber-200">
                ${t.greetingMorning}
              </span>
              <h1 class="text-2xl sm:text-3xl font-black">${this.profile.name}</h1>
              <p class="text-sm font-bold text-amber-100 mt-1">${t.chooseActivity}</p>
            </div>
            <div class="text-4xl">👵</div>
          </div>
          <div class="mt-3 flex items-center justify-between text-xs font-bold bg-amber-600/60 p-2.5 rounded-xl">
            <span>${progress.completedToday} / ${progress.targetDaily} ${t.completed}</span>
            <span class="px-2 py-0.5 bg-white/20 rounded-md">${adaptive.levelName}</span>
          </div>
        </div>

        <!-- 6 Game Cards Grid -->
        <div class="mt-5 space-y-3.5 flex-1">
          <div class="text-xs font-black uppercase tracking-wider text-stone-500 px-1">
            ${t.todaysActivities}
          </div>

          ${gamesList.map((game, idx) => `
            <button 
              data-game-key="${game.key}"
              class="game-card-btn w-full p-4 sm:p-5 bg-white hover:bg-amber-50/80 active:bg-amber-100 border-3 border-stone-200 hover:border-amber-500 rounded-3xl shadow-md transition-all transform active:scale-98 flex items-center justify-between text-left group">
              <div class="flex items-center gap-4">
                <div class="w-14 h-14 sm:w-16 sm:h-16 rounded-2xl bg-amber-100 border-2 border-amber-300 p-2 flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition shadow-sm">
                  ${ICONS[game.icon] || `<span class="text-3xl">🪔</span>`}
                </div>
                <div>
                  <h3 class="text-lg sm:text-xl font-black text-stone-900 group-hover:text-amber-900 leading-snug">
                    ${game.title}
                  </h3>
                  <p class="text-xs sm:text-sm font-semibold text-stone-500 mt-0.5 leading-snug">
                    ${game.desc}
                  </p>
                </div>
              </div>
              <span class="w-10 h-10 rounded-full bg-amber-100 group-hover:bg-amber-600 group-hover:text-white text-amber-800 flex items-center justify-center font-black text-lg transition flex-shrink-0 ml-2">
                ▶
              </span>
            </button>
          `).join("")}
        </div>
      </div>
    `;

    this.attachEvents();
  }

  attachEvents() {
    const backBtn = this.container.querySelector("#btn-back-home");
    if (backBtn) backBtn.addEventListener("click", () => this.onBackHome());

    const langBtns = this.container.querySelectorAll(".lang-btn");
    langBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const lang = btn.dataset.lang;
        this.setLanguage(lang);
      });
    });

    const gameBtns = this.container.querySelectorAll(".game-card-btn");
    gameBtns.forEach(btn => {
      btn.addEventListener("click", () => {
        const key = btn.dataset.gameKey;
        this.launchGame(key);
      });
    });
  }
}