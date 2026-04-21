import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_models.dart';

class GameRepository {
  static const String _userKey = 'primetap_user';
  static const String _politiciansKey = 'primetap_politicians';
  static const String _itemsKey = 'primetap_items';

  Future<void> saveUserProfile(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson());
  }

  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr == null) return null;
    return UserProfile.fromJson(jsonStr);
  }

  Future<void> savePoliticians(List<Politician> politicians) async {
    final prefs = await SharedPreferences.getInstance();
    final list = politicians.map((p) => p.toMap()).toList();
    await prefs.setString(_politiciansKey, jsonEncode(list));
  }

  Future<List<Politician>> loadPoliticians() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_politiciansKey);
    if (jsonStr == null) return _getDefaultPoliticians();
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((m) => Politician.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> saveItems(List<GameItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((i) => i.toMap()).toList();
    await prefs.setString(_itemsKey, jsonEncode(list));
  }

  Future<List<GameItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_itemsKey);
    if (jsonStr == null) return _getDefaultItems();
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((m) => GameItem.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  List<Politician> _getDefaultPoliticians() {
    return [
      Politician(
        id: 'jp_politician_1',
        name: '田中 太郎',
        country: '日本',
        rarity: Rarity.low,
        odds: 1.2,
        isUnlocked: true,
        faceImages: ['assets/images/jp_1_lv1.png', 'assets/images/jp_1_lv2.png', 'assets/images/jp_1_lv3.png'],
      ),
      Politician(
        id: 'us_politician_1',
        name: 'John Smith',
        country: 'アメリカ',
        rarity: Rarity.medium,
        odds: 2.5,
        faceImages: ['assets/images/us_1_lv1.png', 'assets/images/us_1_lv2.png', 'assets/images/us_1_lv3.png'],
      ),
    ];
  }

  List<GameItem> _getDefaultItems() {
    return List.generate(100, (index) {
      return GameItem(
        itemId: 'item_$index',
        name: '政策パッケージ $index',
        country: index % 2 == 0 ? '日本' : 'アメリカ',
        efficiencyBoost: 0.05 * (index % 5 + 1),
        dropRate: 0.01,
      );
    });
  }

  Future<GameItem?> performGacha(UserProfile user, List<GameItem> allItems) async {
    final unownedItems = allItems.where((i) => !i.isOwned).toList();
    if (unownedItems.isEmpty) return null;

    final random = Random();
    if (random.nextDouble() < 0.3) {
      final item = unownedItems[random.nextInt(unownedItems.length)];
      return item;
    }
    return null;
  }
}
