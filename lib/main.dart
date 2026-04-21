import 'dart:math' as math;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_banner.dart';
import 'game_controller.dart';
import 'game_models.dart';
import 'record_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    MobileAds.instance.initialize();
  }
  runApp(const MergeTapGameApp());
}

class MergeTapGameApp extends StatefulWidget {
  const MergeTapGameApp({super.key});

  @override
  State<MergeTapGameApp> createState() => _MergeTapGameAppState();
}

class _MergeTapGameAppState extends State<MergeTapGameApp> {
  late final GameController _controller;
  late final Future<void> _loader;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _loader = _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merge Tap Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B61FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F4FF),
        useMaterial3: true,
      ),
      home: FutureBuilder<void>(
        future: _loader,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashLoadingScreen();
          }
          return StartScreen(controller: _controller);
        },
      ),
    );
  }
}

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('ゲームデータを読み込み中...'),
          ],
        ),
      ),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final selectedCharacter = controller.selectedCharacter;

        return Scaffold(
          bottomNavigationBar: const ConditionalBannerAd(),
          appBar: AppBar(
            title: const Text('Merge Tap Game'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroCard(
                    character: selectedCharacter,
                    scale: controller.growthScaleFor(selectedCharacter),
                    totalTapPoints: state.totalTapPoints,
                    totalTapCount: state.totalTapCount,
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(
                    title: '記録',
                    subtitle: '完全ローカル保存の進行状況',
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        label: '総タップ回数',
                        value: '${state.totalTapCount}',
                        accent: const Color(0xFF7B61FF),
                      ),
                      _StatCard(
                        label: '総タップポイント',
                        value: '${state.totalTapPoints}',
                        accent: const Color(0xFF00B4D8),
                      ),
                      _StatCard(
                        label: '1タップあたり',
                        value: '${state.currentTapPower}',
                        accent: const Color(0xFFFF9F1C),
                      ),
                      _StatCard(
                        label: '強化アイテム',
                        value: '${state.upgradeItemCount}',
                        accent: const Color(0xFF2A9D8F),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle(
                    title: '詳細記録',
                    subtitle: 'カレンダーと日・月・年グラフ',
                  ),
                  const SizedBox(height: 12),
                  RecordDashboard(records: state.dailyRecords),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: 'キャラクター一覧',
                    subtitle:
                        '解放 ${state.unlockedCharacterIds.length} / ${controller.characters.length}（タップで選択）',
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: controller.characters
                        .map(
                          (character) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CharacterListTile(
                              character: character,
                              isUnlocked: controller.isUnlocked(character.id),
                              isSelected:
                                  character.id == state.selectedCharacterId,
                              currentTapPoints: state.totalTapPoints,
                              onTap: controller.isUnlocked(character.id)
                                  ? () => controller.selectCharacter(character.id)
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PlayScreen(controller: controller),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('プレイ開始'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobbleController;
  late final Animation<double> _wobbleAnimation;
  final List<DateTime> _tapMoments = <DateTime>[];
  String? _floatingGainText;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _wobbleAnimation = CurvedAnimation(
      parent: _wobbleController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final beforeCount = widget.controller.state.unlockedCharacterIds.length;
    final tapPower = widget.controller.state.currentTapPower;
    final now = DateTime.now();
    _tapMoments.add(now);
    _tapMoments.removeWhere(
      (moment) => now.difference(moment) > const Duration(seconds: 1),
    );
    final tapsPerSecond = _tapMoments.length.toDouble();

    await widget.controller.registerTap(tapsPerSecond);
    if (!mounted) {
      return;
    }

    setState(() {
      _floatingGainText = '+$tapPower';
    });

    _wobbleController
      ..reset()
      ..forward();

    final afterCount = widget.controller.state.unlockedCharacterIds.length;
    if (afterCount > beforeCount && mounted) {
      final latestId = widget.controller.state.unlockedCharacterIds.last;
      final latestCharacter = widget.controller.characters.firstWhere(
        (character) => character.id == latestId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${latestCharacter.name} が解放されました')),
      );
    }
  }

  Future<void> _handleUpgrade() async {
    final purchased = await widget.controller.purchaseUpgrade();
    if (!mounted) {
      return;
    }
    if (!purchased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('強化アイテムが足りません')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('タップパワーが上がりました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final character = widget.controller.selectedCharacter;
        final scale = widget.controller.growthScaleFor(character);
        final itemProgress = state.upgradeItemDropProgress / 12;

        return Scaffold(
          bottomNavigationBar: const ConditionalBannerAd(),
          appBar: AppBar(title: const Text('プレイ')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          character.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'タップポイント ${state.totalTapPoints} / タップ回数 ${state.totalTapCount}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _MiniStatChip(
                              label: '1タップ',
                              value: '${state.currentTapPower}',
                              color: const Color(0xFF7B61FF),
                            ),
                            _MiniStatChip(
                              label: '強化アイテム',
                              value: '${state.upgradeItemCount}',
                              color: const Color(0xFF2A9D8F),
                            ),
                            _MiniStatChip(
                              label: '速度',
                              value:
                                  '${widget.controller.latestTapsPerSecond.toStringAsFixed(1)} tps',
                              color: const Color(0xFFFF9F1C),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _handleTap,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _wobbleAnimation,
                              builder: (context, child) {
                                final wobble = math.sin(
                                      _wobbleAnimation.value * math.pi * 3,
                                    ) *
                                    0.08;
                                final squish = 1 + (_wobbleAnimation.value * 0.04);
                                return Transform.rotate(
                                  angle: wobble,
                                  child: Transform.scale(
                                    scale: squish,
                                    child: child,
                                  ),
                                );
                              },
                              child: _CharacterAvatar(
                                character: character,
                                scale: scale,
                                size: 180,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Text(
                                'タップし続けて育てよう',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (_floatingGainText case final gain?)
                              TweenAnimationBuilder<double>(
                                key: ValueKey<String>(
                                  '$gain-${state.totalTapCount}-${state.totalTapPoints}',
                                ),
                                tween: Tween(begin: 1, end: 0),
                                duration: const Duration(milliseconds: 420),
                                onEnd: () {
                                  if (mounted) {
                                    setState(() {
                                      _floatingGainText = null;
                                    });
                                  }
                                },
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, -70 * (1 - value)),
                                    child: Opacity(opacity: value, child: child),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    gain,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: const Color(0xFF7B61FF),
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '強化アイテムゲージ',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('${(itemProgress * 100).round()}%'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: itemProgress,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: _handleUpgrade,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              '強化アイテム ${state.upgradeItemCost} 個で 1タップ +1',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '12回タップするごとに強化アイテムを1個獲得します。キャラクターは累計タップポイントに応じて大きくなり、新しいキャラクターも解放されます。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.character,
    required this.scale,
    required this.totalTapPoints,
    required this.totalTapCount,
  });

  final GameCharacter character;
  final double scale;
  final int totalTapPoints;
  final int totalTapCount;

  @override
  Widget build(BuildContext context) {
    final color = Color(character.baseColorHex);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '現在のメインキャラ',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  character.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'タップポイント $totalTapPoints / 総タップ $totalTapCount',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          _CharacterAvatar(
            character: character,
            scale: scale,
            size: 110,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CharacterListTile extends StatelessWidget {
  const _CharacterListTile({
    required this.character,
    required this.isUnlocked,
    required this.isSelected,
    required this.currentTapPoints,
    required this.onTap,
  });

  final GameCharacter character;
  final bool isUnlocked;
  final bool isSelected;
  final int currentTapPoints;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(character.baseColorHex);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              _CharacterAvatar(
                character: character,
                scale: character.baseScale,
                size: 56,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked
                          ? '解放済み'
                          : '解放条件: ${character.unlockTapPoints} タップポイント',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? color.withValues(alpha: 0.14)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isUnlocked
                      ? (isSelected ? '選択中' : '使用可能')
                      : '${(currentTapPoints / character.unlockTapPoints * 100).clamp(0, 99).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: isUnlocked ? color : Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterAvatar extends StatelessWidget {
  const _CharacterAvatar({
    required this.character,
    required this.scale,
    required this.size,
  });

  final GameCharacter character;
  final double scale;
  final double size;

  @override
  Widget build(BuildContext context) {
    final avatarColor = Color(character.baseColorHex);
    return Transform.scale(
      scale: scale.clamp(0.8, 2.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              avatarColor.withValues(alpha: 0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: avatarColor.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _characterGlyph(character.id),
            style: TextStyle(fontSize: size * 0.38),
          ),
        ),
      ),
    );
  }

  String _characterGlyph(String id) {
    switch (id) {
      case 'slime':
        return '◉';
      case 'cat':
        return '◕';
      case 'bear':
        return '◆';
      case 'dragon':
        return '✦';
      case 'star':
        return '★';
      default:
        return '◉';
    }
  }
}
