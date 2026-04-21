import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color deepCyan = Color(0xFF00B8D4);
  static const Color neonCyan = Color(0xFF18FFFF);
  static const Color backgroundBlue = Color(0xFFE1F5FE);

  static BoxDecoration get tekaTekaDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.8),
        primaryCyan,
        deepCyan,
      ],
      stops: [0.0, 0.4, 1.0],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryCyan.withOpacity(0.5),
        blurRadius: 15,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.4),
        offset: Offset(-4, -4),
        blurRadius: 10,
      ),
    ],
  );

  static BoxDecoration get neonButtonDecoration => BoxDecoration(
    color: primaryCyan,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: neonCyan.withOpacity(0.8),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  );

  static TextStyle get titleStyle => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  static TextStyle get bodyStyle => TextStyle(
    fontSize: 16,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
  );
}

class TekaTekaContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const TekaTekaContainer({super.key, 
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: AppTheme.tekaTekaDecoration,
      child: Stack(
        children: [
          // 鏡面反射ハイライト
          Positioned(
            top: 5,
            left: 10,
            child: Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
