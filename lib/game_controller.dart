import 'package:flutter/material.dart';
import 'game_models.dart';
import 'game_repository.dart';

class GameController extends ChangeNotifier {
  final GameRepository _repository = GameRepository();
  
  UserProfile? user;
  List<Politician> politicians = [];
  List<GameItem> items = [];
  Politician? activePolitician;

  bool isLoading = true;

  GameController() {
    _init();
  }

  Future<void> _init() async {
    user = await _repository.loadUserProfile() ?? UserProfile();
    politicians = await _repository.loadPoliticians();
    items = await _repository.loadItems();
    
    activePolitician = politicians.firstWhere((p) => p.isUnlocked, orElse: () => politicians.first);
    
    isLoading = false;
    notifyListeners();
  }

  // 二重通貨ロジック: タップ処理
  void handleTap(Offset position) {
    if (user == null || activePolitician == null) return;

    // 1. タップポイント (Lvアップ用)
    double pointGain = 1.0 * (activePolitician!.rarity.index + 1) * user!.tapEfficiency;
    activePolitician!.politicianTaps += pointGain;
    user!.totalPoints += pointGain;

    // 2. 国家予算 (アンロック用) - インフレ曲線
    double unlockRate = politicians.where((p) => p.isUnlocked).length / politicians.length;
    double budgetGain = (activePolitician!.odds * (1.0 + unlockRate * 5.0)) * user!.tapEfficiency;
    user!.budgetCoins += budgetGain;

    user!.totalTaps++;
    
    // 親密度レベルアップチェック (1-3)
    if (activePolitician!.politicianTaps > 1000 && activePolitician!.intimacyLevel == 1) {
      activePolitician!.intimacyLevel = 2;
    } else if (activePolitician!.politicianTaps > 5000 && activePolitician!.intimacyLevel == 2) {
      activePolitician!.intimacyLevel = 3;
    }

    _save();
    notifyListeners();
  }

  // Tier制アンロックチェック
  bool canUnlock(Politician target) {
    if (user!.budgetCoins < _getUnlockCost(target)) return false;
    
    // 条件チェック: 必要な政治家がすべてLv3（親密度3）であること
    for (String reqId in target.requiredPoliticianIds) {
      final reqPol = politicians.firstWhere((p) => p.id == reqId);
      if (reqPol.intimacyLevel < 3) return false;
    }
    return true;
  }

  double _getUnlockCost(Politician p) {
    double base = (p.rarity.index + 1) * 1000.0;
    return base * (p.tier + 1);
  }

  void unlockPolitician(Politician target) {
    if (!canUnlock(target)) return;
    
    user!.budgetCoins -= _getUnlockCost(target);
    target.isUnlocked = true;
    _save();
    notifyListeners();
  }

  void setActivePolitician(Politician p) {
    if (p.isUnlocked) {
      activePolitician = p;
      notifyListeners();
    }
  }

  Future<GameItem?> tryGacha() async {
    double cost = 500.0;
    if (user!.budgetCoins < cost) return null;

    user!.budgetCoins -= cost;
    final result = await _repository.performGacha(user!, items);
    
    if (result != null) {
      result.isOwned = true;
      user!.tapEfficiency += result.efficiencyBoost;
    } else {
      // ハズレ: 半分返却
      user!.budgetCoins += cost / 2;
    }
    
    _save();
    notifyListeners();
    return result;
  }

  void _save() {
    _repository.saveUserProfile(user!);
    _repository.savePoliticians(politicians);
    _repository.saveItems(items);
  }
}
