import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'game_models.dart';
import 'game_repository.dart';

class GameController extends ChangeNotifier {
  GameController({GameRepository? repository})
      : _repository = repository ?? GameRepository();

  final GameRepository _repository;

  GameStateData _state = GameStateData.initial();
  bool _isReady = false;
  double _latestTapsPerSecond = 0;

  GameStateData get state => _state;
  bool get isReady => _isReady;
  double get latestTapsPerSecond => _latestTapsPerSecond;
  UnmodifiableListView<GameCharacter> get characters =>
      UnmodifiableListView(defaultCharacters);

  Future<void> load() async {
    _state = await _repository.loadState();
    _isReady = true;
    notifyListeners();
  }

  Future<void> registerTap(double tapsPerSecond) async {
    _latestTapsPerSecond = tapsPerSecond;
    _state = await _repository.registerTap(
      currentState: _state,
      tapsPerSecond: tapsPerSecond,
    );
    notifyListeners();
  }

  Future<bool> purchaseUpgrade() async {
    final previousPoints = _state.totalTapPoints;
    _state = await _repository.purchaseUpgrade(_state);
    final purchased = previousPoints != _state.totalTapPoints;
    notifyListeners();
    return purchased;
  }

  Future<void> selectCharacter(String characterId) async {
    _state = await _repository.selectCharacter(
      currentState: _state,
      characterId: characterId,
    );
    notifyListeners();
  }

  GameCharacter get selectedCharacter {
    return characters.firstWhere(
      (character) => character.id == _state.selectedCharacterId,
      orElse: () => characters.first,
    );
  }

  bool isUnlocked(String characterId) {
    return _state.unlockedCharacterIds.contains(characterId);
  }

  double growthScaleFor(GameCharacter character) {
    final growth = (_state.totalTapPoints / 2500).clamp(0, 1.6);
    return character.baseScale + growth;
  }
}
