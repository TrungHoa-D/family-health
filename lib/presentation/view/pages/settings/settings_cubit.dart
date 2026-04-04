import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:family_health/domain/usecases/sign_out_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:family_health/domain/usecases/check_auth_status_usecase.dart';

import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/sync_user_usecase.dart';
import 'package:family_health/data/models/user_model.dart';
import 'package:family_health/shared/utils/logger.dart';
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SignOutUseCase _signOutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final GetUserUseCase _getUserUseCase;
  final SyncUserUseCase _syncUserUseCase;

  SettingsCubit(
    this._signOutUseCase,
    this._checkAuthStatusUseCase,
    this._getUserUseCase,
    this._syncUserUseCase,
  ) : super(const SettingsState()) {
    _loadMockData();
    _loadUserData();
  }

  void _loadMockData() {
    emit(state.copyWith(
      medicalRecord: const MedicalRecord(
        bloodType: 'O+',
        heightCm: 172,
        weightKg: 68,
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
          time: '12:30',
        ),
        DailyRoutine(
          title: 'Bữa tối',
          subtitle: 'Ăn nhẹ, trước 19h',
          time: '18:45',
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

