import 'package:flutter/material.dart';
import 'dart:math' as math;

class TiltPropertyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TiltPropertyCard({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  State<TiltPropertyCard> createState() => _TiltPropertyCardState();
}

class _TiltPropertyCardState extends State<TiltPropertyCard> with SingleTickerProviderStateMixin {
  double _rotateX = 0.0;
  double _rotateY = 0.0;
  
  late AnimationController _animationController;
  late Animation<double> _rotateXAnimation;
  late Animation<double> _rotateYAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotateXAnimation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _rotateYAnimation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.addListener(() {
      setState(() {
        _rotateX = _rotateXAnimation.value;
        _rotateY = _rotateYAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerEvent event) {
    if (!mounted) return;
    
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final Size size = renderBox.size;
      // Convert global touch position to local card coordinates
      final Offset localPosition = renderBox.globalToLocal(event.position);
      
      // Normalize position between -1.0 and 1.0
      // X goes from left (-1) to right (1)
      // Y goes from top (-1) to bottom (1)
      final double normalizedX = (localPosition.dx / size.width) * 2 - 1;
      final double normalizedY = (localPosition.dy / size.height) * 2 - 1;
      
      // Max rotation: +/- 5 degrees (in radians)
      const double maxRotation = 5.0 * math.pi / 180.0;
      
      // Clamp the normalized values to [-1, 1] just in case finger moves out of bounds
      final double clampedX = normalizedX.clamp(-1.0, 1.0);
      final double clampedY = normalizedY.clamp(-1.0, 1.0);
      
      _animationController.stop();
      setState(() {
        _rotateX = -clampedY * maxRotation; // Negative so top (-1) tilts top toward user (+ rotateX)
        _rotateY = clampedX * maxRotation;  // Positive so right (+1) tilts right toward user (+ rotateY)
      });
    }
  }

  void _onPointerUp(PointerEvent event) {
    _rotateXAnimation = Tween<double>(begin: _rotateX, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _rotateYAnimation = Tween<double>(begin: _rotateY, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Apply matrix transformation with perspective
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(_rotateX)
      ..rotateY(_rotateY);

    return Listener(
      onPointerDown: _onPointerMove,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Transform(
          transform: transform,
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
