import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class AnimatedAiFab extends StatefulWidget {
  const AnimatedAiFab({
    super.key,
    required this.medicationName,
    required this.onTap,
  });

  final String medicationName;
  final VoidCallback onTap;

  @override
  State<AnimatedAiFab> createState() => _AnimatedAiFabState();
}

class _AnimatedAiFabState extends State<AnimatedAiFab> {
  bool _isExpanded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Expand initially after short delay to catch attention
    Future.delayed(const Duration(seconds: 1), _showAndHideMessage);
    
    // Then trigger every 15 seconds
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isExpanded) {
        _showAndHideMessage();
      }
    });
  }

  void _showAndHideMessage() {
    if (!mounted) return;
    setState(() {
      _isExpanded = true;
    });
    
    // Collapse after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _isExpanded = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = 'meds.ai_assistant_desc'.tr(args: [widget.medicationName]);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        constraints: BoxConstraints(
          maxWidth: _isExpanded ? MediaQuery.of(context).size.width * 0.75 : 56,
          minWidth: 56,
          minHeight: 56,
        ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: _isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: _isExpanded ? 16.0 : 0),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (_isExpanded)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      message,
                      style: AppStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
            ],
          ), // Row
        ), // InkWell
      ), // Material
      ), // AnimatedContainer
    ); // AnimatedSize
  }
}
