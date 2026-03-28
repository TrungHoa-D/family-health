part of 'interface_mode_selection_cubit.dart';

@freezed
class InterfaceModeSelectionState
    with _$InterfaceModeSelectionState
    implements BaseCubitState {
  const factory InterfaceModeSelectionState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,

    // Interface mode selection
    @Default(InterfaceMode.standard) InterfaceMode selectedMode,

    // Validation
    @Default(false) bool isSubmitted,
  }) = _InterfaceModeSelectionState;

  const InterfaceModeSelectionState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage,
    );
  }
}

enum InterfaceMode { standard, simplified }
