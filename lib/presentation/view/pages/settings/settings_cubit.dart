import 'package:family_health/domain/usecases/get_health_profile_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:family_health/domain/usecases/sign_out_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:family_health/domain/usecases/check_auth_status_usecase.dart';

import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/sync_user_usecase.dart';
import 'package:family_health/data/models/user_model.dart';
import 'package:family_health/shared/utils/logger.dart';
import 'package:family_health/domain/entities/health_profile.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SignOutUseCase _signOutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final GetUserUseCase _getUserUseCase;
  final SyncUserUseCase _syncUserUseCase;
  final GetHealthProfileUseCase _getHealthProfileUseCase;

  SettingsCubit(
    this._signOutUseCase,
    this._checkAuthStatusUseCase,
    this._getUserUseCase,
    this._syncUserUseCase,
    this._getHealthProfileUseCase,
  ) : super(const SettingsState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await refreshData();
  }

  Future<void> refreshData() async {
    try {
      final authUser = await _checkAuthStatusUseCase(params: null);
      if (authUser != null) {
        // Load User Info
        final userData = await _getUserUseCase(params: authUser.uid);
        if (userData != null) {
          emit(state.copyWith(user: userData));
        }

        // Load Health Profile
        final healthProfile = await _getHealthProfileUseCase(params: authUser.uid);
        if (healthProfile != null) {
          emit(state.copyWith(medicalRecord: healthProfile));
          
          // Update routines based on anchor times if available
          _updateRoutinesFromHealthProfile(healthProfile);
        } else {
          // If no profile from Firebase, use mock data or keep defaults
          _loadMockData();
        }
      }
    } catch (e) {
      logger.e('Failed to refresh data: $e');
    }
  }

  void _updateRoutinesFromHealthProfile(HealthProfile profile) {
    emit(state.copyWith(
      routines: [
        DailyRoutine(
          title: 'Bữa sáng',
          subtitle: 'Thanh đạm, ít béo',
          time: profile.anchorTimes.breakfast,
        ),
        DailyRoutine(
          title: 'Bữa trưa',
          subtitle: 'Đầy đủ dinh dưỡng',
          time: profile.anchorTimes.lunch,
        ),
        DailyRoutine(
          title: 'Bữa tối',
          subtitle: 'Ăn nhẹ, trước 19h',
          time: profile.anchorTimes.dinner,
        ),
        DailyRoutine(
          title: 'Đi ngủ',
          subtitle: 'Môi trường yên tĩnh',
          time: profile.anchorTimes.sleep,
        ),
      ],
    ));
  }

  void _loadMockData() {
    emit(state.copyWith(
      medicalRecord: HealthProfile(
        height: '170',
        weight: '65',
        bloodType: 'O',
        isRhPositive: true,
        isMale: true,
        birthDate: DateTime(2026, 3, 24),
        medicalHistory: ['Huyết áp cao'],
        anchorTimes: const AnchorTimes(
          breakfast: '07:00',
          lunch: '12:00',
          dinner: '19:00',
          sleep: '22:00',
        ),
      ),
      routines: const [
        DailyRoutine(
          title: 'Bữa sáng',
          subtitle: 'Thanh đạm, ít béo',
          time: '07:00',
        ),
        DailyRoutine(
          title: 'Bữa trưa',
          subtitle: 'Đầy đủ dinh dưỡng',
          time: '12:00',
        ),
        DailyRoutine(
          title: 'Bữa tối',
          subtitle: 'Ăn nhẹ, trước 19h',
          time: '19:00',
        ),
        DailyRoutine(
          title: 'Đi ngủ',
          subtitle: 'Môi trường yên tĩnh',
          time: '22:00',
        ),
      ]
    ));
  }

  Future<void> _loadUserData() async {
    try {
      final authUser = await _checkAuthStatusUseCase(params: null);
      if (authUser != null) {
        final userData = await _getUserUseCase(params: authUser.uid);
        if (userData != null) {
          emit(state.copyWith(user: userData));
        }
      }
    } catch (e) {
      logger.e('Failed to load user data: $e');
    }
  }

  Future<void> updateProfile({required String name, String? phone}) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    emit(state.copyWith(isUpdatingProfile: true));

    try {
      final updatedUser = UserModel(
        uid: currentUser.uid,
        displayName: name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
        phone: phone,
      );

      await _syncUserUseCase(params: updatedUser);
      
      // Reload user data
      await _loadUserData();
      
      emit(state.copyWith(isUpdatingProfile: false));
    } catch (e) {
      logger.e('Failed to update profile: $e');
      emit(state.copyWith(isUpdatingProfile: false));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoggingOut: true));
    try {
      await _signOutUseCase(params: null);
      emit(state.copyWith(isLoggingOut: false, isLoggedOut: true));
    } catch (e) {
      logger.e('Logout failed: $e');
      emit(state.copyWith(isLoggingOut: false));
    }
  }
}

