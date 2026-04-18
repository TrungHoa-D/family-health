import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'event_detail_cubit.dart';

@RoutePage()
class EventDetailPage extends BaseCubitPage<EventDetailCubit, EventDetailState> {
  const EventDetailPage({super.key, required this.event});
  final MedicalEvent event;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<EventDetailCubit>().init(event);
  }

  @override
  Widget builder(BuildContext context) {
    return BlocConsumer<EventDetailCubit, EventDetailState>(
      listener: (context, state) {},
      builder: (context, state) {
        final ev = state.event;
        final isCancelled = ev.status == 'CANCELLED';
        final displayStatus = ev.computedStatus;
        final isFinished = displayStatus == EventDisplayStatus.finished;
        final isOngoing = displayStatus == EventDisplayStatus.ongoing;
        final isIncomplete = displayStatus == EventDisplayStatus.incomplete;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: isCancelled ? AppColors.surface : AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.router.maybePop(true),
            ),
            title: Text(
              'events.title'.tr(),
              style: AppStyles.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  context.router.push(AddEventRoute(event: ev)).then((res) {
                    if (res == true) {
                      context.router.maybePop(true); // Pop back to list to refresh if edited
                    }
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanner(ev),
                const SizedBox(height: AppSpacing.lg),

                  if (isCancelled)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('events.status.cancelled'.tr(), style: AppStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                if (isFinished)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('events.status.finished'.tr(), style: AppStyles.labelMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                if (isOngoing)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('events.status.ongoing'.tr(), style: AppStyles.labelMedium.copyWith(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                if (isIncomplete)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('events.status.incomplete'.tr(), style: AppStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                Text(
                  ev.title,
                  style: AppStyles.displayLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                    color: isCancelled ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getEventTypeName(ev.eventType),
                  style: AppStyles.titleMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Time box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: AppColors.primary, size: 32),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(ev.startTime),
                              style: AppStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatEventTime(ev),
                              style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Location box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 32),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          ev.location.isNotEmpty ? ev.location : 'Chưa cập nhật địa điểm',
                          style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text('Thành viên tham gia', style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                state.participants.isEmpty
                    ? Text('Chưa có thành viên nào được chỉ định.', style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: state.participants.map((u) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppAvatar.medium(imageUrl: u.avatarUrl),
                            const SizedBox(height: 4),
                            Text(
                              u.displayName?.split(' ').last ?? '',
                              style: AppStyles.labelSmall,
                            ),
                          ],
                        )).toList(),
                      ),

                const SizedBox(height: AppSpacing.xl),
                if (ev.description != null && ev.description!.isNotEmpty) ...[
                  Text('Ghi chú của sự kiện', style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    ),
                    child: Text(
                      ev.description!,
                      style: AppStyles.bodyLarge,
                    ),
                  ),
                ],
                
                const SizedBox(height: 48),
                if (!isCancelled && !isFinished) ...[
                  AppButton.primary(
                    title: 'events.actions.mark_finished'.tr(),
                    onPressed: () => context.read<EventDetailCubit>().markAsFinished(),
                  ),
                  const SizedBox(height: 16),
                  AppButton.outline(
                    title: 'events.actions.cancel_event'.tr(),
                    onPressed: () => context.read<EventDetailCubit>().changeStatus('CANCELLED'),
                  ),
                ],
                if (isFinished || isCancelled)
                  AppButton.outline(
                    title: 'events.actions.reopen_event'.tr(),
                    onPressed: () => context.read<EventDetailCubit>().markAsUnfinished(),
                  ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(MedicalEvent event) {
    String assetPath;
    final type = _getEventType(event.eventType);
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

    return AppCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            ? Image.network(
                event.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(assetPath, fit: BoxFit.cover),
              )
            : Image.asset(assetPath, fit: BoxFit.cover),
      ),
    );
  }

  EventType _getEventType(String type) {
    return EventType.values.firstWhere(
      (e) => e.name.toUpperCase() == type.toUpperCase(),
      orElse: () => EventType.OTHER,
    );
  }

  String _getEventTypeName(String typeString) {
    final type = _getEventType(typeString);
    switch (type) {
      case EventType.VACCINE:
        return 'events.type.vaccine'.tr();
      case EventType.CHECKUP:
        return 'events.type.checkup'.tr();
      case EventType.DENTAL:
        return 'events.type.dental'.tr();
      case EventType.MEDICATION:
        return 'events.type.medication'.tr();
      case EventType.OTHER:
        return 'events.type.other'.tr();
    }
  }

  /// Hiển thị thời gian theo timeMode của event
  String _formatEventTime(MedicalEvent event) {
    switch (event.timeMode) {
      case 'all_day':
        return 'events.time_mode.all_day'.tr();
      case 'meal_based':
        final mealKeys = {
          'breakfast': 'events.meal.breakfast',
          'lunch': 'events.meal.lunch',
          'dinner': 'events.meal.dinner',
          'snack': 'events.meal.snack',
        };
        final key = mealKeys[event.mealTime ?? 'breakfast'] ?? 'events.meal.breakfast';
        return key.tr();
      case 'from_to':
      default:
        return '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';
    }
  }
}

