import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/events/events_state.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    Color eventColor;
    IconData eventIcon;

    switch (event.type) {
      case EventType.vaccine:
        eventColor = AppColors.primary;
        eventIcon = Icons.vaccines;
        break;
      case EventType.dentistry:
        eventColor = Colors.orange;
        eventIcon = Icons.health_and_safety;
        break;
      case EventType.checkup:
        eventColor = AppColors.success;
        eventIcon = Icons.medical_services;
        break;
      case EventType.other:
        eventColor = Colors.purple;
        eventIcon = Icons.event_note;
        break;
    }

    return SizedBox(
      width: 280,
      child: AppCard(
        margin: const EdgeInsets.only(right: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Icon Circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: eventColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(eventIcon, color: eventColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: AppStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(event.time),
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
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
      ),
    );
  }
}
