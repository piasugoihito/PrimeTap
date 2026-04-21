import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'game_screens.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) => _animationController.reverse());
    context.read<GameController>().handleTap();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final politician = controller.selectedPolitician;
    final user = controller.user;

    if (politician == null || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('育成'),
        backgroundColor: Colors.cyan[100],
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '予算: ${user.budgetCoins.toStringAsFixed(0)} コイン',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            '${politician.name} (Lv.${politician.intimacyLevel})',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.cyan[900]),
          ),
          Text('所属: ${politician.country}'),
          const Spacer(),
          GestureDetector(
            onTap: _onTap,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getPoliticianEmoji(politician.id),
                    style: const TextStyle(fontSize: 120),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '累計タップ: ${politician.politicianTaps}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _BottomMenu(),
        ],
      ),
    );
  }

  String _getPoliticianEmoji(String id) {
    if (id.contains('jp')) return '🇯🇵';
    if (id.contains('us')) return '🇺🇸';
    return '👤';
  }
}

class _BottomMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MenuIcon(
            icon: Icons.map,
            label: '世界地図',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorldMapScreen())),
          ),
          _MenuIcon(
            icon: Icons.people,
            label: 'マイ政治家',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPoliticiansScreen())),
          ),
          _MenuIcon(
            icon: Icons.inventory,
            label: 'アイテム',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemScreen())),
          ),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.cyan[700]),
          Text(label, style: TextStyle(color: Colors.cyan[700], fontSize: 12)),
        ],
      ),
    );
  }
}
