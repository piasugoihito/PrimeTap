import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'training_screen.dart';
import 'game_screens.dart';
import 'audio_manager.dart';
import 'theme.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // 同じタブをタップした場合は育成画面（インデックス0）に戻る
      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
        AudioManager().playSE('se_menu_open.mp3');
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
      AudioManager().playSE('se_menu_open.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const TrainingContent(),
      const WorldMapScreen(isTab: true),
      const MyPoliticiansScreen(isTab: true),
      const ItemsScreen(isTab: true),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MenuIcon(
                icon: Icons.fitness_center,
                label: '育成',
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _MenuIcon(
                icon: Icons.map,
                label: '世界地図',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _MenuIcon(
                icon: Icons.people,
                label: 'マイ政治家',
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _MenuIcon(
                icon: Icons.inventory,
                label: 'アイテム',
                isSelected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: AppTheme.glossyDecoration(
              color: isSelected ? AppTheme.primaryCyan : AppTheme.lightCyan,
              borderRadius: 15,
              showShadow: false,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.deepCyan,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.deepCyan,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
