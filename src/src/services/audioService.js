// SMRITI - Audio & Multilingual Speech Synthesis Service
// Evidence-informed auditory feedback: soothing, clear, senior-accessible

class AudioService {
  constructor() {
    this.synth = typeof window !== "undefined" ? window.speechSynthesis : null;
    this.audioCtx = null;
    this.voices = [];
    this.voiceRate = 0.85; // Calmer, slightly slower cadence for older adults
    this.isMuted = false;

    if (this.synth) {
      this.loadVoices();
      if (this.synth.onvoiceschanged !== undefined) {
        this.synth.onvoiceschanged = () => this.loadVoices();
      }
    }
  }

  loadVoices() {
    if (!this.synth) return;
    this.voices = this.synth.getVoices();
  }

  getAudioContext() {
    if (!this.audioCtx && typeof window !== "undefined") {
      const AudioCtxClass = window.AudioContext || window.webkitAudioContext;
      if (AudioCtxClass) {
        this.audioCtx = new AudioCtxClass();
      }
    }
    if (this.audioCtx && this.audioCtx.state === "suspended") {
      this.audioCtx.resume();
    }
    return this.audioCtx;
  }

  // Play gentle, comforting chime chords for positive encouragement
  playPositiveChime() {
    if (this.isMuted) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const now = ctx.currentTime;
      // Gentle major chord progression: C5 -> E5 -> G5 (warm bell)
      const frequencies = [523.25, 659.25, 783.99];
      
      frequencies.forEach((freq, idx) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = "sine";
        osc.frequency.setValueAtTime(freq, now + idx * 0.1);

        gain.gain.setValueAtTime(0, now + idx * 0.1);
        gain.gain.linearRampToValueAtTime(0.18, now + idx * 0.1 + 0.05);
        gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.1 + 0.8);

        osc.connect(gain);
        gain.connect(ctx.destination);

        osc.start(now + idx * 0.1);
        osc.stop(now + idx * 0.1 + 0.9);
      });
    } catch (e) {
      console.warn("Web Audio chime not supported or allowed yet:", e);
    }
  }

  playSoftTap() {
    if (this.isMuted) return;
    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const now = ctx.currentTime;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      osc.type = "triangle";
      osc.frequency.setValueAtTime(320, now);
      osc.frequency.exponentialRampToValueAtTime(150, now + 0.08);

      gain.gain.setValueAtTime(0.08, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.08);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start(now);
      osc.stop(now + 0.09);
    } catch (e) {
      // ignore
    }
  }

  // Speak instruction in the target language (English, Hindi, or Assamese)
  speak(text, lang = "as") {
    if (this.isMuted || !this.synth || !text) return;

    try {
      this.synth.cancel(); // Stop any pending speech
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.rate = this.voiceRate;
      utterance.pitch = 1.0;

      // Select matching voice
      if (this.voices.length === 0) {
        this.loadVoices();
      }

      if (lang === "hi") {
        utterance.lang = "hi-IN";
        const hiVoice = this.voices.find(v => v.lang.startsWith("hi") || v.name.includes("Hindi"));
        if (hiVoice) utterance.voice = hiVoice;
      } else if (lang === "as") {
        // Many systems map Assamese speech via bn-IN or hi-IN or standard en-IN voice
        utterance.lang = "as-IN";
        const asVoice = this.voices.find(v => v.lang.startsWith("as") || v.lang.startsWith("bn") || v.lang.startsWith("hi"));
        if (asVoice) {
          utterance.voice = asVoice;
        } else {
          utterance.lang = "hi-IN";
        }
      } else {
        utterance.lang = "en-IN";
        const enVoice = this.voices.find(v => v.lang.startsWith("en-IN") || v.lang.startsWith("en-GB") || v.lang.startsWith("en"));
        if (enVoice) utterance.voice = enVoice;
      }

      this.synth.speak(utterance);
    } catch (e) {
      console.warn("Speech synthesis error:", e);
    }
  }

  stop() {
    if (this.synth) {
      this.synth.cancel();
    }
  }
}

export const audio = new AudioService();