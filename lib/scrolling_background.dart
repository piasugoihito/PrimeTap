import 'package:flutter/material.dart';

class ScrollingBackground extends StatefulWidget {
  final Widget child;
  const ScrollingBackground({super.key, required this.child});

  @override
  State<ScrollingBackground> createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<ScrollingBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 20秒かけて1サイクルするアニメーション
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景色（ライトブルー/シアン系）
        Container(color: const Color(0xFFE0F7FA)),
        
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // 背景画像をタイル状に配置し、オフセットをアニメーションさせる
                // 背景画像.webp を使用
                for (int i = -1; i <= 1; i++)
                  for (int j = -1; j <= 1; j++)
                    Positioned.fill(
                      child: FractionalTranslation(
                        translation: Offset(
                          i.toDouble() + _controller.value,
                          j.toDouble() + _controller.value,
                        ),
                        child: Opacity(
                          opacity: 0.3, // 背景が主張しすぎないように透明度を調整
                          child: Image.asset(
                            'assets/images/bg_pattern.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
        // メインコンテンツ
        widget.child,
      ],
    );
  }
}
