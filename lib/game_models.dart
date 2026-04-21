import 'dart:convert';

enum Rarity { low, medium, high, boss }

class UserProfile {
  String name;
  String homeCountry;
  List<String> unlockedPoliticianIds;
  int totalTaps;
  int totalPoints;
  double maxTapSpeed;
  double tapEfficiency;
  int luckLevel;
  double budgetCoins;

  UserProfile({
    required this.name,
    required this.homeCountry,
    this.unlockedPoliticianIds = const [],
    this.totalTaps = 0,
    this.totalPoints = 0,
    this.maxTapSpeed = 0.0,
    this.tapEfficiency = 1.0,
    this.luckLevel = 1,
    this.budgetCoins = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'homeCountry': homeCountry,
    'unlockedPoliticianIds': unlockedPoliticianIds,
    'totalTaps': totalTaps,
    'totalPoints': totalPoints,
    'maxTapSpeed': maxTapSpeed,
    'tapEfficiency': tapEfficiency,
    'luckLevel': luckLevel,
    'budgetCoins': budgetCoins,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'User',
    homeCountry: json['homeCountry'] ?? '日本',
    unlockedPoliticianIds: List<String>.from(json['unlockedPoliticianIds'] ?? []),
    totalTaps: json['totalTaps'] ?? 0,
    totalPoints: json['totalPoints'] ?? 0,
    maxTapSpeed: (json['maxTapSpeed'] ?? 0.0).toDouble(),
    tapEfficiency: (json['tapEfficiency'] ?? 1.0).toDouble(),
    luckLevel: json['luckLevel'] ?? 1,
    budgetCoins: (json['budgetCoins'] ?? 0.0).toDouble(),
  );
}

class Politician {
  final String id;
  final String name;
  final String country;
  final Rarity rarity;
  final double odds;
  bool isUnlocked;
  int politicianTaps; // その政治家をタップした総回数
  int politicianPoints; // その政治家で獲得した総ポイント
  int intimacyLevel; // 親密度レベル (1～3)
  final List<String> faceImages; // レベルごとの顔画像（3枚）
  final int tier;
  final List<String> requiredPoliticianIds;

  Politician({
    required this.id,
    required this.name,
    required this.country,
    required this.rarity,
    required this.odds,
    this.isUnlocked = false,
    this.politicianTaps = 0,
    this.politicianPoints = 0,
    this.intimacyLevel = 1,
    required this.faceImages,
    this.tier = 0,
    this.requiredPoliticianIds = const [],
  });

  // 現在のレベルに応じた画像を取得
  String get currentFaceImage {
    if (faceImages.isEmpty) return 'assets/images/pol_jp_leader.png';
    int index = intimacyLevel - 1;
    if (index < 0) index = 0;
    if (index >= faceImages.length) index = faceImages.length - 1;
    return faceImages[index];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'rarity': rarity.index,
    'odds': odds,
    'isUnlocked': isUnlocked,
    'politicianTaps': politicianTaps,
    'politicianPoints': politicianPoints,
    'intimacyLevel': intimacyLevel,
    'faceImages': faceImages,
    'tier': tier,
    'requiredPoliticianIds': requiredPoliticianIds,
  };

  factory Politician.fromJson(Map<String, dynamic> json) => Politician(
    id: json['id'],
    name: json['name'],
    country: json['country'],
    rarity: Rarity.values[json['rarity']],
    odds: (json['odds'] ?? 1.0).toDouble(),
    isUnlocked: json['isUnlocked'] ?? false,
    politicianTaps: json['politicianTaps'] ?? 0,
    politicianPoints: json['politicianPoints'] ?? 0,
    intimacyLevel: json['intimacyLevel'] ?? 1,
    faceImages: List<String>.from(json['faceImages'] ?? []),
    tier: json['tier'] ?? 0,
    requiredPoliticianIds: List<String>.from(json['requiredPoliticianIds'] ?? []),
  );
}

class GameItem {
  final String id;
  final String name;
  final String description;
  final double efficiencyBoost;
  bool isOwned;

  GameItem({
    required this.id,
    required this.name,
    required this.description,
    required this.efficiencyBoost,
    this.isOwned = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'efficiencyBoost': efficiencyBoost,
    'isOwned': isOwned,
  };

  factory GameItem.fromJson(Map<String, dynamic> json) => GameItem(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    efficiencyBoost: (json['efficiencyBoost'] ?? 0.0).toDouble(),
    isOwned: json['isOwned'] ?? false,
  );
}
