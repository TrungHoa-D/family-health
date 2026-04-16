import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap});
  final MedicalEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color eventColor;
    IconData eventIcon;

    final type = _getEventType(event.eventType);

    switch (type) {
      case EventType.VACCINE:
        eventColor = AppColors.primary;
        eventIcon = Icons.vaccines;
        break;
      case EventType.DENTAL:
        eventColor = Colors.orange;
        eventIcon = Icons.health_and_safety;
        break;
      case EventType.CHECKUP:
        eventColor = AppColors.success;
        eventIcon = Icons.medical_services;
        break;
      case EventType.MEDICATION:
        eventColor = Colors.blueAccent;
        eventIcon = Icons.medication;
        break;
      case EventType.OTHER:
      default:
        eventColor = Colors.purple;
        eventIcon = Icons.event_note;
        break;
    }

    String assetPath;
    switch (type) {
      case EventType.VACCINE:
        assetPath = 'assets/images/event_vaccine.png';
        break;
      case EventType.CHECKUP:
        assetPath = 'assets/images/event_checkup.png';
        break;
      case EventType.DENTAL:
        assetPath = 'assets/images/event_dental.png';
        break;
      case EventType.MEDICATION:
        assetPath = 'assets/images/event_medication.png';
        break;
      case EventType.OTHER:
      default:
        assetPath = 'assets/images/event_other.png';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            AspectRatio(
              aspectRatio: 21 / 9,
              child: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(assetPath, fit: BoxFit.cover),
                    )
                  : Image.asset(assetPath, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: eventColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(eventIcon, color: eventColor, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: AppStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: event.status == 'CANCELLED'
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: event.status == 'CANCELLED'
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _StatusChip(status: event.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time_filled,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                                  style: AppStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                const Icon(Icons.location_on,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location.isNotEmpty
                                        ? event.location
                                        : 'Không có địa điểm',
                                    style: AppStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.description!,
                        style:
                            AppStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (event.participantIds.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.people_outline,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${event.participantIds.length} người tham gia',
                              style: AppStyles.labelSmall
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        DateFormat('dd/MM/yyyy').format(event.startTime),
                        style: AppStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  EventType _getEventType(String type) {
    return EventType.values.firstWhere(
      (e) => e.name.toUpperCase() == type.toUpperCase(),
      orElse: () => EventType.OTHER,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'COMPLETED':
        color = AppColors.success;
        text = 'Hoàn thành';
        break;
      case 'CANCELLED':
        color = AppColors.error;
        text = 'Đã huỷ';
        break;
      case 'UPCOMING':
      default:
        color = AppColors.primary;
        text = 'Sắp tới';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: AppStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
