import 'package:flutter/material.dart';

class ResponseLoader extends StatefulWidget {
  final Color dotColor;
  final double dotSize;
  final double spacing;
  final Duration duration;
  final double speed;

  const ResponseLoader({
    super.key,
    this.dotColor = const Color.fromARGB(255, 223, 223, 223),
    this.dotSize = 8.0,
    this.spacing = 4.0,
    this.duration = const Duration(milliseconds: 1200),
    this.speed = 1.0,
  });

  @override
  ResponseLoaderState createState() => ResponseLoaderState();
}

class ResponseLoaderState extends State<ResponseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    final effectiveDuration = Duration(
      milliseconds: (widget.duration.inMilliseconds / widget.speed).round(),
    );

    _controller = AnimationController(
      duration: effectiveDuration,
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    _animation2 = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
      ),
    );
    _animation3 = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: child,
        );
      },
      child: Container(
        width: widget.dotSize,
        height: widget.dotSize,
        decoration: BoxDecoration(
          color: widget.dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(_animation1),
        SizedBox(width: widget.spacing),
        _buildDot(_animation2),
        SizedBox(width: widget.spacing),
        _buildDot(_animation3),
      ],
    );
  }
}