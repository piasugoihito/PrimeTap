import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'game_models.dart';
import 'theme.dart';

class WorldMapScreen extends StatelessWidget { const WorldMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    return Scaffold(
      appBar: AppBar(title: Text('世界地図', style: AppTheme.titleStyle), backgroundColor: AppTheme.primaryCyan),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: 1000,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/bg_start.png'), fit: BoxFit.cover, opacity: 0.3),
          ),
          child: Stack(
            children: [
              _buildCountryPin(context, controller, '日本', 100, 200),
              _buildCountryPin(context, controller, 'アメリカ', 600, 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryPin(BuildContext context, GameController controller, String country, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _showCountryCatalog(context, controller, country),
        child: Column(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 40),
            TekaTekaContainer(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(country, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryCatalog(BuildContext context, GameController controller, String country) {
    final countryPols = controller.politicians.where((p) => p.country == country).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: ListView.builder(
          itemCount: countryPols.length,
          itemBuilder: (context, index) {
            final p = countryPols[index];
            return ListTile(
              leading: Image.asset(p.faceImages[0], width: 50),
              title: Text(p.name, style: AppTheme.bodyStyle),
              subtitle: Text('Tier: ${p.tier} | Rarity: ${p.rarity.name}'),
              trailing: p.isUnlocked 
                ? Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    onPressed: controller.canUnlock(p) ? () => controller.unlockPolitician(p) : null,
                    child: Text('アンロック'),
                  ),
            );
          },
        ),
      ),
    );
  }
}

class MyPoliticiansScreen extends StatelessWidget { const MyPoliticiansScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final unlocked = controller.politicians.where((p) => p.isUnlocked).toList();
    return Scaffold(
      appBar: AppBar(title: Text('マイ政治家', style: AppTheme.titleStyle), backgroundColor: AppTheme.primaryCyan),
      body: ListView.builder(
        itemCount: unlocked.length,
        itemBuilder: (context, index) {
          final p = unlocked[index];
          return Card(
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Image.asset(p.faceImages[0], width: 50),
              title: Text(p.name, style: AppTheme.bodyStyle),
              subtitle: Text('親密度: ${p.intimacyLevel} | ポイント: ${p.politicianTaps.toInt()}'),
              onTap: () {
                controller.setActivePolitician(p);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}

class ItemScreen extends StatefulWidget { const ItemScreen({super.key});
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> with TickerProviderStateMixin {
  bool _isGachaRunning = false;
  GameItem? _gachaResult;

  void _runGacha(GameController controller) async {
    setState(() {
      _isGachaRunning = true;
      _gachaResult = null;
    });

    // ガチャ演出（ハンドル回転を想定したウェイト）
    await Future.delayed(Duration(seconds: 2));
    
    final result = await controller.tryGacha();
    
    setState(() {
      _isGachaRunning = false;
      _gachaResult = result;
    });

    // 結果表示（タップで消える）
    if (mounted) {
      _showGachaResult(context, result);
    }
  }

  void _showGachaResult(BuildContext context, GameItem? result) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Material(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (result != null) ...[
                  Image.asset('assets/images/item_generic.png', width: 200),
                  SizedBox(height: 20),
                  Text('NEW ITEM!', style: AppTheme.titleStyle.copyWith(color: Colors.yellow)),
                  Text(result.name, style: AppTheme.titleStyle),
                ] else ...[
                  Image.asset('assets/images/coin.png', width: 150),
                  SizedBox(height: 20),
                  Text('MISS...', style: AppTheme.titleStyle.copyWith(color: Colors.grey)),
                  Text('コイン半分返却', style: AppTheme.bodyStyle.copyWith(color: Colors.white)),
                ],
                SizedBox(height: 40),
                Text('タップして閉じる', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    return Scaffold(
      appBar: AppBar(title: Text('アイテム・ガチャ', style: AppTheme.titleStyle), backgroundColor: AppTheme.primaryCyan),
      body: Column(
        children: [
          // ガチャセクション
          Container(
            height: 300,
            width: double.infinity,
            margin: EdgeInsets.all(16),
            decoration: AppTheme.tekaTekaDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/gacha_body.png', height: 150),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, shape: StadiumBorder()),
                  onPressed: _isGachaRunning ? null : () => _runGacha(controller),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: Text(_isGachaRunning ? '回転中...' : 'ガチャを引く (500🪙)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          // アイテム一覧
          Expanded(
            child: ListView.builder(
              itemCount: controller.items.where((i) => i.isOwned).length,
              itemBuilder: (context, index) {
                final item = controller.items.where((i) => i.isOwned).toList()[index];
                return ListTile(
                  leading: Image.asset('assets/images/item_generic.png', width: 40),
                  title: Text(item.name),
                  subtitle: Text('効率: +${(item.efficiencyBoost * 100).toInt()}%'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
