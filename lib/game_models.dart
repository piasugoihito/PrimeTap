import 'dart:convert';

enum Rarity { low, medium, high }

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
    name: json['name'],
    homeCountry: json['homeCountry'],
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
  int politicianTaps;
  int intimacyLevel;
  final List<String> faceImages;

  Politician({
    required this.id,
    required this.name,
    required this.country,
    required this.rarity,
    required this.odds,
    this.isUnlocked = false,
    this.politicianTaps = 0,
    this.intimacyLevel = 1,
    required this.faceImages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'rarity': rarity.index,
    'odds': odds,
    'isUnlocked': isUnlocked,
    'politicianTaps': politicianTaps,
    'intimacyLevel': intimacyLevel,
    'faceImages': faceImages,
  };

  factory Politician.fromJson(Map<String, dynamic> json) => Politician(
    id: json['id'],
    name: json['name'],
    country: json['country'],
    rarity: Rarity.values[json['rarity']],
    odds: (json['odds'] ?? 1.0).toDouble(),
    isUnlocked: json['isUnlocked'] ?? false,
    politicianTaps: json['politicianTaps'] ?? 0,
    intimacyLevel: json['intimacyLevel'] ?? 1,
    faceImages: List<String>.from(json['faceImages'] ?? []),
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
