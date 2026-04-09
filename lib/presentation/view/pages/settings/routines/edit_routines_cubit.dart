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
  EditRoutinesCubit(this._saveHealthProfileUseCase) : super(const EditRoutinesState());

  final SaveHealthProfileUseCase _saveHealthProfileUseCase;

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
    emit(state.copyWith(pageStatus: PageStatus.Loading));
    try {
      // In a real app, we would update the health profile or user patterns in Firestore
      // For now, let's pretend we save it successfully
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(pageStatus: PageStatus.Loaded, isSaved: true));
    } catch (e) {
      emit(state.copyWith(pageStatus: PageStatus.Error, pageErrorMessage: e.toString()));
    }
  }
}
