import 'dart:async';

import 'package:easy_localization/easy_localization.dart';

import 'package:family_health/domain/entities/home_stats.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/get_today_stats_usecase.dart';
import 'package:family_health/domain/usecases/sign_out_usecase.dart';
import 'package:family_health/domain/usecases/update_ui_preference_usecase.dart';
import 'package:family_health/domain/usecases/watch_user_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit(
    this._authRepository,
    this._signOutUseCase,
    this._getTodayStatsUseCase,
    this._watchUserUseCase,
    this._updateUIPreferenceUseCase,
  ) : super(const HomeState());

  final AuthRepository _authRepository;
  final SignOutUseCase _signOutUseCase;
  final GetTodayStatsUseCase _getTodayStatsUseCase;
  final WatchUserUseCase _watchUserUseCase;
  final UpdateUIPreferenceUseCase _updateUIPreferenceUseCase;

  StreamSubscription? _userSubscription;

  Future<void> loadData() async {
    final UserEntity? authUser = _authRepository.getCurrentUser();
    if (authUser == null) return;

    _userSubscription?.cancel();
    _userSubscription =
        _watchUserUseCase.call(params: authUser.uid).listen((user) async {
      try {
        HomeStats? stats;
        if (user?.familyId != null) {
          stats = await _getTodayStatsUseCase.call(params: user!.familyId!);
        }

        if (isClosed) return;

        final isSwitchingToSimplified = state.user?.uiPreference != 'simplified' && user?.uiPreference == 'simplified';

        emit(
          state.copyWith(
            pageStatus: PageStatus.Loaded,
            user: user,
            todayStats: stats,
            currentTabIndex: isSwitchingToSimplified ? 0 : state.currentTabIndex,
          ),
        );
      } catch (e) {
        logger.e('Error loading home data: $e');
        // Vẫn giữ user cũ nếu có để tránh trắng màn hình hoàn toàn
        emit(
          state.copyWith(
            pageStatus: PageStatus.Error,
            pageErrorMessage: e.toString(),
            user: user ?? state.user,
          ),
        );
      }
    }, onError: (e) {
      if (isClosed) return;
      logger.e('User stream error: $e');
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    });
  }

  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  Future<void> exitSimplifiedMode() async {
    final uid = state.user?.uid;
    logger.d('exitSimplifiedMode called. uid: $uid');
    if (uid == null) return;

    final confirmed = await showConfirmDialog(
      'simplified.exit_confirm'.tr(),
    );
    logger.d('exitSimplifiedMode confirmed: $confirmed');

    if (!confirmed) return;

    try {
      showLoading();
      logger.d('exitSimplifiedMode calling update API...');
      await _updateUIPreferenceUseCase.call(
        params: UpdateUIPreferenceParams(uid: uid, preference: 'standard'),
      );
      logger.d('exitSimplifiedMode update API SUCCESS');
      hideLoading();

      // NOW we emit the UI preference. Doing this AFTER the update prevents the
      // Firebase Windows SDK from crashing due to active streams starting concurrently.
      logger.d('exitSimplifiedMode eagerly emitting standard UI preference');
      if (state.user != null) {
        if (!isClosed) emit(state.copyWith(
          user: state.user!.copyWith(uiPreference: 'standard'),
        ));
      }
    } catch (e) {
      hideLoading();
      logger.e('Failed to exit simplified mode: $e');
    }
  }

  Future<void> signOut() async {
    try {
      showLoading();
      await _signOutUseCase.call(params: null);
      hideLoading();
    } catch (e) {
      hideLoading();
      logger.e('Sign out failed: $e');
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
