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
          description: medication.description ?? '',
          expiryDate: medication.expiryDate,
          stockQuantity: medication.stockQuantity?.toString() ?? '',
          unit: medication.unit ?? '',
          dosage: medication.dosageStandard ?? '',
          selectedCategory: medication.categories.isNotEmpty
              ? medication.categories.first
              : 'KHÁC',
          imageUrl: medication.imageUrl,
        ),
      );
    } else {
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

  void updateDescription(String value) {
    emit(state.copyWith(description: value));
  }

  void updateExpiryDate(DateTime? date) {
    emit(
      state.copyWith(
        expiryDate: date,
        expiryDateError: null,
      ),
    );
  }

  void updateStockQuantity(String value) {
    emit(state.copyWith(stockQuantity: value));
  }

  void updateUnit(String value) {
    emit(state.copyWith(unit: value));
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
          "category": "Phân loại thuốc — ƯU TIÊN chọn 1 trong danh sách có sẵn: [$categoryList]. Nếu không có loại nào phù hợp, hãy TẠO MỚI tên phân loại (viết HOA, ngắn gọn 1-2 từ).",
          "category_description": "Mô tả ngắn gọn cho phân loại thuốc (VD: Thuốc điều trị và kiểm soát huyết áp). Chỉ điền nếu category là MỚI, không nằm trong danh sách trên. Nếu category đã có sẵn, để null.",
          "description": "Mô tả / công dụng chính của thuốc",
          "unit": "Đơn vị (Viên, Gói, Lọ...)"
        }
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

      DateTime? parsedExpiryDate;
      if (data['expiry_date'] != null) {
        try {
          parsedExpiryDate = DateTime.parse(data['expiry_date'] as String);
        } catch (_) {}
      }

      emit(
        state.copyWith(
          isScanning: false,
          scannedImage: image,
          drugName: data['name'] ?? state.drugName,
          dosage: data['dosage'] ?? state.dosage,
          selectedCategory: scannedCategory ?? state.selectedCategory,
          description: data['description'] ?? state.description,
          stockQuantity: data['stock_quantity']?.toString() ?? state.stockQuantity,
          unit: data['unit'] ?? state.unit,
          expiryDate: parsedExpiryDate ?? state.expiryDate,
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
    String? expiryDateError;

    if (state.drugName.trim().isEmpty) {
      drugNameError = 'meds.validation_drug_name';
    }
    if (state.expiryDate == null) {
      expiryDateError = 'meds.validation_expiry_date';
    }

    if (drugNameError != null || expiryDateError != null) {
      emit(
        state.copyWith(
          drugNameError: drugNameError,
          expiryDateError: expiryDateError,
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
        description: state.description.isNotEmpty ? state.description : null,
        dosageStandard: state.dosage.isNotEmpty ? state.dosage : null,
        categories: [state.selectedCategory],
        stockQuantity: int.tryParse(state.stockQuantity) ?? 0,
        unit: state.unit.isNotEmpty ? state.unit : null,
        expiryDate: state.expiryDate,
        imageUrl: finalImageUrl,
        familyId: familyId,
        createdAt: DateTime.now(),
      );

      await _saveMedicationUseCase.call(params: medication);

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
