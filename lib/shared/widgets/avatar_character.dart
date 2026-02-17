import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated Avatar Widget with Evolution Stages
class AvatarCharacter extends StatefulWidget {
  final String stage; // 'egg', 'baby', 'kid', 'teen', 'master'
  final double size;
  final bool isAnimating;

  const AvatarCharacter({
    super.key,
    required this.stage,
    this.size = 120,
    this.isAnimating = true,
  });

  @override
  State<AvatarCharacter> createState() => _AvatarCharacterState();
}

class _AvatarCharacterState extends State<AvatarCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isAnimating
              ? Offset(0, _floatingAnimation.value)
              : Offset.zero,
          child: Transform.scale(
            scale: widget.isAnimating ? _breathingAnimation.value : 1.0,
            child: _buildStageAvatar(),
          ),
        );
      },
    );
  }

  Widget _buildStageAvatar() {
    switch (widget.stage.toLowerCase()) {
      case 'egg':
        return _buildEggStage();
      case 'baby':
        return _buildBabyStage();
      case 'kid':
        return _buildKidStage();
      case 'teen':
        return _buildTeenStage();
      case 'master':
        return _buildMasterStage();
      default:
        return _buildEggStage();
    }
  }

  // --- Stage Avatars ---

  Widget _buildEggStage() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text('🥚', style: TextStyle(fontSize: widget.size * 0.5)),
      ),
    );
  }

  Widget _buildBabyStage() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text('👶', style: TextStyle(fontSize: widget.size * 0.5)),
      ),
    );
  }

  Widget _buildKidStage() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text('🧒', style: TextStyle(fontSize: widget.size * 0.5)),
      ),
    );
  }

  Widget _buildTeenStage() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text('🧑', style: TextStyle(fontSize: widget.size * 0.5)),
      ),
    );
  }

  Widget _buildMasterStage() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAF5FF), Color(0xFFE9D5FF), Color(0xFFD8B4FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFA855F7).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sparkle effect
          ...List.generate(6, (index) {
            final angle = (index * 60) * math.pi / 180;
            return Transform.translate(
              offset: Offset(
                math.cos(angle) * widget.size * 0.5,
                math.sin(angle) * widget.size * 0.5,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
            );
          }),
          Text('🧙', style: TextStyle(fontSize: widget.size * 0.5)),
        ],
      ),
    );
  }
}

/// Circular Level Progress Ring
class CircularLevelProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int level;
  final double size;
  final Widget child;

  const CircularLevelProgress({
    super.key,
    required this.progress,
    required this.level,
    required this.child,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: progress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              progressColor: const Color(0xFF6366F1),
              strokeWidth: 8,
            ),
          ),
          // Avatar in center
          child,
          // Level badge
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Lvl $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [progressColor, progressColor.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
