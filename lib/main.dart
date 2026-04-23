import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'training_screen.dart';
import 'main_navigation.dart';
import 'record_widgets.dart';
import 'disclaimer_screen.dart';
import 'audio_manager.dart';
import 'theme.dart';
import 'scrolling_background.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const PrimeTapApp(),
    ),
  );
}

class PrimeTapApp extends StatelessWidget {
  const PrimeTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrimeTap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: AppTheme.lightCyan,
        fontFamily: 'Roboto',
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    // BGMの再生開始
    AudioManager().playBGM();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      body: Stack(
        children: [
          // 背景画像（画面全体をカバー、最大幅に合わせる）
          SizedBox.expand(
            child: Container(
              color: Colors.black,
              child: Image.asset(
                'assets/images/bg_title_start.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          // オーバーレイ
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          // コンテンツ
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  // タイトルロゴ画像
                  Image.asset(
                    'assets/images/title_logo.png',
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(flex: 4),
                  // ボタン群
                  if (!controller.isInitialized)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    GlossyButton(
                      label: '育成を始める',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      ),
                    ),
                  const SizedBox(height: 20),
                  GlossyButton(
                    label: '記録を見る',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecordDashboard()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DisclaimerScreen()),
                    ),
                    child: Text(
                      '免責事項 (Disclaimer)',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
