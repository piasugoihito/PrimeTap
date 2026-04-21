import 'dart:convert';

enum Rarity { low, medium, high, boss }

class UserProfile {
  String name;
  String homeCountry;
  int totalTaps;
  double totalPoints;
  double budgetCoins;
  double tapEfficiency;
  double luckLevel;
  double maxTapSpeed;

  UserProfile({
    this.name = 'User',
    this.homeCountry = '日本',
    this.totalTaps = 0,
    this.totalPoints = 0,
    this.budgetCoins = 0,
    this.tapEfficiency = 1.0,
    this.luckLevel = 1.0,
    this.maxTapSpeed = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'homeCountry': homeCountry,
    'totalTaps': totalTaps,
    'totalPoints': totalPoints,
    'budgetCoins': budgetCoins,
    'tapEfficiency': tapEfficiency,
    'luckLevel': luckLevel,
    'maxTapSpeed': maxTapSpeed,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'User',
    homeCountry: json['homeCountry'] ?? '日本',
    totalTaps: json['totalTaps'] ?? 0,
    totalPoints: (json['totalPoints'] ?? 0).toDouble(),
    budgetCoins: (json['budgetCoins'] ?? 0).toDouble(),
    tapEfficiency: (json['tapEfficiency'] ?? 1.0).toDouble(),
    luckLevel: (json['luckLevel'] ?? 1.0).toDouble(),
    maxTapSpeed: (json['maxTapSpeed'] ?? 0.0).toDouble(),
  );
}

class Politician {
  final String id;
  final String name;
  final String country;
  final Rarity rarity;
  final double odds;
  bool isUnlocked;
  int intimacyLevel;
  double politicianTaps;
  final List<String> faceImages;
  final int tier; // 0: Initial, 1: Home Boss, 2: Neighbors, 3: Global, 4: Final
  final List<String> requiredPoliticianIds; // Unlock conditions

  Politician({
    required this.id,
    required this.name,
    required this.country,
    required this.rarity,
    required this.odds,
    this.isUnlocked = false,
    this.intimacyLevel = 1,
    this.politicianTaps = 0,
    required this.faceImages,
    this.tier = 0,
    this.requiredPoliticianIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'rarity': rarity.index,
    'odds': odds,
    'isUnlocked': isUnlocked,
    'intimacyLevel': intimacyLevel,
    'politicianTaps': politicianTaps,
    'faceImages': faceImages,
    'tier': tier,
    'requiredPoliticianIds': requiredPoliticianIds,
  };

  factory Politician.fromJson(Map<String, dynamic> json) => Politician(
    id: json['id'],
    name: json['name'],
    country: json['country'],
    rarity: Rarity.values[json['rarity']],
    odds: json['odds'].toDouble(),
    isUnlocked: json['isUnlocked'],
    intimacyLevel: json['intimacyLevel'],
    politicianTaps: (json['politicianTaps'] ?? 0).toDouble(),
    faceImages: List<String>.from(json['faceImages']),
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
    efficiencyBoost: json['efficiencyBoost'].toDouble(),
    isOwned: json['isOwned'],
  );
}
