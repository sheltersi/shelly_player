import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;
  final Random _random = Random();
  final List<Offset> _positions = [];
  final List<double> _sizes = [];
  final List<double> _speeds = [];
  static const int _orbCount = 6;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _orbCount,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(seconds: 10 + _random.nextInt(15)),
      ),
    );

    _animations = _controllers.map((ctrl) {
      return Tween<double>(begin: 0, end: 2 * pi).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOutSine),
      );
    }).toList();

    for (int i = 0; i < _orbCount; i++) {
      _positions.add(Offset(
        _random.nextDouble() * 0.8 + 0.1,
        _random.nextDouble() * 0.8 + 0.1,
      ));
      _sizes.add(_random.nextDouble() * 200 + 150);
      _speeds.add(_random.nextDouble() * 0.5 + 0.3);
      _controllers[i].repeat();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFF0A0A0A),
        ),
        ...List.generate(_orbCount, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (context, child) {
              final x = _positions[i].dx +
                  sin(_animations[i].value * _speeds[i]) * 0.08;
              final y = _positions[i].dy +
                  cos(_animations[i].value * _speeds[i] * 0.7) * 0.08;
              return Positioned(
                left: x * MediaQuery.of(context).size.width - _sizes[i] / 2,
                top: y * MediaQuery.of(context).size.height - _sizes[i] / 2,
                child: Container(
                  width: _sizes[i],
                  height: _sizes[i],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        i.isEven
                            ? const Color(0xFF800080).withValues(alpha: 0.18)
                            : const Color(0xFFBE29EC).withValues(alpha: 0.12),
                        const Color(0xFF800080).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0A0A).withValues(alpha: 0.0),
                const Color(0xFF0A0A0A).withValues(alpha: 0.7),
                const Color(0xFF0A0A0A).withValues(alpha: 0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
