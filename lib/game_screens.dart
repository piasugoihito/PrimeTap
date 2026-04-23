import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'game_models.dart';
import 'main_navigation.dart';
import 'audio_manager.dart';
import 'theme.dart';
import 'infinite_world_map.dart';
import 'main.dart';

class WorldMapScreen extends StatelessWidget {
  final bool isTab;
  const WorldMapScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('世界地図', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isTab ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StartScreen()),
            (route) => false,
          ),
        ),
      ),
      body: const InfiniteWorldMap(),
    );
  }
}

class MyPoliticiansScreen extends StatelessWidget {
  final bool isTab;
  const MyPoliticiansScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final unlockedPoliticians = controller.politicians.where((p) => p.isUnlocked).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('マイ政治家一覧', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StartScreen()),
            (route) => false,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: unlockedPoliticians.length,
        itemBuilder: (context, index) {
          final p = unlockedPoliticians[index];
          return _MyPoliticianCard(politician: p);
        },
      ),
    );
  }
}

class _MyPoliticianCard extends StatelessWidget {
  final Politician politician;
  const _MyPoliticianCard({required this.politician});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final isSelected = controller.selectedPolitician?.id == politician.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isSelected ? const BorderSide(color: AppTheme.deepCyan, width: 2) : BorderSide.none,
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          controller.selectPolitician(politician);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 0)),
            (route) => false,
          );
        },
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
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(politician.name, style: AppTheme.glossyTextStyle(fontSize: 18, color: Colors.black87)),
                    Text(politician.country, style: TextStyle(color: Colors.grey[600])),
                    Text('Lv: ${politician.intimacyLevel} | ${politician.politicianPoints} pt', 
                      style: const TextStyle(color: AppTheme.deepCyan, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppTheme.deepCyan)
              else
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemsScreen extends StatelessWidget {
  final bool isTab;
  const ItemsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('アイテム', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StartScreen()),
              (route) => false,
            ),
          ),
          bottom: TabBar(
            labelColor: AppTheme.deepCyan,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.deepCyan,
            tabs: const [
              Tab(text: 'ガチャ'),
              Tab(text: '取得済み'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GachaTab(),
            _OwnedItemsTab(),
          ],
        ),
      ),
    );
  }
}

class _OwnedItemsTab extends StatelessWidget {
  const _OwnedItemsTab();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final ownedItems = controller.items.where((i) => i.isOwned).toList();

    if (ownedItems.isEmpty) {
      return const Center(child: Text('まだアイテムを持っていません'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ownedItems.length,
      itemBuilder: (context, index) {
        final item = ownedItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.policy, color: AppTheme.deepCyan),
            title: Text(item.name),
            subtitle: Text('効率UP: +${(item.efficiencyBoost * 100).toStringAsFixed(1)}%'),
          ),
        );
      },
    );
  }
}

class _GachaTab extends StatefulWidget {
  const _GachaTab();

  @override
  State<_GachaTab> createState() => _GachaTabState();
}

class _GachaTabState extends State<_GachaTab> {
  bool _isSpinning = false;
  GameItem? _result;

  void _pullGacha() async {
    final controller = context.read<GameController>();
    if ((controller.user?.budgetCoins ?? 0) < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('国家予算が足りません（100必要）')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    AudioManager().playSE('se_gacha_spinning.mp3');
    
    final result = await controller.tryGacha();
    
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSpinning = false;
        _result = result;
      });

      if (result != null) {
        AudioManager().playSE('se_gacha_success.mp3');
      } else {
        AudioManager().playSE('se_gacha_fail.mp3');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('国家予算: ${controller.user?.budgetCoins.toStringAsFixed(0) ?? 0}', 
            style: AppTheme.glossyTextStyle(fontSize: 24, color: AppTheme.deepCyan)),
          const SizedBox(height: 40),
          AnimatedRotation(
            turns: _isSpinning ? 5 : 0,
            duration: const Duration(seconds: 2),
            child: Image.asset('assets/images/gacha_body.png', width: 200),
          ),
          const SizedBox(height: 40),
          if (!_isSpinning)
            GlossyButton(
              label: 'ガチャを回す (100)',
              onTap: _pullGacha,
            ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Text('当たり！: ${_result!.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
          ] else if (!_isSpinning && _result == null && controller.user != null) ...[
             // ハズレ演出はAudioManagerで音を出しているのでテキストは控えめに
          ],
        ],
      ),
    );
  }
}
