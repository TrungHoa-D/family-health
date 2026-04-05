import 'dart:async';

import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/watch_medications_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'meds_cubit.freezed.dart';
part 'meds_state.dart';

@injectable
class MedsCubit extends BaseCubit<MedsState> {
  MedsCubit(
    this._watchMedicationsUseCase,
    this._getUserUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const MedsState());

  final WatchMedicationsUseCase _watchMedicationsUseCase;
  final GetUserUseCase _getUserUseCase;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _medsSubscription;

  Future<void> loadData() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: 'User not logged in',
        ),
      );
      return;
    }

    final userEntity = await _getUserUseCase.call(params: user.uid);
    final familyId = userEntity?.familyId;

    if (familyId == null) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: 'No family group found',
        ),
      );
      return;
    }

    _medsSubscription?.cancel();
    _medsSubscription = _watchMedicationsUseCase.call(familyId).listen(
      (meds) {
        final uiModels = meds.map(_mapToUiModel).toList();
        emit(
          state.copyWith(
            pageStatus: PageStatus.Loaded,
            medications: uiModels,
          ),
        );
      },
      onError: (e) {
        emit(
          state.copyWith(
            pageStatus: PageStatus.Error,
            pageErrorMessage: e.toString(),
          ),
        );
      },
    );
  }

  MedicationModel _mapToUiModel(Medication med) {
    // Default colors based on categories or tags
    Color tagColor = const Color(0xFFE3F2FD);
    Color textColor = const Color(0xFF1976D2);

    final tag = med.categories.isNotEmpty ? med.categories.first : 'KHÁC';

    if (tag == 'TIỂU ĐƯỜNG') {
      tagColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFF57C00);
    } else if (tag == 'BỔ SUNG') {
      tagColor = const Color(0xFFE0F2F1);
      textColor = const Color(0xFF00796B);
    }

    return MedicationModel(
      id: med.id,
      name: med.name,
      dosageStandard: med.dosageStandard ?? '',
      imageUrl: med.imageUrl,
      description: med.description,
      unit: med.unit,
      categories: med.categories,
      stockQuantity: med.stockQuantity,
      expiryDate: med.expiryDate,
      tag: tag,
      tagColor: tagColor,
      textColor: textColor,
    );
  }

  void changeFilter(int index) {
    emit(state.copyWith(selectedFilterIndex: index));
  }

  @override
  Future<void> close() {
    _medsSubscription?.cancel();
    return super.close();
  }
}
