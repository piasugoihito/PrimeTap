import 'dart:convert';

class GameCharacter {
  const GameCharacter({
    required this.id,
    required this.name,
    required this.baseColorHex,
    required this.unlockTapPoints,
    required this.baseScale,
  });

  final String id;
  final String name;
  final int baseColorHex;
  final int unlockTapPoints;
  final double baseScale;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'baseColorHex': baseColorHex,
      'unlockTapPoints': unlockTapPoints,
      'baseScale': baseScale,
    };
  }

  factory GameCharacter.fromMap(Map<String, dynamic> map) {
    return GameCharacter(
      id: map['id'] as String,
      name: map['name'] as String,
      baseColorHex: map['baseColorHex'] as int,
      unlockTapPoints: map['unlockTapPoints'] as int,
      baseScale: (map['baseScale'] as num).toDouble(),
    );
  }
}

class DailyTapRecord {
  const DailyTapRecord({
    required this.dateKey,
    required this.tapCount,
    required this.highestTapsPerSecond,
    required this.tapPoints,
  });

  final String dateKey;
  final int tapCount;
  final double highestTapsPerSecond;
  final int tapPoints;

  DailyTapRecord copyWith({
    int? tapCount,
    double? highestTapsPerSecond,
    int? tapPoints,
  }) {
    return DailyTapRecord(
      dateKey: dateKey,
      tapCount: tapCount ?? this.tapCount,
      highestTapsPerSecond:
          highestTapsPerSecond ?? this.highestTapsPerSecond,
      tapPoints: tapPoints ?? this.tapPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'tapCount': tapCount,
      'highestTapsPerSecond': highestTapsPerSecond,
      'tapPoints': tapPoints,
    };
  }

  factory DailyTapRecord.fromMap(Map<String, dynamic> map) {
    return DailyTapRecord(
      dateKey: map['dateKey'] as String,
      tapCount: map['tapCount'] as int,
      highestTapsPerSecond: (map['highestTapsPerSecond'] as num).toDouble(),
      tapPoints: map['tapPoints'] as int,
    );
  }
}

class GameStateData {
  const GameStateData({
    required this.totalTapCount,
    required this.totalTapPoints,
    required this.currentTapPower,
    required this.upgradeLevel,
    required this.upgradeItemCount,
    required this.totalUpgradeItemsCollected,
    required this.upgradeItemDropProgress,
    required this.upgradeItemCost,
    required this.selectedCharacterId,
    required this.unlockedCharacterIds,
    required this.dailyRecords,
  });

  final int totalTapCount;
  final int totalTapPoints;
  final int currentTapPower;
  final int upgradeLevel;
  final int upgradeItemCount;
  final int totalUpgradeItemsCollected;
  final int upgradeItemDropProgress;
  final int upgradeItemCost;
  final String selectedCharacterId;
  final List<String> unlockedCharacterIds;
  final List<DailyTapRecord> dailyRecords;

  factory GameStateData.initial() {
    return const GameStateData(
      totalTapCount: 0,
      totalTapPoints: 0,
      currentTapPower: 1,
      upgradeLevel: 0,
      upgradeItemCount: 0,
      totalUpgradeItemsCollected: 0,
      upgradeItemDropProgress: 0,
      upgradeItemCost: 3,
      selectedCharacterId: 'slime',
      unlockedCharacterIds: ['slime'],
      dailyRecords: [],
    );
  }

  GameStateData copyWith({
    int? totalTapCount,
    int? totalTapPoints,
    int? currentTapPower,
    int? upgradeLevel,
    int? upgradeItemCount,
    int? totalUpgradeItemsCollected,
    int? upgradeItemDropProgress,
    int? upgradeItemCost,
    String? selectedCharacterId,
    List<String>? unlockedCharacterIds,
    List<DailyTapRecord>? dailyRecords,
  }) {
    return GameStateData(
      totalTapCount: totalTapCount ?? this.totalTapCount,
      totalTapPoints: totalTapPoints ?? this.totalTapPoints,
      currentTapPower: currentTapPower ?? this.currentTapPower,
      upgradeLevel: upgradeLevel ?? this.upgradeLevel,
      upgradeItemCount: upgradeItemCount ?? this.upgradeItemCount,
      totalUpgradeItemsCollected:
          totalUpgradeItemsCollected ?? this.totalUpgradeItemsCollected,
      upgradeItemDropProgress:
          upgradeItemDropProgress ?? this.upgradeItemDropProgress,
      upgradeItemCost: upgradeItemCost ?? this.upgradeItemCost,
      selectedCharacterId: selectedCharacterId ?? this.selectedCharacterId,
      unlockedCharacterIds: unlockedCharacterIds ?? this.unlockedCharacterIds,
      dailyRecords: dailyRecords ?? this.dailyRecords,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalTapCount': totalTapCount,
      'totalTapPoints': totalTapPoints,
      'currentTapPower': currentTapPower,
      'upgradeLevel': upgradeLevel,
      'upgradeItemCount': upgradeItemCount,
      'totalUpgradeItemsCollected': totalUpgradeItemsCollected,
      'upgradeItemDropProgress': upgradeItemDropProgress,
      'upgradeItemCost': upgradeItemCost,
      'selectedCharacterId': selectedCharacterId,
      'unlockedCharacterIds': unlockedCharacterIds,
      'dailyRecords': dailyRecords.map((record) => record.toMap()).toList(),
    };
  }

  factory GameStateData.fromMap(Map<String, dynamic> map) {
    return GameStateData(
      totalTapCount: map['totalTapCount'] as int? ?? 0,
      totalTapPoints: map['totalTapPoints'] as int? ?? 0,
      currentTapPower: map['currentTapPower'] as int? ?? 1,
      upgradeLevel: map['upgradeLevel'] as int? ?? 0,
      upgradeItemCount: map['upgradeItemCount'] as int? ?? 0,
      totalUpgradeItemsCollected:
          map['totalUpgradeItemsCollected'] as int? ?? 0,
      upgradeItemDropProgress: map['upgradeItemDropProgress'] as int? ?? 0,
      upgradeItemCost: map['upgradeItemCost'] as int? ?? 3,
      selectedCharacterId: map['selectedCharacterId'] as String? ?? 'slime',
      unlockedCharacterIds:
          (map['unlockedCharacterIds'] as List<dynamic>? ?? ['slime'])
              .cast<String>(),
      dailyRecords: (map['dailyRecords'] as List<dynamic>? ?? [])
          .map((item) => DailyTapRecord.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory GameStateData.fromJson(String source) =>
      GameStateData.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

const List<GameCharacter> defaultCharacters = [
  GameCharacter(
    id: 'slime',
    name: 'ぷるスライム',
    baseColorHex: 0xFF7ED957,
    unlockTapPoints: 0,
    baseScale: 1,
  ),
  GameCharacter(
    id: 'cat',
    name: 'もちネコ',
    baseColorHex: 0xFFFFC857,
    unlockTapPoints: 300,
    baseScale: 1.05,
  ),
  GameCharacter(
    id: 'bear',
    name: 'ぽよクマ',
    baseColorHex: 0xFFB08968,
    unlockTapPoints: 1200,
    baseScale: 1.1,
  ),
  GameCharacter(
    id: 'dragon',
    name: 'ちびドラ',
    baseColorHex: 0xFF7B61FF,
    unlockTapPoints: 4000,
    baseScale: 1.18,
  ),
  GameCharacter(
    id: 'star',
    name: 'ほしタマ',
    baseColorHex: 0xFF4CC9F0,
    unlockTapPoints: 9000,
    baseScale: 1.24,
  ),
];
