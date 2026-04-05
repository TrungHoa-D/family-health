import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/save_medication_usecase.dart';
import 'package:family_health/domain/usecases/save_schedule_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'add_medication_cubit.freezed.dart';
part 'add_medication_state.dart';

@injectable
class AddMedicationCubit extends BaseCubit<AddMedicationState> {
  AddMedicationCubit(
    this._saveMedicationUseCase,
    this._saveScheduleUseCase,
    this._getUserUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const AddMedicationState());

  final SaveMedicationUseCase _saveMedicationUseCase;
  final SaveScheduleUseCase _saveScheduleUseCase;
  final GetUserUseCase _getUserUseCase;
  final FirebaseAuth _firebaseAuth;

  void init({Medication? medication, PatientSchedule? schedule}) {
    if (medication != null) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Loaded,
          isEditing: true,
          drugName: medication.name,
          dosage: medication.dosageStandard ?? '',
        ),
      );
    } 
    
    if (schedule != null) {
      emit(
        state.copyWith(
          selectedUser: schedule.targetUserId,
          anchorTime: schedule.timing['anchor_event'] ?? 'Sau ăn sáng',
          offset: schedule.timing['offset'].toString(),
          supervisor: 'Trung Hòa', // Mock for now
        ),
      );
    }
    
    if (medication == null && schedule == null) {
      emit(state.copyWith(pageStatus: PageStatus.Loaded));
    }
  }

  void updateDrugName(String value) {
    emit(
      state.copyWith(
        drugName: value,
        drugNameError: null,
      ),
    );
  }

  void updateDosage(String value) {
    emit(
      state.copyWith(
        dosage: value,
        dosageError: null,
      ),
    );
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
      emit(
        state.copyWith(
          drugNameError: drugNameError,
          dosageError: dosageError,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> save() async {
    if (!validate()) {
      return;
    }

    emit(state.copyWith(pageStatus: PageStatus.Loading));

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final userEntity = await _getUserUseCase.call(params: user.uid);
      final familyId = userEntity?.familyId;
      if (familyId == null) {
        throw Exception('Family not found');
      }

      final medicationId = state.isEditing 
          ? state.drugName.toLowerCase().replaceAll(' ', '_') // placeholder logic
          : DateTime.now().millisecondsSinceEpoch.toString();

      final medication = Medication(
        id: medicationId,
        name: state.drugName,
        dosageStandard: state.dosage,
        familyId: familyId,
        createdAt: DateTime.now(),
      );

      // 1. Save medication to cabinet
      await _saveMedicationUseCase.call(params: medication);

      // 2. Save schedule for user
      final schedule = PatientSchedule(
        id: 'sch_$medicationId',
        medId: medicationId,
        medName: state.drugName,
        familyId: familyId,
        targetUserId: user.uid, // Default to current user for simplicity in this form
        createdBy: user.uid,
        dosage: state.dosage,
        timing: {
          'anchor_event': state.anchorTime,
          'offset': int.tryParse(state.offset.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30,
          'type': 'offset',
        },
      );

      await _saveScheduleUseCase.call(params: schedule);

      emit(state.copyWith(pageStatus: PageStatus.Loaded, isSaved: true));
    } catch (e) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: e.toString(),
        ),
      );
    }
  }
}
