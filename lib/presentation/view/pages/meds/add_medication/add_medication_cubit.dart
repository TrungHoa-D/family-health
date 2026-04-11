import 'dart:convert';
import 'dart:io';

import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/medication_category.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/usecases/get_ai_response_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/save_category_usecase.dart';
import 'package:family_health/domain/usecases/save_medication_usecase.dart';
import 'package:family_health/domain/usecases/save_schedule_usecase.dart';
import 'package:family_health/domain/usecases/watch_categories_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/services/media_service.dart';
import 'package:family_health/shared/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

part 'add_medication_cubit.freezed.dart';
part 'add_medication_state.dart';

@injectable
class AddMedicationCubit extends BaseCubit<AddMedicationState> {
  AddMedicationCubit(
    this._saveMedicationUseCase,
    this._saveScheduleUseCase,
    this._getUserUseCase,
    this._getAIResponseUseCase,
    this._notificationService,
    this._mediaService,
    this._watchCategoriesUseCase,
    this._saveCategoryUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const AddMedicationState());

  final SaveMedicationUseCase _saveMedicationUseCase;
  final SaveScheduleUseCase _saveScheduleUseCase;
  final GetUserUseCase _getUserUseCase;
  final GetAIResponseUseCase _getAIResponseUseCase;
  final NotificationService _notificationService;
  final MediaService _mediaService;
  final WatchCategoriesUseCase _watchCategoriesUseCase;
  final SaveCategoryUseCase _saveCategoryUseCase;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _categoriesSubscription;

  void init({Medication? medication, PatientSchedule? schedule}) async {
    if (medication != null) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Loaded,
          isEditing: true,
          editingMedicationId: medication.id,
          drugName: medication.name,
          dosage: medication.dosageStandard ?? '',
          selectedCategory: medication.categories.isNotEmpty
              ? medication.categories.first
              : 'KHÁC',
          imageUrl: medication.imageUrl,
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

    // Load categories from Firestore
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categoriesSubscription?.cancel();
    _categoriesSubscription = _watchCategoriesUseCase.call().listen(
      (categories) {
        emit(state.copyWith(availableCategories: categories));
      },
      onError: (_) {
        // Nếu chưa có collection thì bỏ qua
      },
    );
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

  void selectCategory(String value) {
    emit(state.copyWith(selectedCategory: value));
  }

  /// Tạo category mới với description
  Future<void> createCategory(String name, String description) async {
    final category = MedicationCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.toUpperCase(),
      description: description,
      icon: 'category',
      createdAt: DateTime.now(),
    );

    await _saveCategoryUseCase.call(params: category);
    emit(state.copyWith(selectedCategory: category.name));
  }

  Future<void> scanMedicationImage(File image) async {
    emit(state.copyWith(isScanning: true, scanError: null));

    try {
      // Lấy danh sách category từ server để AI chọn đúng
      final categoryList = state.categoryNames.isNotEmpty
          ? state.categoryNames.join(', ')
          : 'HUYẾT ÁP, TIỂU ĐƯỜNG, BỔ SUNG, KHÁC';

      final prompt = '''
        Bạn là một chuyên gia y tế AI. Hãy phân tích ảnh nhãn thuốc hoặc đơn thuốc được cung cấp.
        Trích xuất thông tin chính xác và trả về DƯỚI DẠNG JSON duy nhất như sau:
        {
          "name": "Tên thuốc",
          "dosage": "Liều lượng (ví dụ: 500mg, 1 viên)",
          "unit": "Đơn vị (viên, gói, ml)",
          "frequency": "Số lần mỗi ngày (ví dụ: 2 lần/ngày)",
          "instructions": "Chỉ dẫn (ví dụ: Sau khi ăn sáng, Trước khi đi ngủ)",
          "category": "Phân loại thuốc — ƯU TIÊN chọn 1 trong danh sách có sẵn: [$categoryList]. Nếu không có loại nào phù hợp, hãy TẠO MỚI tên phân loại (viết HOA, ngắn gọn 1-2 từ).",
          "category_description": "Mô tả ngắn gọn cho phân loại thuốc (VD: Thuốc điều trị và kiểm soát huyết áp). Chỉ điền nếu category là MỚI, không nằm trong danh sách trên. Nếu category đã có sẵn, để null.",
          "anchor_event": "Sự kiện mốc (chọn 1: Sau ăn sáng, Sau ăn trưa, Sau ăn tối, Trước đi ngủ)",
          "offset_minutes": 30
        }
        Nếu không có thông tin mốc thời gian rõ ràng, hãy mặc định anchor_event là "Sau ăn sáng".
        Nếu không chắc chắn ở trường nào, hãy để giá trị null. Trường category nếu không chắc hãy để "KHÁC".
        CHỈ trả về chuỗi JSON, không giải thích thêm.
      ''';

      final response = await _getAIResponseUseCase(
        params: GetAIResponseParams(prompt: prompt, image: image),
      );

      // Clean response (remove markdown blocks if present)
      final cleanJson =
          response.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      final scannedCategory = data['category'] as String?;
      final categoryDesc = data['category_description'] as String?;

      // Nếu AI trả về category mới chưa có trong danh sách → tự động tạo
      if (scannedCategory != null &&
          scannedCategory.isNotEmpty &&
          !state.categoryNames.contains(scannedCategory)) {
        final newCat = MedicationCategory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: scannedCategory,
          description: categoryDesc ?? 'Phân loại tự động từ AI',
          icon: 'category',
          createdAt: DateTime.now(),
        );
        await _saveCategoryUseCase.call(params: newCat);
      }

      emit(
        state.copyWith(
          isScanning: false,
          scannedImage: image,
          drugName: data['name'] ?? state.drugName,
          dosage: data['dosage'] ?? state.dosage,
          selectedCategory: scannedCategory ?? state.selectedCategory,
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

      final medicationId = state.isEditing && state.editingMedicationId != null
          ? state.editingMedicationId!
          : DateTime.now().millisecondsSinceEpoch.toString();

      String? finalImageUrl = state.imageUrl;

      // Upload hình nếu vừa scan
      if (state.scannedImage != null) {
        final ext = state.scannedImage!.path.split('.').last;
        final path = 'medications/$familyId/${medicationId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        finalImageUrl = await _mediaService.uploadImage(path, state.scannedImage!);
      }

      final medication = Medication(
        id: medicationId,
        name: state.drugName,
        dosageStandard: state.dosage,
        categories: [state.selectedCategory],
        imageUrl: finalImageUrl,
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

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
