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
    try {
      // 1. ユーザープロファイルの読み込み
      user = await _repository.loadUserProfile();
      if (user == null) {
        user = UserProfile(name: '新人プレイヤー', homeCountry: '日本');
        await _repository.saveUserProfile(user!);
      }
      
      // 2. 政治家リストの読み込み
      politicians = await _repository.loadPoliticians();
      
      // もし読み込んだリストが空なら、強制的に初期データを生成する
      if (politicians.isEmpty) {
        // GameRepositoryのloadPoliticiansはデータがない場合に_generateInitialPoliticiansを呼ぶはずだが、
        // 万が一空のリストが返ってきた場合のセーフティネット
        politicians = [
          Politician(
            id: 'jp_leader',
            name: '日本首脳',
            country: '日本',
            rarity: Rarity.low,
            odds: 1.2,
            isUnlocked: true,
            faceImages: ['assets/images/pol_jp_leader.png'],
            tier: 0,
          ),
        ];
        await _repository.savePoliticians(politicians);
      }
      
      // 3. アイテムリストの読み込み
      items = await _repository.loadItems();
      
      // 4. 初期選択政治家の設定
      // アンロックされている政治家を探し、いなければ最初の政治家を選択
      selectedPolitician = politicians.firstWhere(
        (p) => p.isUnlocked, 
        orElse: () => politicians.first
      );
      
    } catch (e) {
      debugPrint('CRITICAL ERROR during GameController initialization: $e');
      // 致命的なエラー時でもアプリが動くように最小限のデータをセット
      user ??= UserProfile(name: '新人プレイヤー', homeCountry: '日本');
      if (politicians.isEmpty) {
        politicians = [
          Politician(
            id: 'jp_leader',
            name: '日本首脳',
            country: '日本',
            rarity: Rarity.low,
            odds: 1.2,
            isUnlocked: true,
            faceImages: ['assets/images/pol_jp_leader.png'],
            tier: 0,
          ),
        ];
        selectedPolitician = politicians.first;
      }
    } finally {
      notifyListeners();
    }
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

    // 親密度レベルアップ (100タップごとに1レベル上昇)
    int newLevel = (selectedPolitician!.politicianTaps / 100).floor() + 1;
    if (newLevel > selectedPolitician!.intimacyLevel) {
      selectedPolitician!.intimacyLevel = newLevel;
    }

    _repository.saveUserProfile(user!);
    _repository.savePoliticians(politicians);
    notifyListeners();
  }

  Future<bool> unlockPolitician(Politician p) async {
    if (user == null || p.isUnlocked) return false;
    
    // アンロック条件のチェック
    // 1. 国家予算ポイント (50)
    if (user!.budgetCoins < 50) return false;
    
    // 2. 日本首脳のレベル (Lv3以上)
    final jpLeader = politicians.firstWhere((pol) => pol.id == 'jp_leader');
    if (jpLeader.intimacyLevel < 3) return false;
    
    // 条件達成: 予算を消費してアンロック
    user!.budgetCoins -= 50;
    p.isUnlocked = true;
    await _repository.saveUserProfile(user!);
    await _repository.savePoliticians(politicians);
    notifyListeners();
    return true;
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
