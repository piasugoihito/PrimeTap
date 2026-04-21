import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'game_models.dart';
import 'theme.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('世界地図', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
        backgroundColor: AppTheme.lightCyan,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: InteractiveViewer(
        constrained: false,
        child: Stack(
          children: [
            Container(
              width: 1200,
              height: 800,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.blue[100]!, Colors.blue[300]!],
                  center: Alignment.center,
                  radius: 1.5,
                ),
              ),
            ),
            _CountryPin(top: 250, left: 850, country: '日本'),
            _CountryPin(top: 350, left: 300, country: 'アメリカ'),
            _CountryPin(top: 220, left: 550, country: 'イギリス'),
            _CountryPin(top: 280, left: 580, country: 'フランス'),
            _CountryPin(top: 320, left: 610, country: 'イタリア'),
            _CountryPin(top: 180, left: 750, country: 'ロシア'),
            _CountryPin(top: 450, left: 250, country: 'メキシコ'),
          ],
        ),
      ),
    );
  }
}

class _CountryPin extends StatelessWidget {
  final double top;
  final double left;
  final String country;

  const _CountryPin({required this.top, required this.left, required this.country});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => _showCatalog(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.glossyDecoration(color: Colors.redAccent),
              child: const Icon(Icons.location_on, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 4),
            Text(country, style: AppTheme.glossyTextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  void _showCatalog(BuildContext context) {
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
            Text('$countryの政治家カタログ', style: AppTheme.glossyTextStyle(fontSize: 20, color: AppTheme.deepCyan)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
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

class _PoliticianCard extends StatelessWidget {
  final Politician politician;
  const _PoliticianCard({required this.politician});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glossyDecoration(
        color: politician.isUnlocked ? Colors.white : Colors.grey[200]!,
        showShadow: true,
      ),
      child: ListTile(
        leading: ClipOval(
          child: Image.asset(
            politician.currentFaceImage,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(politician.name, style: AppTheme.glossyTextStyle(color: Colors.black87, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('レベル: ${politician.intimacyLevel}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
            Text('総ポイント: ${politician.politicianPoints}', style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        trailing: politician.isUnlocked
            ? const Icon(Icons.check_circle, color: AppTheme.primaryCyan, size: 30)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCyan,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    onPressed: () async {
                      bool success = await controller.unlockPolitician(politician);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('解放条件: 予算50 & 日本首脳Lv3')),
                        );
                      }
                    },
                    child: const Text('解放', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const Text('予算50/日Lv3', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('アイテム', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
          backgroundColor: AppTheme.lightCyan,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryCyan,
            labelColor: AppTheme.primaryCyan,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: 'ガチャ'), Tab(text: 'コレクション')],
          ),
        ),
        body: const TabBarView(children: [GachaTab(), OwnedItemsTab()]),
      ),
    );
  }
}

class GachaTab extends StatefulWidget {
  const GachaTab({super.key});

  @override
  State<GachaTab> createState() => _GachaTabState();
}

class _GachaTabState extends State<GachaTab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSpinning = false;
  GameItem? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playGacha() async {
    if (_isSpinning) return;
    final controller = context.read<GameController>();
    if (controller.user!.budgetCoins < 100) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    await _controller.forward(from: 0);
    final res = await controller.tryGacha();

    setState(() {
      _isSpinning = false;
      _result = res;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _result = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: Image.asset('assets/images/gacha_body.png', width: 250),
              ),
              const SizedBox(height: 40),
              Text('国家予算: ${controller.user?.budgetCoins.toStringAsFixed(0)}', style: AppTheme.glossyTextStyle(color: Colors.black87)),
              const SizedBox(height: 20),
              GlossyButton(label: 'ガチャを引く (100)', onTap: _playGacha),
            ],
          ),
        ),
        if (_result != null) _buildResultOverlay(true),
        if (!_isSpinning && _result == null && controller.user!.budgetCoins < 100) _buildResultOverlay(false),
      ],
    );
  }

  Widget _buildResultOverlay(bool isWin) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWin) ...[
              Image.asset('assets/images/item_generic.png', width: 200),
              const SizedBox(height: 20),
              Text('政策採択!', style: AppTheme.glossyTextStyle(fontSize: 32, color: Colors.white)),
              Text(_result!.name, style: AppTheme.glossyTextStyle(fontSize: 24, color: AppTheme.lightCyan)),
              const SizedBox(height: 10),
              Text('タップ効率が上昇しました', style: const TextStyle(color: Colors.white70)),
            ] else ...[
              Image.asset('assets/images/coin.png', width: 150),
              const SizedBox(height: 20),
              Text('不採択...', style: AppTheme.glossyTextStyle(fontSize: 32, color: Colors.white)),
              Text('予算50ポイント返却', style: AppTheme.glossyTextStyle(fontSize: 24, color: Colors.orangeAccent)),
            ],
          ],
        ),
      ),
    );
  }
}

class OwnedItemsTab extends StatelessWidget {
  const OwnedItemsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<GameController>().items.where((i) => i.isOwned).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: AppTheme.glossyDecoration(color: Colors.white),
          child: ListTile(
            leading: Image.asset('assets/images/item_generic.png', width: 40),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('効率UP: +${(item.efficiencyBoost * 100).toStringAsFixed(0)}%'),
          ),
        );
      },
    );
  }
}

class MyPoliticiansScreen extends StatelessWidget {
  const MyPoliticiansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final politicians = context.watch<GameController>().politicians.where((p) => p.isUnlocked).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('マイ政治家', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
        backgroundColor: AppTheme.lightCyan,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: politicians.length,
        itemBuilder: (context, index) {
          final p = politicians[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: AppTheme.glossyDecoration(color: Colors.white),
            child: ListTile(
              leading: ClipOval(
                child: Image.asset(
                  p.currentFaceImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('レベル: ${p.intimacyLevel}', style: const TextStyle(fontSize: 12)),
                  Text('総ポイント: ${p.politicianPoints}', style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              onTap: () {
                context.read<GameController>().selectPolitician(p);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
