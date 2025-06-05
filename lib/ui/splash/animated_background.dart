import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({
    Key? key, 
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
        // グラデーション背景
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
            ),
          ),
        ),
        
        // 浮かぶ円のアニメーション
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: BackgroundPainter(_controller.value),
              child: Container(),
            );
          },
        ),
        
        // メインコンテンツ
        widget.child,
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  
  BackgroundPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    // 複数の円を描画
    _drawCircle(canvas, size, paint, 0.2, 0.3, -0.1);
    _drawCircle(canvas, size, paint, 0.7, 0.2, 0.2);
    _drawCircle(canvas, size, paint, 0.4, 0.4, -0.3);
    _drawCircle(canvas, size, paint, 0.8, 0.1, 0.1);
    _drawCircle(canvas, size, paint, 0.1, 0.2, 0.2);
  }
    void _drawCircle(Canvas canvas, Size size, Paint paint, double posX, double posY, double offset) {
    // アニメーションに基づいて位置をずらす
    final yOffset = size.height * 0.1 * math.sin(animationValue * 2 * math.pi + offset * 10);
    final xOffset = size.width * 0.05 * math.cos(animationValue * 2 * math.pi + offset * 5);
    
    final center = Offset(
      size.width * posX + xOffset,
      size.height * posY + yOffset,
    );
    
    final radius = size.width * (0.1 + 0.05 * math.sin(animationValue * 2 * math.pi + offset));
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
