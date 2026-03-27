import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'setup_health_profile_cubit.freezed.dart';
part 'setup_health_profile_state.dart';

@injectable
class SetupHealthProfileCubit extends BaseCubit<SetupHealthProfileState> {
  SetupHealthProfileCubit() : super(const SetupHealthProfileState());

  void init() {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  void updateHeight(String value) {
    emit(state.copyWith(height: value));
  }

  void updateWeight(String value) {
    emit(state.copyWith(weight: value));
  }

  void selectBloodType(String type) {
    emit(state.copyWith(selectedBloodType: type));
  }

  void toggleRhFactor(bool isPositive) {
    emit(state.copyWith(isRhPositive: isPositive));
  }

  void toggleDisease(String disease) {
    final current = List<String>.from(state.selectedDiseases);
    if (current.contains(disease)) {
      current.remove(disease);
    } else {
      current.add(disease);
    }
    emit(state.copyWith(selectedDiseases: current));
  }

  void toggleOtherDiseaseInput() {
    emit(state.copyWith(
        isShowingOtherDiseaseInput: !state.isShowingOtherDiseaseInput));
  }

  void updateOtherDisease(String value) {
    emit(state.copyWith(otherDisease: value));
  }

  /// Trả về true nếu form hợp lệ, false nếu không
  bool submitForm() {
    emit(state.copyWith(isSubmitted: true));
    return state.isFormValid;
  }
}
