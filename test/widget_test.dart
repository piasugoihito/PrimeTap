import 'package:flutter_test/flutter_test.dart';

import 'package:merge_tap_game/game_models.dart';

void main() {
  test('初期ゲーム状態が想定どおり生成される', () {
    final state = GameStateData.initial();

    expect(state.totalTapCount, 0);
    expect(state.totalTapPoints, 0);
    expect(state.currentTapPower, 1);
    expect(state.unlockedCharacterIds, ['slime']);
  });
}
