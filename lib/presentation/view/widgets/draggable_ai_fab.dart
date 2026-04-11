import 'dart:async';

import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  const DraggableFloatingActionButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.initialOffset = const Offset(20, 20),
  });

  final Widget child;
  final VoidCallback onPressed;
  final Offset initialOffset;

  @override
  State<DraggableFloatingActionButton> createState() =>
      _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late Offset offset;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bubbleAnimation;
  Timer? _timer;
  bool _showBubble = false;
  String _bubbleText = 'Chào bạn, tôi là Trợ lý AI';

  @override
  void initState() {
    super.initState();
    offset = widget.initialOffset;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _bubbleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Chào bạn 1 lần khi mở app, đợi UI ổn định
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _triggerAnimation();
        }
      });
    });
  }



  void _triggerAnimation() {
    if (!mounted) return;

    // Phase 1: Greeting
    setState(() {
      _bubbleText = 'Chào bạn, tôi là Trợ lý AI';
      _showBubble = true;
    });
    _animationController.forward();

    // After 3 seconds, hide the first message
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || !_showBubble) return;
      _animationController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _showBubble = false);

        // Phase 2: Offer help (5 seconds after the first message started)
        // Since we spent 3s on Phase 1 + some transition time, we wait ~2s more
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _bubbleText = 'Nếu cần trợ giúp gì hãy hỏi tôi nhé';
            _showBubble = true;
          });
          _animationController.forward();

          // After 3 seconds, hide the second message
          Future.delayed(const Duration(seconds: 3), () {
            if (!mounted || !_showBubble) return;
            _animationController.reverse().then((_) {
              if (!mounted) return;
              setState(() => _showBubble = false);
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      right: offset.dx,
      bottom: offset.dy,
      child: Draggable(
        feedback: Material(
          color: Colors.transparent,
          child: widget.child,
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            // Calculate new offset from bottom-right (details.offset is from top-left)
            final double newRight = size.width - details.offset.dx - 56;
            final double newBottom = size.height - details.offset.dy - 56;

            // Constrain within screen padding
            offset = Offset(
              newRight.clamp(16.0, size.width - 72.0),
              newBottom.clamp(80.0, size.height - 72.0),
            );

            // Hide bubble on drag to avoid visual glitches
            _showBubble = false;
            _animationController.reset();
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showBubble)
              ScaleTransition(
                scale: _bubbleAnimation,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _bubbleText,
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: widget.onPressed,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
