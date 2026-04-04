import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/usecases/check_auth_status_usecase.dart';
import 'package:family_health/domain/usecases/save_health_profile_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'setup_health_profile_cubit.freezed.dart';
part 'setup_health_profile_state.dart';

@injectable
class SetupHealthProfileCubit extends BaseCubit<SetupHealthProfileState> {
  final SaveHealthProfileUseCase _saveHealthProfileUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  SetupHealthProfileCubit(
    this._saveHealthProfileUseCase,
    this._checkAuthStatusUseCase,
  ) : super(const SetupHealthProfileState());

  void init() {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  void initWithProfile(HealthProfile profile) {
    emit(state.copyWith(
      height: profile.height,
      weight: profile.weight,
      selectedBloodType: profile.bloodType,
      isRhPositive: profile.isRhPositive,
      selectedDiseases: profile.medicalHistory,
      isMale: profile.isMale,
      birthDate: profile.birthDate,
      breakfastTime: profile.anchorTimes.breakfast,
      lunchTime: profile.anchorTimes.lunch,
      dinnerTime: profile.anchorTimes.dinner,
      sleepTime: profile.anchorTimes.sleep,
      otherDisease: profile.otherDisease ?? '',
      isShowingOtherDiseaseInput:
          profile.otherDisease != null && profile.otherDisease!.isNotEmpty,
      isUpdateMode: true,
      pageStatus: PageStatus.Loaded,
    ));
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

  void updateGender(bool isMale) {
    emit(state.copyWith(isMale: isMale));
  }

  void updateBirthDate(DateTime date) {
    emit(state.copyWith(birthDate: date));
  }

  void updateAnchorTime(String type, String time) {
    switch (type) {
      case 'breakfast':
        emit(state.copyWith(breakfastTime: time));
        break;
      case 'lunch':
        emit(state.copyWith(lunchTime: time));
        break;
      case 'dinner':
        emit(state.copyWith(dinnerTime: time));
        break;
      case 'sleep':
        emit(state.copyWith(sleepTime: time));
        break;
    }
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

  /// Trả về true nếu form thành công, false nếu không
  Future<bool> submitForm() async {
    emit(state.copyWith(isSubmitted: true));
    if (!state.isFormValid) return false;

    emit(state.copyWith(pageStatus: PageStatus.Loading));

    try {
      final user = await _checkAuthStatusUseCase(params: null);
      if (user == null) {
        emit(state.copyWith(pageStatus: PageStatus.Error));
        return false;
      }

      final profile = HealthProfile(
        height: state.height,
        weight: state.weight,
        bloodType: state.selectedBloodType,
        isRhPositive: state.isRhPositive,
        isMale: state.isMale,
        birthDate: state.birthDate,
        medicalHistory: state.selectedDiseases,
        otherDisease: state.isShowingOtherDiseaseInput ? state.otherDisease : null,
        anchorTimes: AnchorTimes(
          breakfast: state.breakfastTime,
          lunch: state.lunchTime,
          dinner: state.dinnerTime,
          sleep: state.sleepTime,
        ),
      );

      await _saveHealthProfileUseCase(
        params: SaveHealthProfileParams(uid: user.uid, profile: profile),
      );

      emit(state.copyWith(pageStatus: PageStatus.Success));
      return true;
    } catch (e) {
      emit(state.copyWith(pageStatus: PageStatus.Error));
      return false;
    }
  }
}
