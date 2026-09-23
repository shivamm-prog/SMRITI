// SMRITI - Deterministic Local Adaptive Engine & Analytics
// 100% Offline, Zero-API Requirement

import { db } from '../db/smritiStorage.js';

export class PersonalizationEngine {
  /**
   * Deterministic local adaptive difficulty rule:
   * IF accuracy >= 80% for 3 consecutive sessions -> increase difficulty by 1 (max Level 4)
   * IF accuracy < 50% for 2 consecutive sessions -> decrease difficulty by 1 (min Level 1)
   * ELSE -> maintain difficulty
   */
  static getAdaptiveLevel(patientId = "pat_anita_001", gameType = null) {
    const history = db.getActivityResults(patientId);
    if (!history || history.length === 0) {
      return { level: 1, levelName: "Level 1 (Very Easy)" };
    }

    // Filter by specific game or recent general sessions
    const relevant = gameType 
      ? history.filter(r => r.activityType === gameType) 
      : history;

    if (relevant.length === 0) {
      return { level: 1, levelName: "Level 1 (Very Easy)" };
    }

    // Base current level on latest recorded level
    const latestLevelStr = relevant[0].difficultyLevel || "Level 1 (Very Easy)";
    let currentLevel = 1;
    if (latestLevelStr.includes("Level 2") || latestLevelStr.includes("2")) currentLevel = 2;
    else if (latestLevelStr.includes("Level 3") || latestLevelStr.includes("3")) currentLevel = 3;
    else if (latestLevelStr.includes("Level 4") || latestLevelStr.includes("4")) currentLevel = 4;

    // Rule: Check last 3 consecutive sessions for >= 80%
    if (relevant.length >= 3) {
      const last3 = relevant.slice(0, 3);
      const allHigh = last3.every(r => (r.accuracy || 0) >= 80);
      if (allHigh && currentLevel < 4) {
        currentLevel += 1;
      }
    }

    // Rule: Check last 2 consecutive sessions for < 50%
    if (relevant.length >= 2) {
      const last2 = relevant.slice(0, 2);
      const allLow = last2.every(r => (r.accuracy || 0) < 50);
      if (allLow && currentLevel > 1) {
        currentLevel -= 1;
      }
    }

    const levelNames = {
      1: "Level 1 (Very Easy)",
      2: "Level 2 (Easy)",
      3: "Level 3 (Moderate)",
      4: "Level 4 (Challenging)"
    };

    return {
      level: currentLevel,
      levelName: levelNames[currentLevel]
    };
  }

  // Get Today's Progress
  static getTodayProgress(patientId = "pat_anita_001") {
    const history = db.getActivityResults(patientId);
    const todayStr = new Date().toISOString().split("T")[0];
    const todayRecords = history.filter(r => r.timestamp && r.timestamp.startsWith(todayStr));
    const completedToday = todayRecords.length;
    const targetDaily = 6;
    return {
      completedToday,
      targetDaily,
      percentage: Math.min(100, Math.round((completedToday / targetDaily) * 100))
    };
  }

  // Calculate local domain-specific trends for Caregiver and Doctor dashboards
  static calculateDomainTrends(patientId = "pat_anita_001") {
    const history = db.getActivityResults(patientId);
    
    // Cognitive domains
    const domains = {
      memory: { name: "Memory", sessions: 0, totalAccuracy: 0, avgAccuracy: 85 },
      attention: { name: "Attention & Focus", sessions: 0, totalAccuracy: 0, avgAccuracy: 80 },
      language: { name: "Language & Semantic", sessions: 0, totalAccuracy: 0, avgAccuracy: 90 },
      sequencing: { name: "Sequencing & Planning", sessions: 0, totalAccuracy: 0, avgAccuracy: 75 },
      orientation: { name: "Orientation & Environment", sessions: 0, totalAccuracy: 0, avgAccuracy: 95 },
      reminiscence: { name: "Reminiscence & Personal", sessions: 0, totalAccuracy: 0, avgAccuracy: 100 }
    };

    history.forEach(record => {
      const type = record.activityType;
      const acc = record.accuracy || 100;

      if (type === "memory_match") {
        domains.memory.sessions++;
        domains.memory.totalAccuracy += acc;
      } else if (type === "remember_objects" || type === "find_the_object") {
        domains.attention.sessions++;
        domains.attention.totalAccuracy += acc;
      } else if (type === "word_category_game" || type === "word_picture_match" || type === "category_game") {
        domains.language.sessions++;
        domains.language.totalAccuracy += acc;
      } else if (type === "daily_life_sequencing" || type === "picture_sequence") {
        domains.sequencing.sessions++;
        domains.sequencing.totalAccuracy += acc;
      } else if (type === "orientation_game") {
        domains.orientation.sessions++;
        domains.orientation.totalAccuracy += acc;
      } else if (type === "reminiscence_album" || type === "remember_recall") {
        domains.reminiscence.sessions++;
        domains.reminiscence.totalAccuracy += acc;
      }
    });

    // Calculate averages or default to baseline
    Object.keys(domains).forEach(k => {
      if (domains[k].sessions > 0) {
        domains[k].avgAccuracy = Math.round(domains[k].totalAccuracy / domains[k].sessions);
      }
    });

    return domains;
  }

  // Calculate overall metrics
  static calculateMetrics(patientId = "pat_anita_001") {
    const history = db.getActivityResults(patientId);
    const observations = db.getObservations(patientId);

    if (history.length === 0) {
      return {
        totalActivities: 0,
        averageAccuracy: 0,
        averageResponseTimeSec: 0,
        completionRate: 100,
        domainTrends: this.calculateDomainTrends(patientId),
        adaptiveLevel: this.getAdaptiveLevel(patientId),
        observationsCount: observations.length
      };
    }

    const total = history.length;
    const avgAcc = Math.round(history.reduce((sum, r) => sum + (r.accuracy || 0), 0) / total);
    const avgTime = Math.round((history.reduce((sum, r) => sum + (r.responseTimeMs || 4000), 0) / total) / 100) / 10;

    return {
      totalActivities: total,
      averageAccuracy: avgAcc,
      averageResponseTimeSec: avgTime,
      completionRate: 100,
      domainTrends: this.calculateDomainTrends(patientId),
      adaptiveLevel: this.getAdaptiveLevel(patientId),
      observationsCount: observations.length
    };
  }
}