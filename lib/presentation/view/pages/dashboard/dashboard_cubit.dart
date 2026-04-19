import 'dart:async';

import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/entities/medication_alert.dart';
import 'package:family_health/domain/entities/member_stats.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/repositories/event_repository_interface.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/get_today_stats_usecase.dart';
import 'package:family_health/domain/usecases/watch_family_schedules_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'dashboard_cubit.freezed.dart';
part 'dashboard_state.dart';

@injectable
class DashboardCubit extends BaseCubit<DashboardState> {
  DashboardCubit(
    this._authRepository,
    this._getUserUseCase,
    this._getTodayStatsUseCase,
    this._watchFamilySchedulesUseCase,
    this._eventRepository,
  ) : super(const DashboardState());

  final AuthRepository _authRepository;
  final GetUserUseCase _getUserUseCase;
  final GetTodayStatsUseCase _getTodayStatsUseCase;
  final WatchFamilySchedulesUseCase _watchFamilySchedulesUseCase;
  final EventRepository _eventRepository;

  StreamSubscription? _schedulesSubscription;
  StreamSubscription? _eventsSubscription;

  Future<void> loadData() async {
    final authUser = _authRepository.getCurrentUser();
    if (authUser == null) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: 'User not found',
      ));
      return;
    }

    final user = await _getUserUseCase.call(params: authUser.uid);
    if (user == null) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: 'User document not found',
      ));
      return;
    }

    emit(state.copyWith(user: user));

    if (user.familyId != null) {
      final familyId = user.familyId!;

      // Note: We don't use medication logs for stats in the dashboard progress card anymore,
      // but we still watch schedules if we want to show generic alerts or member stats.
      // However to avoid conflict, we calculate the progress inside the events stream block.
      _schedulesSubscription?.cancel();
      _schedulesSubscription =
          _watchFamilySchedulesUseCase.call(familyId).listen(
        (schedules) async {
          final stats =
              await _getTodayStatsUseCase.call(params: familyId);

          // We just update member stats and alerts from medication stats
          emit(state.copyWith(
            pageStatus: PageStatus.Loaded,
            alerts: stats.alerts,
            memberStats: stats.memberStats,
          ));
        },
        onError: (e) {
          emit(state.copyWith(
            pageStatus: PageStatus.Error,
            pageErrorMessage: e.toString(),
          ));
        },
      );

      // 2. Watch events → lọc sự kiện và tính toán progress trong ngày thay cho medication load
      _eventsSubscription?.cancel();
      _eventsSubscription =
          _eventRepository.watchMedicalEvents(familyId).listen(
        (events) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final todayEvents = events.where((e) {
            if (e.computedStatus == EventDisplayStatus.cancelled) return false;
            final startDay = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
            final endDay = DateTime(e.endTime.year, e.endTime.month, e.endTime.day);
            return !startDay.isAfter(today) && !endDay.isBefore(today);
          }).toList();

          final ongoing = todayEvents.where((e) => e.computedStatus == EventDisplayStatus.ongoing).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          final upcoming = todayEvents.where((e) => e.computedStatus == EventDisplayStatus.upcoming).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          final incomplete = todayEvents.where((e) => e.computedStatus == EventDisplayStatus.incomplete).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          final completed = todayEvents.where((e) => e.computedStatus == EventDisplayStatus.finished).toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime)); // sort newest completed first

          // Calculate progress using ONLY today's active events!
          final total = ongoing.length + upcoming.length + incomplete.length + completed.length;
          final finishedCount = todayEvents.where((e) => e.computedStatus == EventDisplayStatus.finished).length;
          final missedCount = todayEvents.where((e) => e.computedStatus == EventDisplayStatus.incomplete).length;
          final waitingCount = total - finishedCount - missedCount;
          
          final progress = total == 0 ? 0.0 : finishedCount / total;

          emit(state.copyWith(
            ongoingEvents: ongoing,
            upcomingEvents: upcoming,
            incompleteEvents: incomplete,
            completedEvents: completed,
            totalCount: total,
            takenCount: finishedCount,
            waitingCount: ongoing.length + upcoming.length,
            missedCount: missedCount,
            progress: progress,
          ));
        },
        onError: (e) {
          // Không emit error — events là tính năng phụ
        },
      );
    } else {
      emit(state.copyWith(pageStatus: PageStatus.Loaded));
    }
  }

  @override
  Future<void> close() {
    _schedulesSubscription?.cancel();
    _eventsSubscription?.cancel();
    return super.close();
  }
}
