import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/get_health_profile_usecase.dart';
import 'package:family_health/domain/usecases/save_health_profile_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'edit_routines_cubit.freezed.dart';
part 'edit_routines_state.dart';

@injectable
class EditRoutinesCubit extends BaseCubit<EditRoutinesState> {
  EditRoutinesCubit(
    this._saveHealthProfileUseCase,
    this._getHealthProfileUseCase,
    this._authRepository,
  ) : super(const EditRoutinesState());

  final SaveHealthProfileUseCase _saveHealthProfileUseCase;
  final GetHealthProfileUseCase _getHealthProfileUseCase;
  final AuthRepository _authRepository;

  void init(List<DailyRoutine> initialRoutines) {
    emit(state.copyWith(
      pageStatus: PageStatus.Loaded,
      routines: initialRoutines.toList(),
    ));
  }

  void updateRoutineTime(int index, String newTime) {
    final newList = List<DailyRoutine>.from(state.routines);
    newList[index] = newList[index].copyWith(time: newTime);
    emit(state.copyWith(routines: newList));
  }

  Future<void> save() async {
    emit(state.copyWith(isSaving: true, saveError: null));
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final profile = await _getHealthProfileUseCase(params: user.uid);
      if (profile == null) {
        throw Exception('Health profile not found');
      }

      // Update AnchorTimes in profile
      final updatedProfile = profile.copyWith(
        anchorTimes: profile.anchorTimes.copyWith(
          breakfast: state.routines[0].time,
          lunch: state.routines[1].time,
          dinner: state.routines[2].time,
          sleep: state.routines[3].time,
        ),
      );

      await _saveHealthProfileUseCase(
        params: SaveHealthProfileParams(
          uid: user.uid,
          profile: updatedProfile,
        ),
      );

      emit(state.copyWith(isSaving: false, isSaved: true));
    } catch (e) {
      emit(state.copyWith(isSaving: false, saveError: e.toString()));
    }
  }
}
