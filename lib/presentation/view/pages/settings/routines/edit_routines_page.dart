import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'edit_routines_cubit.dart';

@RoutePage()
class EditRoutinesPage extends BaseCubitPage<EditRoutinesCubit, EditRoutinesState> {
  const EditRoutinesPage({super.key, required this.initialRoutines});
  final List<DailyRoutine> initialRoutines;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<EditRoutinesCubit>().init(initialRoutines);
  }

  Future<void> _selectTime(BuildContext context, int index, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && picked != initialTime && context.mounted) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      context.read<EditRoutinesCubit>().updateRoutineTime(index, formatted);
    }
  }

  @override
  Widget builder(BuildContext context) {
    return BlocConsumer<EditRoutinesCubit, EditRoutinesState>(
      listenWhen: (prev, curr) => prev.isSaved != curr.isSaved,
      listener: (context, state) {
        if (state.isSaved) {
          context.router.maybePop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: Text(
              'settings.edit_routines'.tr(),
              style: AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.router.maybePop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'settings.edit_routines_desc'.tr(),
                  style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.routines.length,
                    itemBuilder: (context, index) {
                      final routine = state.routines[index];
                      return _RoutineEditTile(
                        routine: routine,
                        onTap: () => _selectTime(context, index, routine.time),
                      );
                    },
                  ),
                ),
                AppButton.primary(
                  title: 'common.save'.tr(),
                  onPressed: () => context.read<EditRoutinesCubit>().save(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoutineEditTile extends StatelessWidget {
  const _RoutineEditTile({required this.routine, required this.onTap});
  final DailyRoutine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routine.title, style: AppStyles.titleMedium),
                Text(routine.subtitle, style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                routine.time,
                style: AppStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
