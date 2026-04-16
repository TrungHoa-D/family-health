import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SimplifiedEventListItem extends StatelessWidget {
  const SimplifiedEventListItem({
    super.key,
    required this.event,
    this.onTap,
    this.onComplete,
  });

  final MedicalEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isActive = now.isAfter(event.startTime) && 
                    now.isBefore(event.endTime.add(const Duration(minutes: 30)));
    final timeStr = DateFormat('HH:mm').format(event.startTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.all(isActive ? AppSpacing.xl : AppSpacing.lg),
        decoration: BoxDecoration(
          color: isActive ? _getEventColor().withValues(alpha: 0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(32),
          border: isActive ? Border.all(color: _getEventColor().withValues(alpha: 0.3), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: isActive ? 100 : 80,
                  height: isActive ? 100 : 80,
                  decoration: BoxDecoration(
                    color: _getEventColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isActive ? 28 : 20),
                  ),
                  child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(isActive ? 28 : 20),
                          child: Image.network(
                            event.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(_getEventIcon(),
                                color: _getEventColor(), size: isActive ? 50 : 40),
                          ),
                        )
                      : Icon(_getEventIcon(), color: _getEventColor(), size: isActive ? 50 : 40),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: isActive ? 32 : 24,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$timeStr - ${event.location}',
                        style: AppStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isActive ? 22 : 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline, size: 32),
                  label: const Text(
                    'HOÀN THÀNH',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon() {
    switch (event.eventType) {
      case 'VACCINE':
        return Icons.vaccines;
      case 'CHECKUP':
        return Icons.medical_services;
      case 'DENTAL':
        return Icons.medical_information;
      case 'MEDICATION':
        return Icons.medication;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor() {
    switch (event.eventType) {
      case 'VACCINE':
        return Colors.orange;
      case 'CHECKUP':
        return Colors.blue;
      case 'DENTAL':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }
}
