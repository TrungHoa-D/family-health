import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/medication_category.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'category_list_cubit.dart';

@RoutePage()
class CategoryListPage
    extends BaseCubitPage<CategoryListCubit, CategoryListState> {
  const CategoryListPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<CategoryListCubit>().loadData();
  }

  /// Map tên icon string sang IconData
  static IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'bloodtype':
        return Icons.bloodtype;
      case 'medication':
        return Icons.medication;
      case 'vitamins':
        return Icons.spa;
      case 'healing':
        return Icons.healing;
      case 'monitor_heart':
        return Icons.monitor_heart;
      case 'psychology':
        return Icons.psychology;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.category;
    }
  }

  /// Màu gradient cho mỗi card dựa trên index
  static List<Color> _getGradient(int index) {
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
      [const Color(0xFFfccb90), const Color(0xFFd57eeb)],
      [const Color(0xFF89f7fe), const Color(0xFF66a6ff)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<CategoryListCubit, CategoryListState>(
      builder: (context, state) {
        final categories = state.filteredCategories;

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
              'meds.category_list_title'.tr(),
              style:
                  AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  onChanged: (value) =>
                      context.read<CategoryListCubit>().updateSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'meds.category_search_hint'.tr(),
                    hintStyle: AppStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusCard),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: AppStyles.bodyMedium,
                ),
              ),

              // Grid
              Expanded(
                child: categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.4),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Chưa có phân loại nào',
                              style: AppStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final medCount =
                              state.getMedCount(category.name);
                          return _CategoryCard(
                            category: category,
                            medCount: medCount,
                            gradient: _getGradient(index),
                            icon: _getIconData(category.icon),
                            onTap: () {
                              context.router.push(
                                CategoryMedsRoute(
                                    categoryName: category.name),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.medCount,
    required this.gradient,
    required this.icon,
    this.onTap,
  });

  final MedicationCategory category;
  final int medCount;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: AppSpacing.md),

              // Name
              Text(
                category.name,
                style: AppStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Med count
              Text(
                'meds.category_med_count'.tr(args: [medCount.toString()]),
                style: AppStyles.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),

              const Spacer(),

              // Description
              if (category.description != null &&
                  category.description!.isNotEmpty)
                Text(
                  category.description!,
                  style: AppStyles.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
