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
    @Default('') String description,
    File? scannedImage,
    String? imageUrl,
    DateTime? expiryDate,
    @Default('') String stockQuantity,
    @Default('') String unit,
    String? drugNameError,
    String? dosageError,
    String? expiryDateError,
    @Default(false) bool isSaving,
    @Default(false) bool isSaved,
    String? saveError,
    @Default(false) bool isScanning,
    String? scanError,
    @Default([]) List<MedicationCategory> availableCategories,
  }) = _AddMedicationState;

  const AddMedicationState._();

  /// Tên các category từ Firestore để hiển thị chip
  List<String> get categoryNames {
    return availableCategories.map((c) => c.name).toList();
  }

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
