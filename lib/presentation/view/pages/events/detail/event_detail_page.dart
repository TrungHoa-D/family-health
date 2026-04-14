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
        final isCompleted = ev.status == 'COMPLETED';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: isCancelled ? AppColors.surface : AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.router.maybePop(true),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  context.router.push(AddEventRoute(event: ev)).then((_) {
                    context.read<EventDetailCubit>().init(ev); // Refresh could need an id load but we assume parent repolls
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
                        Text('Sự kiện đã huỷ bỏ', style: AppStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                if (isCompleted)
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
                        Text('Sự kiện đã diễn ra / Hoàn thành', style: AppStyles.labelMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
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
                              '${DateFormat('HH:mm').format(ev.startTime)} - ${DateFormat('HH:mm').format(ev.endTime)}',
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
                if (!isCancelled && !isCompleted) ...[
                  AppButton.primary(
                    title: 'Đánh dấu Hoàn thành',
                    onPressed: () => context.read<EventDetailCubit>().changeStatus('COMPLETED'),
                  ),
                  const SizedBox(height: 16),
                  AppButton.outline(
                    title: 'Huỷ bỏ sự kiện',
                    onPressed: () => context.read<EventDetailCubit>().changeStatus('CANCELLED'),
                  ),
                ],
                if (isCompleted || isCancelled)
                  AppButton.outline(
                    title: 'Mở lại sự kiện',
                    onPressed: () => context.read<EventDetailCubit>().changeStatus('UPCOMING'),
                  ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }
}
