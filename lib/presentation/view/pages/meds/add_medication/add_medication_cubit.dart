import 'dart:convert';
import 'dart:io';

import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/usecases/get_ai_response_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/save_medication_usecase.dart';
import 'package:family_health/domain/usecases/save_schedule_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/services/notification_service.dart';
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
    this._getUserUseCase,
    this._getAIResponseUseCase,
    this._notificationService, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const AddMedicationState());

  final SaveMedicationUseCase _saveMedicationUseCase;
  final SaveScheduleUseCase _saveScheduleUseCase;
  final GetUserUseCase _getUserUseCase;
  final GetAIResponseUseCase _getAIResponseUseCase;
  final NotificationService _notificationService;
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

  Future<void> scanMedicationImage(File image) async {
    emit(state.copyWith(isScanning: true, scanError: null));

    try {
      const prompt = '''
        Bạn là một chuyên gia y tế AI. Hãy phân tích ảnh nhãn thuốc hoặc đơn thuốc được cung cấp.
        Trích xuất thông tin chính xác và trả về DƯỚI DẠNG JSON duy nhất như sau:
        {
          "name": "Tên thuốc",
          "dosage": "Liều lượng (ví dụ: 500mg, 1 viên)",
          "unit": "Đơn vị (viên, gói, ml)",
          "frequency": "Số lần mỗi ngày (ví dụ: 2 lần/ngày)",
          "instructions": "Chỉ dẫn (ví dụ: Sau khi ăn sáng, Trước khi đi ngủ)",
          "anchor_event": "Sự kiện mốc (chọn 1: Sau ăn sáng, Sau ăn trưa, Sau ăn tối, Trước đi ngủ)",
          "offset_minutes": 30
        }
        Nếu không có thông tin mốc thời gian rõ ràng, hãy mặc định anchor_event là "Sau ăn sáng".
        Nếu không chắc chắn ở trường nào, hãy để giá trị null. 
        CHỈ trả về chuỗi JSON, không giải thích thêm.
      ''';

      final response = await _getAIResponseUseCase(
        params: GetAIResponseParams(prompt: prompt, image: image),
      );

      // Clean response (remove markdown blocks if present)
      final cleanJson =
          response.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      emit(
        state.copyWith(
          isScanning: false,
          drugName: data['name'] ?? state.drugName,
          dosage: data['dosage'] ?? state.dosage,
          frequency: data['frequency'] ?? state.frequency,
          instructions: data['instructions'] ?? state.instructions,
          anchorTime: data['anchor_event'] ?? state.anchorTime,
          offset: 'Sau ${data['offset_minutes'] ?? 30}p',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isScanning: false,
          scanError: 'Không thể phân tích ảnh: ${e.toString()}',
        ),
      );
    }
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

    await _notificationService.requestPermissions();

    emit(state.copyWith(isSaving: true, saveError: null));

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

      final schedule = PatientSchedule(
        id: 'sch_$medicationId',
        medId: medicationId,
        medName: state.drugName,
        familyId: familyId,
        targetUserId: user.uid,
        createdBy: user.uid,
        dosage: state.dosage,
        timing: {
          'anchor_event': state.anchorTime,
          'offset': int.tryParse(state.offset.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30,
          'type': 'offset',
        },
      );

      // Gọi song song save medication + save schedule
      await Future.wait([
        _saveMedicationUseCase.call(params: medication),
        _saveScheduleUseCase.call(params: schedule),
      ]);

      // Schedule notifications sau khi save xong
      if (state.isEditing) {
        await _notificationService.cancelMedicationReminders(schedule.id);
      }
      await _notificationService.scheduleMedicationReminders(schedule);

      emit(state.copyWith(isSaving: false, isSaved: true));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        saveError: e.toString(),
      ));
    }
  }
}
