import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_category.freezed.dart';
part 'medication_category.g.dart';

@freezed
class MedicationCategory with _$MedicationCategory {
  const factory MedicationCategory({
    required String id,
    required String name,
    String? description,
    @Default('category') String icon,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MedicationCategory;

  factory MedicationCategory.fromJson(Map<String, dynamic> json) =>
      _$MedicationCategoryFromJson(json);
}

