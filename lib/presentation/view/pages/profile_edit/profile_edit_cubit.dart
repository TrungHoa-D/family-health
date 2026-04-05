import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/sync_user_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'profile_edit_cubit.freezed.dart';
part 'profile_edit_state.dart';

@injectable
class ProfileEditCubit extends BaseCubit<ProfileEditState> {
  ProfileEditCubit(this._syncUserUseCase) : super(const ProfileEditState());
  final SyncUserUseCase _syncUserUseCase;

  void init(UserEntity user) {
    emit(
      state.copyWith(
        pageStatus: PageStatus.Loaded,
        name: user.displayName ?? '',
        phoneNumber: user.phoneNumber ?? '',
      ),
    );
  }

  void updateName(String value) {
    emit(state.copyWith(name: value));
  }

  void updatePhone(String value) {
    emit(state.copyWith(phoneNumber: value));
  }

  Future<void> updateProfile({
    required UserEntity currentUser,
  }) async {
    final name = state.name.trim();
    final phoneNumber = state.phoneNumber.trim();

    if (name.isEmpty) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: 'settings.name_required',
        ),
      );
      return;
    }

    emit(state.copyWith(pageStatus: PageStatus.Uninitialized));

    try {
      final updatedUser = currentUser.copyWith(
        displayName: name,
        phoneNumber: phoneNumber,
      );

      await _syncUserUseCase(params: updatedUser);
      emit(
        state.copyWith(
          pageStatus: PageStatus.Loaded,
          isSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: e.toString(),
        ),
      );
    }
  }
}
