import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_models.dart';

class GameRepository {
  static const String _userKey = 'user_profile';
  static const String _politiciansKey = 'politicians_list';
  static const String _itemsKey = 'items_list';

  Future<void> saveUserProfile(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<void> savePoliticians(List<Politician> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((p) => p.toJson()).toList();
    await prefs.setString(_politiciansKey, jsonEncode(data));
  }

  Future<List<Politician>> loadPoliticians() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_politiciansKey);
    if (data == null) return _generateInitialPoliticians();
    final List<dynamic> list = jsonDecode(data);
    return list.map((p) => Politician.fromJson(p)).toList();
  }

  Future<void> saveItems(List<GameItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((i) => i.toJson()).toList();
    await prefs.setString(_itemsKey, jsonEncode(data));
  }

  Future<List<GameItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_itemsKey);
    if (data == null) return _generateInitialItems();
    final List<dynamic> list = jsonDecode(data);
    return list.map((i) => GameItem.fromJson(i)).toList();
  }

  List<Politician> _generateInitialPoliticians() {
    return [
      Politician(
        id: 'jp_01',
        name: 'タナカ',
        country: '日本',
        rarity: Rarity.low,
        odds: 1.2,
        isUnlocked: true,
        faceImages: ['assets/images/pol_jp_01_lv1.png'],
      ),
      Politician(
        id: 'usa_01',
        name: 'スミス',
        country: 'アメリカ',
        rarity: Rarity.medium,
        odds: 2.5,
        faceImages: ['assets/images/pol_usa_01_lv1.png'],
      ),
    ];
  }

  List<GameItem> _generateInitialItems() {
    return List.generate(100, (index) => GameItem(
      id: 'item_${index.toString().padLeft(3, '0')}',
      name: 'アイテム ${index + 1}',
      description: 'タップ効率が上昇するアイテムです。',
      efficiencyBoost: 0.05,
    ));
  }

  Future<GameItem?> performGacha(UserProfile user, List<GameItem> allItems) async {
    final unownedItems = allItems.where((i) => !i.isOwned).toList();
    if (unownedItems.isEmpty) return null;
    
    // 10%の確率で当たり
    final isWin = (DateTime.now().millisecond % 10) == 0;
    if (isWin) {
      unownedItems.shuffle();
      return unownedItems.first;
    }
    return null;
  }
}
