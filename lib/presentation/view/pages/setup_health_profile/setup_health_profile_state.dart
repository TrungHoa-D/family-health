part of 'setup_health_profile_cubit.dart';

@freezed
class SetupHealthProfileState
    with _$SetupHealthProfileState
    implements BaseCubitState {
  const factory SetupHealthProfileState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,

    // Form fields
    @Default('') String height,
    @Default('') String weight,
    @Default(null) String? selectedBloodType,
    @Default(true) bool isRhPositive,
    @Default([]) List<String> selectedDiseases,

    // New fields
    @Default(true) bool isMale,
    DateTime? birthDate,
    @Default('07:00') String breakfastTime,
    @Default('12:00') String lunchTime,
    @Default('19:00') String dinnerTime,
    @Default('22:00') String sleepTime,

    // Other disease
    @Default(false) bool isShowingOtherDiseaseInput,
    @Default('') String otherDisease,

    // Mode
    @Default(false) bool isUpdateMode,

    // Validation
    @Default(false) bool isSubmitted,
    @Default(false) bool isSaving,
  }) = _SetupHealthProfileState;

  const SetupHealthProfileState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage,
    );
  }

  // Validation getters
  String? get heightError {
    if (!isSubmitted) {
      return null;
    }
    if (height.isEmpty) {
      return 'required';
    }
    final value = double.tryParse(height);
    if (value == null || value <= 0 || value > 300) {
      return 'invalid';
    }
    return null;
  }

  String? get weightError {
    if (!isSubmitted) {
      return null;
    }
    if (weight.isEmpty) {
      return 'required';
    }
    final value = double.tryParse(weight);
    if (value == null || value <= 0 || value > 500) {
      return 'invalid';
    }
    return null;
  }

  String? get bloodTypeError {
    if (!isSubmitted) {
      return null;
    }
    if (selectedBloodType == null) {
      return 'required';
    }
    return null;
  }

  bool get isFormValid {
    if (height.isEmpty) {
      return false;
    }
    final h = double.tryParse(height);
    if (h == null || h <= 0 || h > 300) {
      return false;
    }
    if (weight.isEmpty) {
      return false;
    }
    final w = double.tryParse(weight);
    if (w == null || w <= 0 || w > 500) {
      return false;
    }
    if (selectedBloodType == null) {
      return false;
    }
    return true;
  }
}
