import 'package:flutter/material.dart';
import 'game_models.dart';
import 'game_repository.dart';

class GameController extends ChangeNotifier {
  final GameRepository _repository = GameRepository();
  
  UserProfile? user;
  List<Politician> politicians = [];
  List<GameItem> items = [];
  Politician? selectedPolitician;

  GameController() {
    _init();
  }

  Future<void> _init() async {
    user = await _repository.loadUserProfile();
    if (user == null) {
      user = UserProfile(name: '新人プレイヤー', homeCountry: '日本');
      await _repository.saveUserProfile(user!);
    }
    
    politicians = await _repository.loadPoliticians();
    items = await _repository.loadItems();
    
    // 初期選択
    selectedPolitician = politicians.firstWhere((p) => p.isUnlocked, orElse: () => politicians.first);
    notifyListeners();
  }

  void handleTap() {
    if (user == null || selectedPolitician == null) return;
    
    user!.totalTaps++;
    double points = 1.0 * user!.tapEfficiency;
    user!.totalPoints += points.toInt();
    selectedPolitician!.politicianTaps++;
    
    // コイン計算: 政治家のオッズ × タップポイント
    double earnedCoins = points * selectedPolitician!.odds;
    user!.budgetCoins += earnedCoins;

    // 親密度レベルアップ (1->2: 1000 taps, 2->3: 5000 taps)
    if (selectedPolitician!.intimacyLevel == 1 && selectedPolitician!.politicianTaps >= 1000) {
      selectedPolitician!.intimacyLevel = 2;
    } else if (selectedPolitician!.intimacyLevel == 2 && selectedPolitician!.politicianTaps >= 5000) {
      selectedPolitician!.intimacyLevel = 3;
    }

    _repository.saveUserProfile(user!);
    _repository.savePoliticians(politicians);
    notifyListeners();
  }

  Future<bool> unlockPolitician(Politician p) async {
    if (user == null || p.isUnlocked) return false;
    
    double cost = _getUnlockCost(p);
    if (user!.budgetCoins >= cost) {
      user!.budgetCoins -= cost;
      p.isUnlocked = true;
      await _repository.saveUserProfile(user!);
      await _repository.savePoliticians(politicians);
      notifyListeners();
      return true;
    }
    return false;
  }

  double _getUnlockCost(Politician p) {
    // レアリティに比例
    double baseCost = 1000;
    switch (p.rarity) {
      case Rarity.low: baseCost = 500; break;
      case Rarity.medium: baseCost = 2000; break;
      case Rarity.high: baseCost = 10000; break;
      case Rarity.boss: baseCost = 50000; break;
    }
    
    // 国家戦略: 特定の政治家は安価 (例: 各国の最初の政治家)
    if (p.id.endsWith('_01')) {
      baseCost *= 0.5;
    }
    return baseCost;
  }

  void selectPolitician(Politician p) {
    if (p.isUnlocked) {
      selectedPolitician = p;
      notifyListeners();
    }
  }

  Future<GameItem?> tryGacha() async {
    if (user == null || user!.budgetCoins < 100) return null;
    
    user!.budgetCoins -= 100;
    final result = await _repository.performGacha(user!, items);
    
    if (result != null) {
      result.isOwned = true;
      user!.tapEfficiency += result.efficiencyBoost;
      await _repository.saveItems(items);
    } else {
      // 外れ: 半分返却
      user!.budgetCoins += 50;
    }
    
    await _repository.saveUserProfile(user!);
    notifyListeners();
    return result;
  }
}
