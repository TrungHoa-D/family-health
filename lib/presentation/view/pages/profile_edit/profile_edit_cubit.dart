import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/sync_user_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/data/models/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'profile_edit_cubit.freezed.dart';
part 'profile_edit_state.dart';

@injectable
class ProfileEditCubit extends BaseCubit<ProfileEditState> {
  final SyncUserUseCase _syncUserUseCase;

  ProfileEditCubit(this._syncUserUseCase) : super(const ProfileEditState());

  void init(UserEntity user) {
    emit(state.copyWith(
      pageStatus: PageStatus.Loaded,
      name: user.displayName ?? '',
      phone: user.phone ?? '',
    ));
  }

  void updateName(String value) {
    emit(state.copyWith(name: value));
  }

  void updatePhone(String value) {
    emit(state.copyWith(phone: value));
  }

  Future<void> updateProfile({
    required UserEntity currentUser,
  }) async {
    final name = state.name.trim();
    final phone = state.phone.trim();
    
    if (name.isEmpty) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: 'settings.name_required',
      ));
      return;
    }

    emit(state.copyWith(pageStatus: PageStatus.Uninitialized));

    try {
      final updatedUser = UserModel(
        uid: currentUser.uid,
        displayName: name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl,
        phone: phone,
        uiPreference: currentUser.uiPreference,
      );

      await _syncUserUseCase(params: updatedUser);
      emit(state.copyWith(
        pageStatus: PageStatus.Loaded,
        isSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }
}
