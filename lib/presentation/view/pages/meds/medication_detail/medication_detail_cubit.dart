import 'package:family_health/domain/usecases/delete_medication_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'medication_detail_cubit.freezed.dart';
part 'medication_detail_state.dart';

@injectable
class MedicationDetailCubit extends BaseCubit<MedicationDetailState> {
  MedicationDetailCubit(this._deleteMedicationUseCase)
      : super(const MedicationDetailState());

  final DeleteMedicationUseCase _deleteMedicationUseCase;

  void loadMedication(MedicationModel medication) {
    emit(
      state.copyWith(
        pageStatus: PageStatus.Loaded,
        medication: medication,
      ),
    );
  }

  Future<void> deleteMedication() async {
    if (state.medication != null) {
      try {
        await _deleteMedicationUseCase(params: state.medication!.id);
      } catch (e) {
        // Handle error if needed
      }
    }
  }

  void copyMedication() {
    // TODO(TrungHoa): Copy medication to another member
  }
}
