// SMRITI - Main Application Root Coordinator & Router
import { db } from './db/smritiStorage.js';
import { syncEngine } from './services/syncEngine.js';
import { HomePortal } from './components/HomePortal.js';
import { PatientPortal } from './components/PatientPortal.js';
import { CaregiverPortal } from './components/CaregiverPortal.js';
import { DoctorPortal } from './components/DoctorPortal.js';
import { ApiMonitorModal } from './components/ApiMonitorModal.js';

class SmritiApp {
  constructor() {
    this.appContainer = document.getElementById("app-container");
    this.currentPortal = "home"; // 'home' | 'patient' | 'caregiver' | 'doctor'
    this.lang = "as"; // Default: Assamese
  }

  async init() {
    await db.init();
    const settings = db.getSettings();
    this.lang = settings.activeLanguage || "as";

    // Subscribe to sync updates
    syncEngine.subscribe(() => {
      // Re-render current portal to update pending badge
      if (this.currentPortal === "home") {
        this.renderPortal();
      }
    });

    this.renderPortal();
  }

  setLanguage(lang) {
    this.lang = lang;
    db.updateSettings({ activeLanguage: lang });
    this.renderPortal();
  }

  navigateTo(portal) {
    this.currentPortal = portal;
    this.renderPortal();
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  renderPortal() {
    this.appContainer.innerHTML = "";

    switch (this.currentPortal) {
      case "patient":
        new PatientPortal(this.appContainer, {
          lang: this.lang,
          onBackHome: () => this.navigateTo("home")
        });
        break;

      case "caregiver":
        new CaregiverPortal(this.appContainer, {
          lang: this.lang,
          onBackHome: () => this.navigateTo("home")
        });
        break;

      case "doctor":
        new DoctorPortal(this.appContainer, {
          lang: this.lang,
          onBackHome: () => this.navigateTo("home")
        });
        break;

      case "home":
      default:
        new HomePortal(this.appContainer, {
          lang: this.lang,
          onSelectPortal: (p) => this.navigateTo(p),
          onLanguageChange: (l) => this.setLanguage(l),
          onOpenApiMonitor: () => new ApiMonitorModal()
        });
        break;
    }
  }
}

// Instantiate App when DOM is ready
document.addEventListener("DOMContentLoaded", () => {
  window.smritiApp = new SmritiApp();
  window.smritiApp.init();
});