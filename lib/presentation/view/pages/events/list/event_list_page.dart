import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/pages/events/components/event_card.dart';
import 'package:family_health/presentation/view/pages/events/list/event_list_cubit.dart';
import 'package:family_health/presentation/view/pages/events/list/event_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class EventListPage extends BaseCubitPage<EventListCubit, EventListState> {
  const EventListPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<EventListCubit>().init();
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<EventListCubit, EventListState>(
      builder: (context, state) {
        final filteredEvents = state.filteredEvents;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: Text(
              'Danh sách sự kiện',
              style: AppStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.router.maybePop(),
            ),
            actions: [
              if (state.dateRange != null ||
                  state.statusFilter != null ||
                  state.searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: () =>
                      context.read<EventListCubit>().clearFilters(),
                ),
            ],
          ),
          body: Column(
            children: [
              // Search & Filter Header
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (val) =>
                          context.read<EventListCubit>().updateSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm sự kiện, địa điểm...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Filters Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Date Picker Filter
                          _FilterChip(
                            label: state.dateRange == null
                                ? 'Thời gian'
                                : '${DateFormat('dd/MM').format(state.dateRange!.start)} - ${DateFormat('dd/MM').format(state.dateRange!.end)}',
                            icon: Icons.calendar_today,
                            isSelected: state.dateRange != null,
                            onTap: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                initialDateRange: state.dateRange,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (range != null) {
                                context
                                    .read<EventListCubit>()
                                    .updateDateRange(range);
                              }
                            },
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Quick Filters
                          _FilterChip(
                            label: 'Sắp tới',
                            isSelected: state.statusFilter == 'UPCOMING',
                            onTap: () => context
                                .read<EventListCubit>()
                                .updateStatusFilter(
                                    state.statusFilter == 'UPCOMING'
                                        ? null
                                        : 'UPCOMING'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            label: 'Hoàn thành',
                            isSelected: state.statusFilter == 'COMPLETED',
                            onTap: () => context
                                .read<EventListCubit>()
                                .updateStatusFilter(
                                    state.statusFilter == 'COMPLETED'
                                        ? null
                                        : 'COMPLETED'),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            label: 'Chưa hoàn thành',
                            isSelected: state.statusFilter == 'INCOMPLETE',
                            onTap: () => context
                                .read<EventListCubit>()
                                .updateStatusFilter(
                                    state.statusFilter == 'INCOMPLETE'
                                        ? null
                                        : 'INCOMPLETE'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Results List
              Expanded(
                child: filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_busy,
                                size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Không tìm thấy sự kiện nào',
                              style: AppStyles.bodyLarge
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          return EventCard(
                            event: event,
                            onTap: () {
                              context.router
                                  .push(EventDetailRoute(event: event));
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: isSelected ? AppColors.white : AppColors.textPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
