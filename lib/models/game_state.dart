class GameSettings {
  bool musicEnabled;
  bool soundEnabled;
  bool vibrationEnabled;
  String graphicsQuality; // 'low', 'medium', 'high'
  String controlLayout; // 'default', 'compact', 'leftHanded'

  GameSettings({
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.graphicsQuality = 'high',
    this.controlLayout = 'default',
  });

  Map<String, dynamic> toJson() {
    return {
      'musicEnabled': musicEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'graphicsQuality': graphicsQuality,
      'controlLayout': controlLayout,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      musicEnabled: json['musicEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      graphicsQuality: json['graphicsQuality'] ?? 'high',
      controlLayout: json['controlLayout'] ?? 'default',
    );
  }
}

class GameProgress {
  int currentLevelId;
  Set<int> unlockedLevels;
  Map<int, int> levelStars; // levelId -> 1..3
  Map<int, double> bestTimes; // levelId -> seconds
  int totalCoins;
  int totalCrystals;

  GameProgress({
    this.currentLevelId = 1,
    Set<int>? unlockedLevels,
    Map<int, int>? levelStars,
    Map<int, double>? bestTimes,
    this.totalCoins = 0,
    this.totalCrystals = 0,
  })  : unlockedLevels = unlockedLevels ?? {1},
        levelStars = levelStars ?? {},
        bestTimes = bestTimes ?? {};

  Map<String, dynamic> toJson() {
    return {
      'currentLevelId': currentLevelId,
      'unlockedLevels': unlockedLevels.toList(),
      'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
      'bestTimes': bestTimes.map((k, v) => MapEntry(k.toString(), v)),
      'totalCoins': totalCoins,
      'totalCrystals': totalCrystals,
    };
  }

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    Set<int> unlocked = {1};
    if (json['unlockedLevels'] != null) {
      unlocked = (json['unlockedLevels'] as List).map((e) => e as int).toSet();
    }

    Map<int, int> stars = {};
    if (json['levelStars'] != null) {
      (json['levelStars'] as Map).forEach((k, v) {
        stars[int.parse(k.toString())] = v as int;
      });
    }

    Map<int, double> times = {};
    if (json['bestTimes'] != null) {
      (json['bestTimes'] as Map).forEach((k, v) {
        times[int.parse(k.toString())] = (v as num).toDouble();
      });
    }

    return GameProgress(
      currentLevelId: json['currentLevelId'] ?? 1,
      unlockedLevels: unlocked,
      levelStars: stars,
      bestTimes: times,
      totalCoins: json['totalCoins'] ?? 0,
      totalCrystals: json['totalCrystals'] ?? 0,
    );
  }
}
