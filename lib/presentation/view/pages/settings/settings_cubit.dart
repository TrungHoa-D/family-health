import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:family_health/domain/usecases/sign_out_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:family_health/shared/utils/logger.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SignOutUseCase _signOutUseCase;

  SettingsCubit(this._signOutUseCase) : super(const SettingsState()) {
    _loadMockData();
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

