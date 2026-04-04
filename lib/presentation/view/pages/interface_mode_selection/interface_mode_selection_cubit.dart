import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'interface_mode_selection_cubit.freezed.dart';
part 'interface_mode_selection_state.dart';

@injectable
class InterfaceModeSelectionCubit
    extends BaseCubit<InterfaceModeSelectionState> {
  InterfaceModeSelectionCubit(this._userRepository, this._firebaseAuth)
      : super(const InterfaceModeSelectionState());
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;

  void init() {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  void selectMode(InterfaceMode mode) {
    emit(state.copyWith(selectedMode: mode));
  }

  Future<bool> submitForm() async {
    emit(state.copyWith(isSubmitted: true, pageStatus: PageStatus.Loading));

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(state.copyWith(
            pageStatus: PageStatus.Error,
            pageErrorMessage: 'User not logged in',),);
        return false;
      }

      final userEntity = await _userRepository.getUser(user.uid);
      if (userEntity == null) {
        emit(state.copyWith(
            pageStatus: PageStatus.Error,
            pageErrorMessage: 'User data not found',),);
        return false;
      }

      await _userRepository.syncUser(
        userEntity.copyWith(
          uiPreference: state.selectedMode == InterfaceMode.standard
              ? 'standard'
              : 'simplified',
        ),
      );
      emit(state.copyWith(pageStatus: PageStatus.Loaded));
      return true;
    } catch (e) {
      emit(state.copyWith(
          pageStatus: PageStatus.Error, pageErrorMessage: e.toString(),),);
      return false;
    }
  }
}
