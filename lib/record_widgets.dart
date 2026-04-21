import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'theme.dart';

class RecordDashboard extends StatelessWidget {
  const RecordDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final user = controller.user;

    if (user == null) return const Scaffold(body: Center(child: Text('データがありません')));

    return Scaffold(
      backgroundColor: AppTheme.lightCyan,
      appBar: AppBar(
        title: Text('記録', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatCard(title: '累計タップ回数', value: '${user.totalTaps} 回'),
            _StatCard(title: '累計獲得ポイント', value: '${user.totalPoints} pt'),
            _StatCard(title: '最高タップ速度', value: '${user.maxTapSpeed.toStringAsFixed(1)} taps/s'),
            _StatCard(title: 'タップ効率', value: 'x${user.tapEfficiency.toStringAsFixed(2)}'),
            _StatCard(title: '国家予算', value: '${user.budgetCoins.toStringAsFixed(0)} コイン'),
            const SizedBox(height: 20),
            const Text('統計グラフ (実装予定)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepCyan)),
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyan[200]!),
              ),
              child: const Center(child: Text('グラフ表示エリア', style: TextStyle(color: Colors.grey))),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
      ),
    );
  }
}
