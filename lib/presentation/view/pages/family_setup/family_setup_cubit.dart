import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'family_setup_cubit.freezed.dart';
part 'family_setup_state.dart';

@injectable
class FamilySetupCubit extends BaseCubit<FamilySetupState> {
  FamilySetupCubit() : super(const FamilySetupState());

  void init() {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  void updateInviteCode(String code) {
    emit(state.copyWith(inviteCode: code.toUpperCase()));
  }

  void selectOption(FamilySetupOption option) {
    emit(state.copyWith(selectedOption: option));
  }

  bool submitForm() {
    emit(state.copyWith(isSubmitted: true));
    return state.isFormValid;
  }
}
