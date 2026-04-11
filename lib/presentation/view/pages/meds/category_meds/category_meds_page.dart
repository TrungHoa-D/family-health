import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/pages/meds/components/meds_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'category_meds_cubit.dart';

@RoutePage()
class CategoryMedsPage
    extends BaseCubitPage<CategoryMedsCubit, CategoryMedsState> {
  const CategoryMedsPage({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<CategoryMedsCubit>().loadData(categoryName);
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<CategoryMedsCubit, CategoryMedsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.router.maybePop(),
            ),
            title: Text(
              'meds.category_meds_title'.tr(args: [categoryName]),
              style:
                  AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: false,
          ),
          body: state.medications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'meds.no_meds_in_category'.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with count
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'meds.current_list_label'.tr(),
                                style: AppStyles.labelLarge.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'meds.meds_count'.tr(
                                  args: [
                                    state.medications.length.toString()
                                  ]),
                              style: AppStyles.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Medication list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.medications.length,
                        itemBuilder: (context, index) {
                          return MedsCard(
                            medication: state.medications[index],
                            onTap: () {
                              context.router.push(
                                MedicationDetailRoute(
                                    medication: state.medications[index]),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
