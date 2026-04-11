import 'dart:io';

import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/sync_user_usecase.dart';
import 'package:family_health/domain/usecases/update_avatar_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'profile_edit_cubit.freezed.dart';
part 'profile_edit_state.dart';

@injectable
class ProfileEditCubit extends BaseCubit<ProfileEditState> {
  ProfileEditCubit(
    this._syncUserUseCase,
    this._updateAvatarUseCase,
  ) : super(const ProfileEditState());

  final SyncUserUseCase _syncUserUseCase;
  final UpdateAvatarUseCase _updateAvatarUseCase;

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

  void updateAvatarFile(File file) {
    emit(state.copyWith(avatarFile: file));
  }

  Future<void> updateProfile({
    required UserEntity currentUser,
  }) async {
    final name = state.name.trim();
    final phoneNumber = state.phoneNumber.trim();

    if (name.isEmpty) {
      emit(state.copyWith(saveError: 'settings.name_required'));
      return;
    }

    emit(state.copyWith(isSaving: true, saveError: null));

    try {
      String? avatarUrl = currentUser.avatarUrl;

      // Handle avatar upload if a new file is selected
      if (state.avatarFile != null) {
        avatarUrl = await _updateAvatarUseCase(
          params: UpdateAvatarParams(
            uid: currentUser.uid,
            image: state.avatarFile!,
          ),
        );
      }

      final updatedUser = currentUser.copyWith(
        displayName: name,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );

      await _syncUserUseCase(params: updatedUser);
      emit(state.copyWith(isSaving: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        saveError: e.toString(),
      ));
    }
  }
}
