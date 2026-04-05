import 'dart:async';

import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/get_medication_logs_usecase.dart';
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
    this._getMedicationLogsUseCase,
    this._watchFamilySchedulesUseCase,
  ) : super(const DashboardState());

  final AuthRepository _authRepository;
  final GetMedicationLogsUseCase _getMedicationLogsUseCase;
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
          final logs = await _getMedicationLogsUseCase.call(
            params: GetMedicationLogsParams(
              familyId: user.familyId!,
              date: DateTime.now(),
            ),
          );

          // Lọc lịch trình dành riêng cho người dùng này
          final mySchedules = schedules.where((s) => s.targetUserId == user.uid).toList();
          final myLogs = logs.where((l) => mySchedules.any((s) => s.id == l.scheduleId)).toList();

          final totalCount = mySchedules.length;
          final takenCount = myLogs.where((log) => log.status == 'TAKEN').length;
          final missedCount = myLogs.where((log) => log.status == 'MISSED').length;
          final waitingCount = totalCount - myLogs.length;
          final progress = totalCount > 0 ? takenCount / totalCount : 0.0;

          emit(state.copyWith(
            pageStatus: PageStatus.Loaded,
            totalCount: totalCount,
            takenCount: takenCount,
            waitingCount: waitingCount > 0 ? waitingCount : 0,
            missedCount: missedCount,
            progress: progress,
          ),);
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
