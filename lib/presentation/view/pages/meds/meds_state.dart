part of 'meds_cubit.dart';

@freezed
class MedsState with _$MedsState implements BaseCubitState {
  const factory MedsState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(0) int selectedFilterIndex,
    @Default([]) List<MedicationModel> medications,
    @Default([]) List<MedicationRefillModel> refills,
  }) = _MedsState;

  const MedsState._();

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

class MedicationModel {
  MedicationModel({
    required this.id,
    required this.name,
    required this.dosageStandard,
    this.imageUrl,
    this.description,
    this.unit,
    this.categories = const [],
    this.stockQuantity,
    this.expiryDate,
    // Schedule info (UI combined)
    this.scheduleDescription,
    this.targetUserName,
    this.tag = 'KHÁC',
    this.tagColor = const Color(0xFFE3F2FD),
    this.textColor = const Color(0xFF1976D2),
  });

  final String id;
  final String name;
  final String dosageStandard;
  final String? imageUrl;
  final String? description;
  final String? unit;
  final List<String> categories;
  final int? stockQuantity;
  final DateTime? expiryDate;

  // Schedule/Usage info for UI display
  final String? scheduleDescription;
  final String? targetUserName;
  final String tag;
  final Color tagColor;
  final Color textColor;

  Medication toEntity() {
    return Medication(
      id: id,
      name: name,
      dosageStandard: dosageStandard,
      imageUrl: imageUrl,
      description: description,
      unit: unit,
      categories: categories,
      stockQuantity: stockQuantity,
      expiryDate: expiryDate,
    );
  }
}

class MedicationRefillModel {
  MedicationRefillModel({
    required this.name,
    required this.remainingPills,
  });
  final String name;
  final int remainingPills;
}
