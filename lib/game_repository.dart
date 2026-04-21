import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_models.dart';

class GameRepository {
  GameRepository({SharedPreferences? preferences})
      : _preferences = preferences;

  static const _stateKey = 'merge_tap_game_state_v1';
  static const _itemDropEveryTaps = 12;
  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<GameStateData> loadState() async {
    final prefs = await _prefs;
    final json = prefs.getString(_stateKey);
    if (json == null || json.isEmpty) {
      final initial = GameStateData.initial();
      await saveState(initial);
      return initial;
    }
    return GameStateData.fromJson(json);
  }

  Future<void> saveState(GameStateData state) async {
    final prefs = await _prefs;
    await prefs.setString(_stateKey, state.toJson());
  }

  Future<GameStateData> registerTap({
    required GameStateData currentState,
    required double tapsPerSecond,
  }) async {
    final nextPoints = currentState.totalTapPoints + currentState.currentTapPower;
    final nextTapCount = currentState.totalTapCount + 1;
    final nextUnlocked = _computeUnlockedCharacterIds(nextPoints);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final dropProgress = currentState.upgradeItemDropProgress + 1;
    final earnedItems = dropProgress ~/ _itemDropEveryTaps;
    final nextDropProgress = dropProgress % _itemDropEveryTaps;

    final updatedRecords = _upsertDailyRecord(
      records: currentState.dailyRecords,
      dateKey: todayKey,
      tapCountDelta: 1,
      tapPointDelta: currentState.currentTapPower,
      tapsPerSecond: tapsPerSecond,
    );

    final nextState = currentState.copyWith(
      totalTapCount: nextTapCount,
      totalTapPoints: nextPoints,
      upgradeItemCount: currentState.upgradeItemCount + earnedItems,
      totalUpgradeItemsCollected:
          currentState.totalUpgradeItemsCollected + earnedItems,
      upgradeItemDropProgress: nextDropProgress,
      unlockedCharacterIds: nextUnlocked,
      selectedCharacterId: _resolveSelectedCharacterId(
        currentState.selectedCharacterId,
        nextUnlocked,
      ),
      dailyRecords: updatedRecords,
    );

    await saveState(nextState);
    return nextState;
  }

  Future<GameStateData> purchaseUpgrade(GameStateData currentState) async {
    if (currentState.upgradeItemCount < currentState.upgradeItemCost) {
      return currentState;
    }

    final nextState = currentState.copyWith(
      currentTapPower: currentState.currentTapPower + 1,
      upgradeLevel: currentState.upgradeLevel + 1,
      upgradeItemCount:
          currentState.upgradeItemCount - currentState.upgradeItemCost,
      upgradeItemCost: _nextUpgradeCost(currentState.upgradeLevel + 1),
    );

    await saveState(nextState);
    return nextState;
  }

  Future<GameStateData> selectCharacter({
    required GameStateData currentState,
    required String characterId,
  }) async {
    if (!currentState.unlockedCharacterIds.contains(characterId)) {
      return currentState;
    }

    final nextState = currentState.copyWith(selectedCharacterId: characterId);
    await saveState(nextState);
    return nextState;
  }

  int _nextUpgradeCost(int nextLevel) {
    return 3 + (pow(nextLevel + 1, 1.7) * 1.5).round();
  }

  List<String> _computeUnlockedCharacterIds(int totalTapPoints) {
    return defaultCharacters
        .where((character) => totalTapPoints >= character.unlockTapPoints)
        .map((character) => character.id)
        .toList();
  }

  String _resolveSelectedCharacterId(
    String selectedCharacterId,
    List<String> unlockedIds,
  ) {
    if (unlockedIds.contains(selectedCharacterId)) {
      return selectedCharacterId;
    }
    return unlockedIds.isNotEmpty ? unlockedIds.last : defaultCharacters.first.id;
  }

  List<DailyTapRecord> _upsertDailyRecord({
    required List<DailyTapRecord> records,
    required String dateKey,
    required int tapCountDelta,
    required int tapPointDelta,
    required double tapsPerSecond,
  }) {
    final copied = List<DailyTapRecord>.from(records);
    final index = copied.indexWhere((record) => record.dateKey == dateKey);

    if (index == -1) {
      copied.add(
        DailyTapRecord(
          dateKey: dateKey,
          tapCount: tapCountDelta,
          highestTapsPerSecond: tapsPerSecond,
          tapPoints: tapPointDelta,
        ),
      );
      copied.sort((a, b) => a.dateKey.compareTo(b.dateKey));
      return copied;
    }

    final current = copied[index];
    copied[index] = current.copyWith(
      tapCount: current.tapCount + tapCountDelta,
      tapPoints: current.tapPoints + tapPointDelta,
      highestTapsPerSecond: max(current.highestTapsPerSecond, tapsPerSecond),
    );
    return copied;
  }
}
