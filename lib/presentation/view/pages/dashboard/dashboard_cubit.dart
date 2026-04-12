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

      // 1. Watch schedules → tính stats + member progress
      _schedulesSubscription?.cancel();
      _schedulesSubscription =
          _watchFamilySchedulesUseCase.call(familyId).listen(
        (schedules) async {
          final stats =
              await _getTodayStatsUseCase.call(params: familyId);

          final waiting = stats.totalDoses - stats.takenDoses - stats.missedDoses;
          emit(state.copyWith(
            pageStatus: PageStatus.Loaded,
            totalCount: stats.totalDoses,
            takenCount: stats.takenDoses,
            waitingCount: waiting.clamp(0, stats.totalDoses),
            missedCount: stats.missedDoses,
            progress: stats.completionPercentage / 100,
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

      // 2. Watch events → lọc sự kiện sắp tới
      _eventsSubscription?.cancel();
      _eventsSubscription =
          _eventRepository.watchMedicalEvents(familyId).listen(
        (events) {
          final now = DateTime.now();
          final upcoming = events
              .where((e) => e.startTime.isAfter(now))
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          emit(state.copyWith(
            upcomingEvents: upcoming.take(5).toList(),
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
