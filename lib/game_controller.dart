import 'dart:async';
import 'package:flutter/foundation.dart';
import 'game_models.dart';
import 'game_repository.dart';

class GameController extends ChangeNotifier {
  final GameRepository _repository = GameRepository();

  UserProfile? _user;
  List<Politician> _politicians = [];
  List<GameItem> _items = [];
  Politician? _selectedPolitician;

  UserProfile? get user => _user;
  List<Politician> get politicians => _politicians;
  List<GameItem> get items => _items;
  Politician? get selectedPolitician => _selectedPolitician;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _user = await _repository.loadUserProfile();
    _politicians = await _repository.loadPoliticians();
    _items = await _repository.loadItems();

    if (_user == null) {
      // 初回起動時の初期化はUI側で行う（名前・国家選択）
    } else {
      // 最後に選択していた政治家をセット（簡易的に最初の解放済み政治家）
      _selectedPolitician = _politicians.firstWhere((p) => p.isUnlocked);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUser(String name, String country) async {
    final initialPolitician = _politicians.firstWhere((p) => p.country == country && p.rarity == Rarity.low);
    _user = UserProfile(
      name: name,
      homeCountry: country,
      unlockedPoliticianIds: [initialPolitician.id],
      totalTaps: 0,
      totalPoints: 0,
      maxTapSpeed: 0.0,
      tapEfficiency: 1.0,
      luckLevel: 1,
      budgetCoins: 0.0,
    );
    _selectedPolitician = initialPolitician;
    await _repository.saveUserProfile(_user!);
    notifyListeners();
  }

  void handleTap() {
    if (_user == null || _selectedPolitician == null) return;

    final pointsEarned = (1 * _user!.tapEfficiency).toInt();
    final newTotalTaps = _user!.totalTaps + 1;
    final newTotalPoints = _user!.totalPoints + pointsEarned;
    
    // 政治家の個別タップ数とレベルアップ
    final updatedPoliticianTaps = _selectedPolitician!.politicianTaps + 1;
    int newIntimacyLevel = _selectedPolitician!.intimacyLevel;
    if (updatedPoliticianTaps >= 400 && newIntimacyLevel < 3) {
      newIntimacyLevel = 3;
    } else if (updatedPoliticianTaps >= 200 && newIntimacyLevel < 2) {
      newIntimacyLevel = 2;
    }

    _selectedPolitician = _selectedPolitician!.copyWith(
      politicianTaps: updatedPoliticianTaps,
      intimacyLevel: newIntimacyLevel,
    );

    // 政治家リストの更新
    final index = _politicians.indexWhere((p) => p.id == _selectedPolitician!.id);
    if (index != -1) {
      _politicians[index] = _selectedPolitician!;
    }

    // コイン計算: 政治家のオッズ × 総タップポイント
    final newBudgetCoins = _selectedPolitician!.odds * newTotalPoints;

    _user = _user!.copyWith(
      totalTaps: newTotalTaps,
      totalPoints: newTotalPoints,
      budgetCoins: newBudgetCoins,
    );

    _repository.saveUserProfile(_user!);
    _repository.savePoliticians(_politicians);
    notifyListeners();
  }

  Future<GameItem?> tryGacha() async {
    if (_user == null) return null;
    
    const gachaCost = 100.0; // 仮のコスト
    if (_user!.budgetCoins < gachaCost) return null;

    final result = await _repository.performGacha(_user!, _items);
    
    if (result != null) {
      // 当たり
      final itemIndex = _items.indexWhere((i) => i.itemId == result.itemId);
      if (itemIndex != -1) {
        _items[itemIndex] = _items[itemIndex].copyWith(isOwned: true);
        _user = _user!.copyWith(
          tapEfficiency: _user!.tapEfficiency + result.efficiencyBoost,
          budgetCoins: _user!.budgetCoins - gachaCost,
        );
      }
    } else {
      // 外れ: 半分返却
      _user = _user!.copyWith(
        budgetCoins: _user!.budgetCoins - (gachaCost / 2),
      );
    }

    await _repository.saveUserProfile(_user!);
    await _repository.saveItems(_items);
    notifyListeners();
    return result;
  }

  void selectPolitician(Politician politician) {
    if (politician.isUnlocked) {
      _selectedPolitician = politician;
      notifyListeners();
    }
  }
}
