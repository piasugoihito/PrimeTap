import 'dart:convert';

enum Rarity { low, medium, high }

class UserProfile {
  final String name;
  final String homeCountry;
  final List<String> unlockedPoliticianIds;
  final int totalTaps;
  final int totalPoints;
  final double maxTapSpeed;
  final double tapEfficiency;
  final int luckLevel;
  final double budgetCoins;

  UserProfile({
    required this.name,
    required this.homeCountry,
    required this.unlockedPoliticianIds,
    required this.totalTaps,
    required this.totalPoints,
    required this.maxTapSpeed,
    required this.tapEfficiency,
    required this.luckLevel,
    required this.budgetCoins,
  });

  UserProfile copyWith({
    String? name,
    String? homeCountry,
    List<String>? unlockedPoliticianIds,
    int? totalTaps,
    int? totalPoints,
    double? maxTapSpeed,
    double? tapEfficiency,
    int? luckLevel,
    double? budgetCoins,
  }) {
    return UserProfile(
      name: name ?? this.name,
      homeCountry: homeCountry ?? this.homeCountry,
      unlockedPoliticianIds: unlockedPoliticianIds ?? this.unlockedPoliticianIds,
      totalTaps: totalTaps ?? this.totalTaps,
      totalPoints: totalPoints ?? this.totalPoints,
      maxTapSpeed: maxTapSpeed ?? this.maxTapSpeed,
      tapEfficiency: tapEfficiency ?? this.tapEfficiency,
      luckLevel: luckLevel ?? this.luckLevel,
      budgetCoins: budgetCoins ?? this.budgetCoins,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      homeCountry: map['homeCountry'] ?? '',
      unlockedPoliticianIds: List<String>.from(map['unlockedPoliticianIds'] ?? []),
      totalTaps: map['totalTaps'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      maxTapSpeed: (map['maxTapSpeed'] ?? 0.0).toDouble(),
      tapEfficiency: (map['tapEfficiency'] ?? 1.0).toDouble(),
      luckLevel: map['luckLevel'] ?? 1,
      budgetCoins: (map['budgetCoins'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}

class Politician {
  final String id;
  final String name;
  final String country;
  final Rarity rarity;
  final double odds;
  final bool isUnlocked;
  final int politicianTaps;
  final int intimacyLevel; // 1-3
  final List<String> faceImages; // Paths to 3 images

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

  Politician copyWith({
    bool? isUnlocked,
    int? politicianTaps,
    int? intimacyLevel,
  }) {
    return Politician(
      id: id,
      name: name,
      country: country,
      rarity: rarity,
      odds: odds,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      politicianTaps: politicianTaps ?? this.politicianTaps,
      intimacyLevel: intimacyLevel ?? this.intimacyLevel,
      faceImages: faceImages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
  }

  factory Politician.fromMap(Map<String, dynamic> map) {
    return Politician(
      id: map['id'],
      name: map['name'],
      country: map['country'],
      rarity: Rarity.values[map['rarity'] ?? 0],
      odds: (map['odds'] ?? 1.0).toDouble(),
      isUnlocked: map['isUnlocked'] ?? false,
      politicianTaps: map['politicianTaps'] ?? 0,
      intimacyLevel: map['intimacyLevel'] ?? 1,
      faceImages: List<String>.from(map['faceImages'] ?? []),
    );
  }
}

class GameItem {
  final String itemId;
  final String name;
  final String country;
  final bool isOwned;
  final double efficiencyBoost;
  final double dropRate;

  GameItem({
    required this.itemId,
    required this.name,
    required this.country,
    this.isOwned = false,
    required this.efficiencyBoost,
    required this.dropRate,
  });

  GameItem copyWith({bool? isOwned}) {
    return GameItem(
      itemId: itemId,
      name: name,
      country: country,
      isOwned: isOwned ?? this.isOwned,
      efficiencyBoost: efficiencyBoost,
      dropRate: dropRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'country': country,
      'isOwned': isOwned,
      'efficiencyBoost': efficiencyBoost,
      'dropRate': dropRate,
    };
  }

  factory GameItem.fromMap(Map<String, dynamic> map) {
    return GameItem(
      itemId: map['itemId'],
      name: map['name'],
      country: map['country'],
      isOwned: map['isOwned'] ?? false,
      efficiencyBoost: (map['efficiencyBoost'] ?? 0.0).toDouble(),
      dropRate: (map['dropRate'] ?? 0.0).toDouble(),
    );
  }
}
