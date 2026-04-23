import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'game_models.dart';
import 'audio_manager.dart';
import 'theme.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 以前のTrainingScreenは、現在はMainNavigationScreenの初期タブとして機能する
    // 直接ここに来る場合は、MainNavigationScreenでラップして表示する
    return const TrainingContent();
  }
}

class TrainingContent extends StatefulWidget {
  const TrainingContent({super.key});

  @override
  State<TrainingContent> createState() => _TrainingContentState();
}

class _TrainingContentState extends State<TrainingContent> with SingleTickerProviderStateMixin {
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
    AudioManager().playSE('se_tap.mp3').catchError((_) {});
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('育成', style: AppTheme.glossyTextStyle(color: Colors.cyan[900]!)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.deepCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppTheme.glossyDecoration(color: Colors.white, borderRadius: 15),
                child: Row(
                  children: [
                    Image.asset('assets/images/coin.png', width: 20),
                    const SizedBox(width: 4),
                    Text(
                      user.budgetCoins.toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // UI以外をタップした時に無効音を流す
              AudioManager().playSE('無効音.mp3').catchError((_) {});
            },
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              Text(
                politician.name,
                style: AppTheme.glossyTextStyle(fontSize: 28, color: Colors.cyan[900]!),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: AppTheme.glossyDecoration(color: AppTheme.primaryCyan, borderRadius: 20, showShadow: false),
                    child: Text(
                      '親密度レベル: ${politician.intimacyLevel}', 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: AppTheme.glossyDecoration(color: Colors.orangeAccent, borderRadius: 20, showShadow: false),
                    child: Text(
                      '速度: ${controller.currentTapSpeed}', 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: _onTap,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 発光エフェクト
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryCyan.withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // キャラクター画像（レベルに応じて変化）
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 5),
                          image: DecorationImage(
                            image: AssetImage(politician.currentFaceImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // 鏡面反射オーバーレイ
                      IgnorePointer(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0.0),
                                Colors.black.withValues(alpha: 0.05),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: AppTheme.glossyDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: 15),
                child: Column(
                  children: [
                    Text(
                      '総タップポイント: ${politician.politicianPoints}',
                      style: AppTheme.glossyTextStyle(fontSize: 22, color: Colors.cyan[800]!),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '（総タップ回数: ${politician.politicianTaps}）',
                      style: TextStyle(fontSize: 14, color: Colors.cyan[600]!),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
