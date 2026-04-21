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
              'assets/images/bg_title_start.png',
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
                  const Spacer(flex: 1),
                  // タイトルロゴ画像
                  Image.asset(
                    'assets/images/title_logo.png',
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(flex: 4),
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
                          content: const SingleChildScrollView(
                            child: Text(
                              '1. 本アプリはエンターテインメントを目的としたフィクションであり、実在の人物、団体、国、政治的出来事とは一切関係ありません。\\n\\n'
                              '2. アプリ内で使用されている画像や名称は、特定の個人を誹謗中傷したり、政治的意図を持って使用されているものではありません。\\n\\n'
                              '3. 本アプリの利用によって生じた損害について、開発者は一切の責任を負いません。\\n\\n'
                              '4. アプリ内のコンテンツは予告なく変更・削除される場合があります。',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('承諾して閉じる'),
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
