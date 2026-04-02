import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'add_medication_cubit.freezed.dart';
part 'add_medication_state.dart';

@injectable
class AddMedicationCubit extends BaseCubit<AddMedicationState> {
  AddMedicationCubit() : super(const AddMedicationState());

  void init({MedicationModel? medication}) {
    if (medication != null) {
      emit(state.copyWith(
        pageStatus: PageStatus.Loaded,
        isEditing: true,
        drugName: medication.name,
        dosage: medication.dosage ?? '',
        selectedUser: medication.memberName,
        anchorTime: medication.anchorTime ?? 'Sau ăn sáng',
        offset: medication.offset ?? 'Sau 30p',
        supervisor: medication.supervisorNames.isNotEmpty
            ? medication.supervisorNames.first
            : 'Trung Hòa',
      ));
    } else {
      emit(state.copyWith(pageStatus: PageStatus.Loaded));
    }
  }

  void updateDrugName(String value) {
    emit(state.copyWith(
      drugName: value,
      drugNameError: null,
    ));
  }

  void updateDosage(String value) {
    emit(state.copyWith(
      dosage: value,
      dosageError: null,
    ));
  }

  void selectUser(String value) {
    emit(state.copyWith(selectedUser: value));
  }

  void selectAnchorTime(String value) {
    emit(state.copyWith(anchorTime: value));
  }

  void selectOffset(String value) {
    emit(state.copyWith(offset: value));
  }

  void selectSupervisor(String value) {
    emit(state.copyWith(supervisor: value));
  }

  bool validate() {
    String? drugNameError;
    String? dosageError;

    if (state.drugName.trim().isEmpty) {
      drugNameError = 'meds.validation_drug_name';
    }
    if (state.dosage.trim().isEmpty) {
      dosageError = 'meds.validation_dosage';
    }

    if (drugNameError != null || dosageError != null) {
      emit(state.copyWith(
        drugNameError: drugNameError,
        dosageError: dosageError,
      ));
      return false;
    }
    return true;
  }

  void save() {
    if (!validate()) return;

    // TODO: Save to Firestore
    emit(state.copyWith(isSaved: true));
  }
}
