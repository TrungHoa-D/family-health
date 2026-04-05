import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'dosage_standard') String? dosageStandard,
    String? unit,
    @Default([]) List<String> categories,
    @JsonKey(name: 'stock_quantity') int? stockQuantity,
    @JsonKey(name: 'expiry_date') DateTime? expiryDate,
    @JsonKey(name: 'family_id') String? familyId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}
