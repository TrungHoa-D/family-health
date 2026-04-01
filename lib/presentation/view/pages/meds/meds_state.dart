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
  final String name;
  final String memberName;
  final String schedule;
  final String tag;
  final Color tagColor;
  final Color textColor;
  final String? imageUrl;

  MedicationModel({
    required this.name,
    required this.memberName,
    required this.schedule,
    required this.tag,
    required this.tagColor,
    required this.textColor,
    this.imageUrl,
  });
}

class MedicationRefillModel {
  final String name;
  final int remainingPills;

  MedicationRefillModel({
    required this.name,
    required this.remainingPills,
  });
}
