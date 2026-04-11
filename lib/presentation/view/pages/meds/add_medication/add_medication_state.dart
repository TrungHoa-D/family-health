part of 'add_medication_cubit.dart';

@freezed
class AddMedicationState with _$AddMedicationState implements BaseCubitState {
  const factory AddMedicationState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(false) bool isEditing,
    String? editingMedicationId,
    @Default('') String drugName,
    @Default('') String dosage,
    @Default('KHÁC') String selectedCategory,
    @Default('') String frequency,
    @Default('') String instructions,
    File? scannedImage,
    String? imageUrl,
    @Default('Bố') String selectedUser,
    @Default('Sau ăn sáng') String anchorTime,
    @Default('Sau 30p') String offset,
    @Default('Trung Hòa') String supervisor,
    String? drugNameError,
    String? dosageError,
    @Default(false) bool isSaving,
    @Default(false) bool isSaved,
    String? saveError,
    @Default(false) bool isScanning,
    String? scanError,
  }) = _AddMedicationState;

  const AddMedicationState._();

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
}
