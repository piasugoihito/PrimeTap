import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'record_widgets.dart';
import 'training_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController()..initialize(),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          primary: Colors.cyan,
          secondary: Colors.cyanAccent,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE0F7FA),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final controller = context.read<GameController>();
    if (controller.user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InitialSetupScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GameSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, size: 100, color: Colors.cyan),
            const SizedBox(height: 20),
            Text(
              'PrimeTap',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.cyan[800],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.cyan),
          ],
        ),
      ),
    );
  }
}

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _nameController = TextEditingController();
  String _selectedCountry = '日本';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('初期設定'), backgroundColor: Colors.cyan[100]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ユーザー名'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              items: ['日本', 'アメリカ'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCountry = val!),
              decoration: const InputDecoration(labelText: '所属国家'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  await context.read<GameController>().createUser(_nameController.text, _selectedCountry);
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GameSelectionScreen()),
                    );
                  }
                }
              },
              child: const Text('ゲーム開始'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.cyan[200],
            child: const Center(child: Icon(Icons.account_balance, size: 120, color: Colors.white)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MenuButton(
                    label: '育成',
                    icon: Icons.trending_up,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingScreen())),
                  ),
                  const SizedBox(height: 20),
                  _MenuButton(
                    label: '記録',
                    icon: Icons.bar_chart,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordDashboard())),
                  ),
                  const SizedBox(height: 20),
                  _MenuButton(
                    label: '免責事項',
                    icon: Icons.info_outline,
                    onPressed: () {
                      showAboutDialog(context: context, applicationName: 'PrimeTap', children: [const Text('このゲームはフィクションです。')]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.cyan[800],
          side: BorderSide(color: Colors.cyan[800]!, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
