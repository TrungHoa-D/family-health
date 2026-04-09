import 'dart:async';

import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/get_today_stats_usecase.dart';
import 'package:family_health/domain/usecases/watch_family_schedules_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:family_health/domain/entities/medication_alert.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';

part 'dashboard_cubit.freezed.dart';
part 'dashboard_state.dart';

@injectable
class DashboardCubit extends BaseCubit<DashboardState> {
  DashboardCubit(
    this._authRepository,
    this._getTodayStatsUseCase,
    this._watchFamilySchedulesUseCase,
  ) : super(const DashboardState());

  final AuthRepository _authRepository;
  final GetTodayStatsUseCase _getTodayStatsUseCase;
  final WatchFamilySchedulesUseCase _watchFamilySchedulesUseCase;

  StreamSubscription? _schedulesSubscription;

  Future<void> loadData() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      emit(state.copyWith(pageStatus: PageStatus.Error, pageErrorMessage: 'User not found'));
      return;
    }

    emit(state.copyWith(user: user));

    if (user.familyId != null) {
      _schedulesSubscription?.cancel();
      _schedulesSubscription = _watchFamilySchedulesUseCase.call(user.familyId!).listen(
        (schedules) async {
          final stats = await _getTodayStatsUseCase.call(params: user.familyId!);

          emit(state.copyWith(
            pageStatus: PageStatus.Loaded,
            totalCount: stats.totalDoses,
            takenCount: stats.takenDoses,
            waitingCount: stats.totalDoses - stats.takenDoses - stats.missedDoses,
            missedCount: stats.missedDoses,
            progress: stats.completionPercentage / 100,
            alerts: stats.alerts,
          ));
        },
        onError: (e) {
          emit(state.copyWith(pageStatus: PageStatus.Error, pageErrorMessage: e.toString()));
        },
      );
    } else {
      emit(state.copyWith(pageStatus: PageStatus.Loaded));
    }
  }

  @override
  Future<void> close() {
    _schedulesSubscription?.cancel();
    return super.close();
  }
}
