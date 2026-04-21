import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('世界地図'), backgroundColor: Colors.cyan[100]),
      body: InteractiveViewer(
        constrained: false,
        child: Stack(
          children: [
            // 実際には大きな地図画像
            Container(width: 1000, height: 800, color: Colors.blue[50]),
            _CountryPin(top: 200, left: 700, country: '日本'),
            _CountryPin(top: 300, left: 200, country: 'アメリカ'),
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
            const Icon(Icons.location_on, color: Colors.red, size: 40),
            Text(country, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showCatalog(BuildContext context) {
    final politicians = context.read<GameController>().politicians.where((p) => p.country == country).toList();
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        itemCount: politicians.length,
        itemBuilder: (context, index) {
          final p = politicians[index];
          return ListTile(
            leading: const CircleAvatar(child: Text('👤')),
            title: Text(p.name),
            subtitle: Text('レアリティ: ${p.rarity.name}'),
            trailing: p.isUnlocked ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.lock),
          );
        },
      ),
    );
  }
}

class MyPoliticiansScreen extends StatelessWidget {
  const MyPoliticiansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final politicians = context.watch<GameController>().politicians.where((p) => p.isUnlocked).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('マイ政治家'), backgroundColor: Colors.cyan[100]),
      body: ListView.builder(
        itemCount: politicians.length,
        itemBuilder: (context, index) {
          final p = politicians[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const CircleAvatar(child: Text('👤')),
              title: Text(p.name),
              subtitle: Text('累計タップ: ${p.politicianTaps}'),
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

class ItemScreen extends StatelessWidget {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('アイテム'),
          backgroundColor: Colors.cyan[100],
          bottom: const TabBar(tabs: [Tab(text: 'ガチャ'), Tab(text: '取得済み')]),
        ),
        body: const TabBarView(children: [GachaTab(), OwnedItemsTab()]),
      ),
    );
  }
}

class GachaTab extends StatelessWidget {
  const GachaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.card_giftcard, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          Text('予算: ${controller.user?.budgetCoins.toStringAsFixed(0)} コイン'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final result = await controller.tryGacha();
              if (context.mounted) {
                if (result != null) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('当たり！'),
                      content: Text('${result.name} を獲得しました！\n効率が ${(result.efficiencyBoost * 100).toStringAsFixed(0)}% 上昇しました。'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('残念！外れました。')));
                }
              }
            },
            child: const Text('ガチャを引く (100コイン)'),
          ),
        ],
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.cyan),
          title: Text(item.name),
          subtitle: Text('効率UP: +${(item.efficiencyBoost * 100).toStringAsFixed(0)}%'),
        );
      },
    );
  }
}
