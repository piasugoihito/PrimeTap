import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'training_screen.dart';
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
        primaryColor: AppTheme.primaryCyan,
        scaffoldBackgroundColor: AppTheme.backgroundBlue,
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_start.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PrimeTap',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 60,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Version 3.0 Final Architecture',
                style: AppTheme.bodyStyle.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 100),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrainingScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        decoration: AppTheme.neonButtonDecoration,
        child: Text(
          'PLAY',
          style: AppTheme.titleStyle.copyWith(fontSize: 24),
        ),
      ),
    );
  }
}
