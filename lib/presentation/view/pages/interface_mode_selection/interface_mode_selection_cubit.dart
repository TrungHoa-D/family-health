import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'interface_mode_selection_cubit.freezed.dart';
part 'interface_mode_selection_state.dart';

@injectable
class InterfaceModeSelectionCubit
    extends BaseCubit<InterfaceModeSelectionState> {
  InterfaceModeSelectionCubit() : super(const InterfaceModeSelectionState());

  void init() {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  void selectMode(InterfaceMode mode) {
    emit(state.copyWith(selectedMode: mode));
  }

  bool submitForm() {
    emit(state.copyWith(isSubmitted: true));
    return true;
  }
}
