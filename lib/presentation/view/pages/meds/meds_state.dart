part of 'meds_cubit.dart';

@freezed
class MedsState with _$MedsState implements BaseCubitState {
  const factory MedsState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(0) int selectedFilterIndex,
    @Default([]) List<MedicationModel> medications,
    @Default([]) List<MedicationRefillModel> refills,
    @Default([]) List<MedicationCategory> allCategories,
  }) = _MedsState;

  const MedsState._();

  /// Top 3 categories có nhiều thuốc nhất
  List<String> get topCategoryNames {
    // Đếm số lượng thuốc mỗi category
    final countMap = <String, int>{};
    for (final med in medications) {
      for (final cat in med.categories) {
        countMap[cat] = (countMap[cat] ?? 0) + 1;
      }
    }

    // Sắp xếp theo số lượng giảm dần, lấy top 3
    final sorted = countMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Danh sách filter labels cho filter bar: "Tất cả" + top 3
  List<String?> get filterCategories {
    return [
      null, // index 0 = Tất cả
      ...topCategoryNames,
    ];
  }

  List<MedicationModel> get filteredMedications {
    if (selectedFilterIndex == 0) return medications;
    if (selectedFilterIndex >= filterCategories.length) return medications;
    final category = filterCategories[selectedFilterIndex];
    if (category == null) return medications;
    return medications
        .where((m) => m.categories.contains(category))
        .toList();
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
    this.createdAt,
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
  final DateTime? createdAt;

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
      createdAt: createdAt,
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

