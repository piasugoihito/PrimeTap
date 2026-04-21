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
      user = await _repository.loadUserProfile();
      if (user == null) {
        user = UserProfile(name: '新人プレイヤー', homeCountry: '日本');
        await _repository.saveUserProfile(user!);
      }
      
      politicians = await _repository.loadPoliticians();
      if (politicians.isEmpty) {
        politicians = _repository._generateInitialPoliticians();
        await _repository.savePoliticians(politicians);
      }
      
      items = await _repository.loadItems();
      
      selectedPolitician = politicians.firstWhere(
        (p) => p.isUnlocked, 
        orElse: () => politicians.first
      );
    } catch (e) {
      debugPrint('Error during GameController initialization: $e');
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
            faceImages: ['assets/images/pol_jp_leader.png', 'assets/images/pol_jp_leader.png', 'assets/images/pol_jp_leader.png'],
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
    
    // 1. タップ回数の更新
    user!.totalTaps++;
    selectedPolitician!.politicianTaps++;
    
    // 2. ポイント計算: 1タップにつき 1ポイント × タップ効率
    int points = (1 * user!.tapEfficiency).toInt();
    user!.totalPoints += points;
    selectedPolitician!.politicianPoints += points;
    
    // 3. 国家予算（コイン）計算: 政治家のオッズ × 獲得ポイント
    double earnedCoins = points * selectedPolitician!.odds;
    user!.budgetCoins += earnedCoins;

    // 4. レベルアップロジック: 200タップごとにレベル上昇 (最大Lv3)
    int newLevel = (selectedPolitician!.politicianTaps / 200).floor() + 1;
    if (newLevel > 3) newLevel = 3;
    if (newLevel > selectedPolitician!.intimacyLevel) {
      selectedPolitician!.intimacyLevel = newLevel;
    }

    _repository.saveUserProfile(user!);
    _repository.savePoliticians(politicians);
    notifyListeners();
  }

  Future<bool> unlockPolitician(Politician p) async {
    if (user == null || p.isUnlocked) return false;
    
    // アンロック条件: 予算50ポイント & 日本首脳Lv3
    final jpLeader = politicians.firstWhere((pol) => pol.id == 'jp_leader');
    if (user!.budgetCoins >= 50 && jpLeader.intimacyLevel >= 3) {
      user!.budgetCoins -= 50;
      p.isUnlocked = true;
      await _repository.saveUserProfile(user!);
      await _repository.savePoliticians(politicians);
      notifyListeners();
      return true;
    }
    return false;
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
      // 外れ: 50コイン返却
      user!.budgetCoins += 50;
    }
    
    await _repository.saveUserProfile(user!);
    notifyListeners();
    return result;
  }
}

extension on GameRepository {
  List<Politician> _generateInitialPoliticians() {
    return [
      Politician(
        id: 'jp_leader',
        name: '日本首脳',
        country: '日本',
        rarity: Rarity.low,
        odds: 1.2,
        isUnlocked: true,
        faceImages: ['assets/images/pol_jp_leader.png', 'assets/images/pol_jp_leader.png', 'assets/images/pol_jp_leader.png'],
        tier: 0,
      ),
      Politician(
        id: 'usa_leader',
        name: 'アメリカ首脳',
        country: 'アメリカ',
        rarity: Rarity.medium,
        odds: 2.5,
        faceImages: ['assets/images/pol_usa_leader.png', 'assets/images/pol_usa_leader.png', 'assets/images/pol_usa_leader.png'],
        tier: 1,
        requiredPoliticianIds: ['jp_leader'],
      ),
      Politician(
        id: 'uk_leader',
        name: 'イギリス首脳',
        country: 'イギリス',
        rarity: Rarity.medium,
        odds: 2.5,
        faceImages: ['assets/images/pol_uk_leader.png', 'assets/images/pol_uk_leader.png', 'assets/images/pol_uk_leader.png'],
        tier: 1,
        requiredPoliticianIds: ['jp_leader'],
      ),
      Politician(
        id: 'fra_leader',
        name: 'フランス首脳',
        country: 'フランス',
        rarity: Rarity.medium,
        odds: 2.5,
        faceImages: ['assets/images/pol_fra_leader.png', 'assets/images/pol_fra_leader.png', 'assets/images/pol_fra_leader.png'],
        tier: 1,
        requiredPoliticianIds: ['jp_leader'],
      ),
      Politician(
        id: 'ita_leader',
        name: 'イタリア首脳',
        country: 'イタリア',
        rarity: Rarity.medium,
        odds: 2.5,
        faceImages: ['assets/images/pol_ita_leader.png', 'assets/images/pol_ita_leader.png', 'assets/images/pol_ita_leader.png'],
        tier: 1,
        requiredPoliticianIds: ['jp_leader'],
      ),
      Politician(
        id: 'rus_leader',
        name: 'ロシア首脳',
        country: 'ロシア',
        rarity: Rarity.high,
        odds: 3.5,
        faceImages: ['assets/images/pol_rus_leader.png', 'assets/images/pol_rus_leader.png', 'assets/images/pol_rus_leader.png'],
        tier: 1,
        requiredPoliticianIds: ['jp_leader'],
      ),
      Politician(
        id: 'mex_leader',
        name: 'メキシコ首脳',
        country: 'メキシコ',
        rarity: Rarity.high,
        odds: 3.5,
        faceImages: ['assets/images/pol_mex_leader.png', 'assets/images/pol_mex_leader.png', 'assets/images/pol_mex_leader.png'],
        tier: 1,
        requiredPoliticianIds: ['jp_leader'],
      ),
    ];
  }
}
