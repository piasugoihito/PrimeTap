import 'package:flutter/material.dart';
import 'audio_manager.dart';

class AppTheme {
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color deepCyan = Color(0xFF00B8D4);
  static const Color lightCyan = Color(0xFFE0F7FA);

  static BoxDecoration glossyDecoration({
    Color color = primaryCyan,
    double borderRadius = 20,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.8),
          color,
          color.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 2,
                spreadRadius: -1,
                offset: const Offset(-2, -2),
              ),
            ]
          : [],
    );
  }

  static TextStyle glossyTextStyle({
    double fontSize = 18,
    Color color = Colors.white,
    bool bold = true,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    );
  }
}

class GlossyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  const GlossyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 200,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioManager().playSE('se_tap.mp3');
        onTap();
      },
      child: Container(
        width: width,
        height: height,
        decoration: AppTheme.glossyDecoration(),
        child: Center(
          child: Text(
            label,
            style: AppTheme.glossyTextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }
}
