import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'meds_cubit.freezed.dart';
part 'meds_state.dart';

@injectable
class MedsCubit extends BaseCubit<MedsState> {
  MedsCubit() : super(const MedsState());

  void loadData() {
    emit(state.copyWith(
      pageStatus: PageStatus.Loaded,
      medications: [
        MedicationModel(
          name: 'Losartan 50mg',
          memberName: 'Bố',
          schedule: 'Sáng & Tối | 1 viên',
          tag: 'HUYẾT ÁP',
          tagColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1976D2),
        ),
        MedicationModel(
          name: 'Glucophage 500mg',
          memberName: 'Mẹ',
          schedule: 'Sau ăn sáng | 1 viên',
          tag: 'TIỂU ĐƯỜNG',
          tagColor: const Color(0xFFFFF3E0),
          textColor: const Color(0xFFF57C00),
        ),
        MedicationModel(
          name: 'Vitamin C 1000mg',
          memberName: 'Em',
          schedule: 'Sáng | 1 viên',
          tag: 'BỔ SUNG',
          tagColor: const Color(0xFFE0F2F1),
          textColor: const Color(0xFF00796B),
        ),
      ],
      refills: [
        MedicationRefillModel(
          name: 'Paracetamol 500mg',
          remainingPills: 2,
        ),
      ],
    ));
  }

  void changeFilter(int index) {
    emit(state.copyWith(selectedFilterIndex: index));
  }
}
