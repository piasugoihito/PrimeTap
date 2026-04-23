import 'package:flutter/material.dart';
import 'game_models.dart';
import 'game_controller.dart';
import 'audio_manager.dart';
import 'theme.dart';
import 'package:provider/provider.dart';
import 'main_navigation.dart';

class InfiniteWorldMap extends StatefulWidget {
  const InfiniteWorldMap({super.key});

  @override
  State<InfiniteWorldMap> createState() => _InfiniteWorldMapState();
}

class _InfiniteWorldMapState extends State<InfiniteWorldMap> {
  // マップの基本サイズ
  final double mapWidth = 1200.0;
  final double mapHeight = 600.0;

  // 現在のオフセット
  double offsetX = 0.0;
  double offsetY = 0.0;

  // 表か裏か
  bool isFront = true;

  // ピンのデータ（表マップ基準の座標）
  final List<MapPinData> pins = [
    MapPinData(country: '日本', x: 1050, y: 200),
    MapPinData(country: 'アメリカ', x: 250, y: 250),
    MapPinData(country: 'イギリス', x: 580, y: 150),
    MapPinData(country: 'フランス', x: 600, y: 200),
    MapPinData(country: 'イタリア', x: 630, y: 230),
    MapPinData(country: 'ロシア', x: 850, y: 120),
    MapPinData(country: 'メキシコ', x: 250, y: 350),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              offsetX += details.delta.dx;
              offsetY += details.delta.dy;

              // 左右ループ
              if (offsetX > 0) offsetX -= mapWidth;
              if (offsetX < -mapWidth) offsetX += mapWidth;

              // 上下ループ（表裏切り替え）
              if (offsetY > 0) {
                offsetY = -mapHeight + offsetY;
                isFront = !isFront;
              } else if (offsetY < -mapHeight) {
                offsetY = mapHeight + offsetY;
                isFront = !isFront;
              }
            });
          },
          child: Container(
            color: Colors.blue[100],
            child: ClipRect(
              child: Stack(
                children: [
                  // メインマップ
                  _buildMapImage(offsetX, offsetY, isFront),
                  // 左右の補完
                  _buildMapImage(offsetX + mapWidth, offsetY, isFront),
                  _buildMapImage(offsetX - mapWidth, offsetY, isFront),
                  
                  // 上下の補完（裏表逆）
                  _buildMapImage(offsetX, offsetY + mapHeight, !isFront),
                  _buildMapImage(offsetX, offsetY - mapHeight, !isFront),
                  
                  // 斜めの補完（裏表逆）
                  _buildMapImage(offsetX + mapWidth, offsetY + mapHeight, !isFront),
                  _buildMapImage(offsetX - mapWidth, offsetY + mapHeight, !isFront),
                  _buildMapImage(offsetX + mapWidth, offsetY - mapHeight, !isFront),
                  _buildMapImage(offsetX - mapWidth, offsetY - mapHeight, !isFront),

                  // ピンの描画
                  ..._buildPins(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapImage(double x, double y, bool front) {
    return Positioned(
      left: x,
      top: y,
      child: Image.asset(
        front ? 'assets/images/world_map_front.webp' : 'assets/images/world_map_back.webp',
        width: mapWidth,
        height: mapHeight,
        fit: BoxFit.fill,
      ),
    );
  }

  List<Widget> _buildPins() {
    List<Widget> pinWidgets = [];
    
    for (var pin in pins) {
      if (isFront) {
        pinWidgets.add(_buildSinglePin(pin, offsetX, offsetY));
        pinWidgets.add(_buildSinglePin(pin, offsetX + mapWidth, offsetY));
        pinWidgets.add(_buildSinglePin(pin, offsetX - mapWidth, offsetY));
      }
    }
    return pinWidgets;
  }

  Widget _buildSinglePin(MapPinData pin, double x, double y) {
    return Positioned(
      left: x + pin.x,
      top: y + pin.y,
      child: GestureDetector(
        onTap: () => _showCatalog(context, pin.country),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.glossyDecoration(color: Colors.redAccent),
              child: const Icon(Icons.location_on, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(pin.country, style: AppTheme.glossyTextStyle(fontSize: 14, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCatalog(BuildContext context, String country) {
    AudioManager().playSE('se_menu_open.mp3');
    final politicians = context.read<GameController>().politicians.where((p) => p.country == country).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            Text('$country の政治家', style: AppTheme.glossyTextStyle(fontSize: 20, color: AppTheme.deepCyan)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: politicians.length,
                itemBuilder: (context, index) {
                  final p = politicians[index];
                  return _PoliticianCard(politician: p);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPinData {
  final String country;
  final double x;
  final double y;
  MapPinData({required this.country, required this.x, required this.y});
}

class _PoliticianCard extends StatelessWidget {
  final Politician politician;
  const _PoliticianCard({required this.politician});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final isUnlocked = politician.isUnlocked;
    
    // 日本首脳のレベルを確認
    final jpLeader = controller.politicians.firstWhere((p) => p.id == 'jp_leader');
    final canUnlock = (controller.user?.budgetCoins ?? 0) >= 50 && jpLeader.intimacyLevel >= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: InkWell(
        onTap: isUnlocked ? () {
          controller.selectPolitician(politician);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
            (route) => false,
          );
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  politician.faceImages[0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  color: isUnlocked ? null : Colors.black54,
                  colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(politician.name, style: AppTheme.glossyTextStyle(fontSize: 18, color: Colors.black87)),
                    Text('レアリティ: ${politician.rarity.name.toUpperCase()}', style: TextStyle(color: Colors.grey[600])),
                    if (isUnlocked) ...[
                      Text('Lv: ${politician.intimacyLevel} | ${politician.politicianPoints} pt', 
                        style: const TextStyle(color: AppTheme.deepCyan, fontWeight: FontWeight.bold)),
                    ] else ...[
                      const Text('未解放', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ],
                ),
              ),
              if (!isUnlocked)
                ElevatedButton(
                  onPressed: () {
                    if (canUnlock) {
                      controller.unlockPolitician(politician);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('解放条件: 国家予算50 & 日本首脳Lv3')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canUnlock ? AppTheme.deepCyan : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('解放'),
                )
              else
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
