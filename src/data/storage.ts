import { UserStats } from '../types';

const STORAGE_KEY = 'speedy_arrow_user_stats_v3';

const DEFAULT_STATS: UserStats = {
  coins: 50, // Welcome starter balance
  streakDays: 1,
  lastLoginDate: new Date().toDateString(),
  username: 'SpeedRunner',
  country: 'USA',
  bio: 'Master of geometry waves & speed tunnels!',
  unlockedLevels: { 1: 0 },
  equippedShape: 'arrow',
  ownedShapes: ['arrow'],
  eloRating: 1000,
  totalCrashes: 0,
  totalPerfectRuns: 0,
  endlessHighScore: 0,
  raceWins: 0,
  isMuted: false,
};

export function loadUserStats(): UserStats {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      saveUserStats(DEFAULT_STATS);
      return { ...DEFAULT_STATS };
    }
    const parsed = JSON.parse(raw);
    return {
      ...DEFAULT_STATS,
      ...parsed,
      unlockedLevels: { 1: 0, ...(parsed.unlockedLevels || {}) },
      ownedShapes: Array.from(new Set(['arrow', ...(parsed.ownedShapes || [])])),
      equippedShape: parsed.equippedShape || 'arrow',
    };
  } catch (e) {
    console.error('Failed to load stats from localStorage:', e);
    return { ...DEFAULT_STATS };
  }
}

export function saveUserStats(stats: UserStats): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(stats));
  } catch (e) {
    console.error('Failed to save stats to localStorage:', e);
  }
}

export function checkDailyStreak(stats: UserStats): { updatedStats: UserStats; reward: number; isNewDay: boolean } {
  const todayStr = new Date().toDateString();
  let updated = { ...stats };
  let reward = 0;
  let isNewDay = false;

  if (!updated.lastLoginDate) {
    updated.streakDays = 1;
    reward = 50;
    updated.coins += reward;
    updated.lastLoginDate = todayStr;
    isNewDay = true;
  } else {
    const lastDate = new Date(updated.lastLoginDate);
    const todayDate = new Date(todayStr);
    const diffTime = Math.abs(todayDate.getTime() - lastDate.getTime());
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays === 1) {
      updated.streakDays += 1;
      reward = Math.min(500, 50 * updated.streakDays);
      updated.coins += reward;
      updated.lastLoginDate = todayStr;
      isNewDay = true;
    } else if (diffDays > 1) {
      updated.streakDays = 1;
      reward = 50;
      updated.coins += reward;
      updated.lastLoginDate = todayStr;
      isNewDay = true;
    }
  }

  if (isNewDay) {
    saveUserStats(updated);
  }

  return { updatedStats: updated, reward, isNewDay };
}

export function calculateElo(stats: UserStats): number {
  let completedCount = 0;
  Object.keys(stats.unlockedLevels).forEach((lvlStr) => {
    const progress = stats.unlockedLevels[Number(lvlStr)];
    if (progress >= 100) {
      completedCount++;
    }
  });

  const rating = Math.max(
    200,
    1000 + (completedCount * 30) + (stats.totalPerfectRuns * 50) + (stats.raceWins * 25) - (stats.totalCrashes * 4)
  );

  return Math.floor(rating);
}
