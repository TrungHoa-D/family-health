import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
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
}
