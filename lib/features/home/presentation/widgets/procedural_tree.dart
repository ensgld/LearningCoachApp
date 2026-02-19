import 'dart:math';

import 'package:flutter/material.dart';

class ProceduralTree extends StatelessWidget {
  final int level;
  final double size;

  const ProceduralTree({super.key, required this.level, required this.size});

  @override
  Widget build(BuildContext context) {
    // Determine visuals based on level
    // Cap visual evolution at level 10, but allow color changes after
    final int visualLevel = level.clamp(1, 10);
    final bool isMaxGrowth = level >= 10;

    // Trunk Color: Green (Lvl 1) -> Brown (Lvl 10)
    final Color trunkColor = Color.lerp(
      const Color(0xFF86EFAC), // Light Green
      const Color(0xFF5D4037), // Dark Brown
      (visualLevel - 1) / 9,
    )!;

    // Leaf Color
    Color leafColor = const Color(0xFF22C55E); // Base Green
    if (level > 10) {
      // Shift hue for levels > 10
      final double hue = ((level - 10) * 37.0) % 360;
      leafColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.45).toColor();
    }

    // Fruit?
    final bool showFruits = visualLevel >= 9;

    return CustomPaint(
      size: Size(size, size),
      painter: _TreePainter(
        level: visualLevel,
        isMaxGrowth: isMaxGrowth,
        trunkColor: trunkColor,
        leafColor: leafColor,
        showFruits: showFruits,
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final int level;
  final bool isMaxGrowth;
  final Color trunkColor;
  final Color leafColor;
  final bool showFruits;

  Random _rng = Random(42); // Seeded for consistency

  _TreePainter({
    required this.level,
    required this.isMaxGrowth,
    required this.trunkColor,
    required this.leafColor,
    required this.showFruits,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _rng = Random(42); // Reset seed each paint

    final centerBottom = Offset(size.width / 2, size.height);

    // Properties based on level
    // Height: Grows from 65% to 95% of container
    final double treeHeight = size.height * (0.65 + (level / 10) * 0.3);

    // Trunk Thickness: Grows from 6 to 18
    final double trunkWidth = 6.0 + (level * 1.2);

    // Recursion Depth (Complexity)
    final int depth = level <= 2
        ? 1
        : level <= 5
        ? 2
        : 3;

    // Draw Trunk & Branches
    _drawBranch(
      canvas,
      centerBottom,
      -pi / 2, // Upwards
      treeHeight,
      trunkWidth,
      depth,
      level,
    );
  }

  void _drawBranch(
    Canvas canvas,
    Offset start,
    double angle,
    double length,
    double width,
    int currentDepth,
    int currentLevel,
  ) {
    if (currentDepth < 0) return;

    final Paint trunkPaint = Paint()
      ..color = trunkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // Calculate end point
    final double endX = start.dx + cos(angle) * length;
    final double endY = start.dy + sin(angle) * length;
    final Offset end = Offset(endX, endY);

    // Quadratic Bezier for slight curve
    // Curve intensity changes slightly pseudo-randomly but deterministically
    final double curveFactor =
        (_rng.nextDouble() - 0.5) * 20 * (4 - currentDepth);
    final Offset control = Offset(
      (start.dx + endX) / 2 + curveFactor,
      (start.dy + endY) / 2,
    );

    final Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(control.dx, control.dy, endX, endY);

    canvas.drawPath(path, trunkPaint);

    // Draw Leaves/Fruits at ends or joints if complex enough
    // Draw leaves on trunk too for bushier look at higher levels
    if (currentDepth == 0 || (currentDepth == 1 && currentLevel >= 4)) {
      _drawFoliage(canvas, end, width, currentLevel);
    }

    // Recursive branches
    if (currentDepth > 0) {
      final double spreadAngle =
          0.6 + (currentLevel * 0.04).clamp(0.0, 0.4); // Wider spread

      _drawBranch(
        canvas,
        end,
        angle - spreadAngle / 2,
        length * 0.65,
        width * 0.7,
        currentDepth - 1,
        currentLevel,
      );

      _drawBranch(
        canvas,
        end,
        angle + spreadAngle / 2,
        length * 0.65,
        width * 0.7,
        currentDepth - 1,
        currentLevel,
      );
    }
  }

  void _drawFoliage(
    Canvas canvas,
    Offset center,
    double stemWidth,
    int currentLevel,
  ) {
    // Leaf Cluster
    final Paint leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;

    // Cluster size grows with level
    final double clusterRadius = 12.0 + (currentLevel * 1.8);
    final int leafCount = 5 + currentLevel; // More density

    for (int i = 0; i < leafCount; i++) {
      final double leafAngle = _rng.nextDouble() * 2 * pi;
      final double distance = _rng.nextDouble() * clusterRadius;

      final double lx = center.dx + cos(leafAngle) * distance;
      final double ly = center.dy + sin(leafAngle) * distance;

      // Draw individual leaf (Ellipse)
      canvas.drawOval(
        Rect.fromCenter(center: Offset(lx, ly), width: 8, height: 12),
        leafPaint,
      );
    }

    // Fruits
    if (showFruits && _rng.nextDouble() > 0.6) {
      final Paint fruitPaint = Paint()..color = const Color(0xFFEF4444); // Red
      // Draw a fruit
      canvas.drawCircle(
        center + Offset(_rng.nextDouble() * 10 - 5, _rng.nextDouble() * 10 - 5),
        4.0,
        fruitPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.leafColor != leafColor;
  }
}
