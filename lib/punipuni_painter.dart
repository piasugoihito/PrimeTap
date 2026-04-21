import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PuniPuniPainter extends CustomPainter {
  final ui.Image image;
  final Offset? tapPosition;
  final double deformation; // 0.0 to 1.0
  final bool isTouching;

  PuniPuniPainter({
    required this.image,
    this.tapPosition,
    required this.deformation,
    required this.isTouching,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final int rows = 10;
    final int cols = 10;
    final double cellWidth = size.width / cols;
    final double cellHeight = size.height / rows;

    List<Offset> vertices = [];
    List<Offset> textureCoords = [];
    List<int> indices = [];

    for (int r = 0; r <= rows; r++) {
      for (int c = 0; c <= cols; c++) {
        double x = c * cellWidth;
        double y = r * cellHeight;
        
        Offset currentPoint = Offset(x, y);
        
        if (tapPosition != null) {
          double dist = (currentPoint - tapPosition!).distance;
          double radius = size.width * 0.4;
          
          if (dist < radius) {
            double force = (1.0 - dist / radius) * deformation;
            if (isTouching) {
              // Touch Down: 押し込み（放射状に広がる）
              Offset direction = (currentPoint - tapPosition!);
              if (direction.distance > 0) {
                currentPoint += direction / direction.distance * force * 20.0;
              }
            } else {
              // Touch Up: インパルス（Curves.elasticOut的な揺れ）
              double wave = sin(deformation * pi * 4) * force * 15.0;
              currentPoint += Offset(0, wave);
            }
          }
        }

        vertices.add(currentPoint);
        textureCoords.add(Offset(c / cols * image.width, r / rows * image.height));
      }
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int topLeft = r * (cols + 1) + c;
        int topRight = topLeft + 1;
        int bottomLeft = (r + 1) * (cols + 1) + c;
        int bottomRight = bottomLeft + 1;

        indices.addAll([topLeft, topRight, bottomLeft]);
        indices.addAll([topRight, bottomRight, bottomLeft]);
      }
    }

    canvas.drawVertices(
      ui.Vertices(
        VertexMode.triangles,
        vertices,
        textureCoordinates: textureCoords,
        indices: indices,
      ),
      BlendMode.srcOver,
      paint,
    );

    // テカテカ感のハイライト（鏡面反射）
    final highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [
          Colors.white.withOpacity(0.4 * deformation),
          Colors.transparent,
          Colors.white.withOpacity(0.2 * deformation),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      size.width * 0.2,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PuniPuniPainter oldDelegate) => true;
}
