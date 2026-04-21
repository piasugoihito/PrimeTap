import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'training_screen.dart';
import 'record_widgets.dart';
import 'theme.dart';

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

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_start.png',
              fit: BoxFit.cover,
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
                  const Spacer(flex: 2),
                  // タイトル（発光エフェクト）
                  Text(
                    'PrimeTap',
                    style: AppTheme.glossyTextStyle(
                      fontSize: 64,
                      color: Colors.white,
                    ).copyWith(
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '政治家育成タップゲーム',
                    style: AppTheme.glossyTextStyle(
                      fontSize: 20,
                      color: AppTheme.lightCyan,
                      bold: false,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // ボタン群
                  GlossyButton(
                    label: '育成を始める',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrainingScreen()),
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('免責事項'),
                          content: const Text('本アプリはフィクションであり、実在の人物・団体とは一切関係ありません。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('閉じる'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      '免責事項',
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
