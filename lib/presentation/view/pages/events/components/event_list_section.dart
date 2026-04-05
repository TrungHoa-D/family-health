import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/events/components/event_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventListSection extends StatelessWidget {
  const EventListSection({super.key, required this.events, this.onEventTap});
  final List<MedicalEvent> events;
  final Function(MedicalEvent)? onEventTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Không có sự kiện nào trong ngày này',
            style:
                AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Grouping events
    final Map<String, List<MedicalEvent>> groupedEvents = {};
    for (final event in events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      String key;
      if (date == today) {
        key = 'Hôm nay';
      } else {
        final String dau = DateFormat('EEEE', 'vi_VN').format(date);
        final String cuoi = DateFormat('dd/MM').format(date);
        key =
            '${dau[0].toUpperCase()}${dau.substring(1)}, $cuoi'; // e.g. Thứ Bảy, 28/03
      }

      if (!groupedEvents.containsKey(key)) {
        groupedEvents[key] = [];
      }
      groupedEvents[key]!.add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedEvents.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  entry.key,
                  style: AppStyles.titleLarge
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...entry.value.map((event) => EventCard(
                  event: event,
                  onTap: () => onEventTap?.call(event),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      }).toList(),
    );
  }
}
