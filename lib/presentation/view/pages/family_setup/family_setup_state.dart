part of 'family_setup_cubit.dart';

@freezed
class FamilySetupState with _$FamilySetupState implements BaseCubitState {
  const factory FamilySetupState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,

    // Form fields
    @Default(FamilySetupOption.create) FamilySetupOption selectedOption,
    @Default('') String inviteCode,

    // Validation
    @Default(false) bool isSubmitted,
  }) = _FamilySetupState;

  const FamilySetupState._();

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

  String? get inviteCodeError {
    if (!isSubmitted) {
      return null;
    }
    if (inviteCode.isEmpty) {
      return 'required';
    }
    if (inviteCode.length < 6) {
      return 'invalid';
    }
    return null;
  }

  bool get isFormValid {
    if (selectedOption == FamilySetupOption.create) {
      return true;
    }
    return inviteCode.length == 6;
  }
}

enum FamilySetupOption { create, join }
