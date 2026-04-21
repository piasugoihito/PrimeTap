import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_controller.dart';
import 'punipuni_painter.dart';
import 'theme.dart';
import 'game_screens.dart';

class TrainingScreen extends StatefulWidget { const TrainingScreen({super.key});
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> with TickerProviderStateMixin {
  late AnimationController _puniController;
  Offset? _tapPosition;
  bool _isTouching = false;
  ui.Image? _cachedImage;

  @override
  void initState() {
    super.initState();
    _puniController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _puniController.dispose();
    super.dispose();
  }

  Future<void> _loadImage(String path) async {
    final completer = Completer<ui.Image>();
    final image = AssetImage(path);
    final stream = image.resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((info, _) {
      completer.complete(info.image);
    }));
    _cachedImage = await completer.future;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final pol = controller.activePolitician;

    if (pol != null && _cachedImage == null) {
      _loadImage(pol.faceImages[0]);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      _tapPosition = details.localPosition;
                      _isTouching = true;
                    });
                    _puniController.forward(from: 0.0);
                    controller.handleTap(details.globalPosition);
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _isTouching = false;
                    });
                    _puniController.animateTo(1.0, curve: Curves.elasticOut);
                  },
                  child: Container(
                    width: 300,
                    height: 300,
                    child: _cachedImage == null
                        ? CircularProgressIndicator()
                        : AnimatedBuilder(
                            animation: _puniController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: PuniPuniPainter(
                                  image: _cachedImage!,
                                  tapPosition: _tapPosition,
                                  deformation: _puniController.value,
                                  isTouching: _isTouching,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
            _buildBottomMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(GameController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TekaTekaContainer(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '予算: ${controller.user?.budgetCoins.toInt()} 🪙',
              style: AppTheme.bodyStyle.copyWith(color: Colors.white),
            ),
          ),
          TekaTekaContainer(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ポイント: ${controller.activePolitician?.politicianTaps.toInt()}',
              style: AppTheme.bodyStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomMenu(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _menuIcon(Icons.map, '世界地図', () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorldMapScreen()))),
          _menuIcon(Icons.people, 'マイ政治家', () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyPoliticiansScreen()))),
          _menuIcon(Icons.shopping_bag, 'アイテム', () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemScreen()))),
        ],
      ),
    );
  }

  Widget _menuIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryCyan, size: 30),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
