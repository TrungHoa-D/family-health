import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/events/components/calendar_strip.dart';
import 'package:family_health/presentation/view/pages/events/components/event_card.dart';
import 'package:family_health/presentation/view/pages/events/events_cubit.dart';
import 'package:family_health/presentation/view/pages/events/events_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsCubit(),
      child: const EventsView(),
    );
  }
}

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        final currentDate = state.currentDate;
        final String monthYear =
            'Tháng ${currentDate.month.toString().padLeft(2, '0')}, ${currentDate.year}';

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xl * 1.5,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthYear.toUpperCase(),
                            style: AppStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'events.title'.tr(),
                            style: AppStyles.displayLarge
                                .copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      // Add FAB equivalent
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('events.coming_soon'.tr())),
                          );
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Calendar Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: CalendarStrip(
                    currentDate: state.currentDate,
                    selectedDate: state.selectedDate,
                    onDateSelected: (date) {
                      context.read<EventsCubit>().selectDate(date);
                    },
                  ),
                ),
              ),

              // Event List 1: Selected Date (e.g. Hôm nay)
              if (state.selectedDateEvents.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          () {
                            final now = DateTime.now();
                            if (state.selectedDate.day == now.day &&
                                state.selectedDate.month == now.month &&
                                state.selectedDate.year == now.year) {
                              return 'events.today'.tr();
                            }
                            final String titleDayOfWeek =
                                state.selectedDate.weekday == DateTime.sunday
                                    ? 'Chủ Nhật'
                                    : 'Thứ ${state.selectedDate.weekday + 1}';
                            final String dateStr =
                                DateFormat('dd/MM').format(state.selectedDate);
                            return '$titleDayOfWeek, $dateStr';
                          }(),
                          style: AppStyles.titleLarge
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Container(height: 1, color: AppColors.border),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100, // Card height approx
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: state.selectedDateEvents.length,
                      itemBuilder: (context, index) {
                        return EventCard(
                          event: state.selectedDateEvents[index],
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ] else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Không có sự kiện nào cho ngày này',
                        style: AppStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],

              // Event List 2: Upcoming (Sắp tới)
              if (state.upcomingEvents.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          'Sắp tới',
                          style: AppStyles.titleLarge
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Container(height: 1, color: AppColors.border),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: state.upcomingEvents.length,
                      itemBuilder: (context, index) {
                        return EventCard(event: state.upcomingEvents[index]);
                      },
                    ),
                  ),
                ),
              ],

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: AppSpacing.xl * 2,
                ), // for bottom nav overlap
              ),
            ],
          ),
        );
      },
    );
  }
}
