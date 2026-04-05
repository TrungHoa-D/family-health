import 'dart:math' as math;

import 'package:family_health/domain/entities/family_group.dart';
import 'package:family_health/domain/repositories/family_repository_interface.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'family_group_state.dart';

@injectable
class FamilyGroupCubit extends BaseCubit<FamilyGroupState> {
  FamilyGroupCubit(
    this._familyRepository,
    this._userRepository,
    this._firebaseAuth,
  ) : super(const FamilyGroupState());
  final FamilyRepository _familyRepository;
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;

  void init() {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  void selectOption(FamilyGroupOption option) {
    emit(state.copyWith(selectedOption: option));
  }

  void updateGroupName(String name) {
    emit(state.copyWith(groupName: name));
  }

  void updateInviteCode(String code) {
    emit(state.copyWith(inviteCode: code.toUpperCase()));
  }

  Future<bool> submit() async {
    emit(state.copyWith(isSubmitted: true));
    if (!state.isFormValid) {
      return false;
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return false;
    }

    emit(state.copyWith(pageStatus: PageStatus.Loading));

    try {
      if (state.selectedOption == FamilyGroupOption.create) {
        final familyId = DateTime.now().millisecondsSinceEpoch.toString();
        final inviteCode = _generateInviteCode();

        final family = FamilyGroup(
          familyId: familyId,
          familyName: state.groupName,
          invitationCode: inviteCode,
          adminId: user.uid,
          memberIds: [user.uid],
          createdAt: DateTime.now(),
        );

        await _familyRepository.createFamilyGroup(family);

        final userEntity = await _userRepository.getUser(user.uid);
        if (userEntity != null) {
          await _userRepository
              .syncUser(userEntity.copyWith(familyId: familyId));
        }
      } else {
        await _familyRepository.joinFamilyGroup(user.uid, state.inviteCode);

        final family =
            await _familyRepository.getFamilyByInviteCode(state.inviteCode);
        if (family != null) {
          final userEntity = await _userRepository.getUser(user.uid);
          if (userEntity != null) {
            await _userRepository
                .syncUser(userEntity.copyWith(familyId: family.familyId));
          }
        }
      }

      emit(state.copyWith(pageStatus: PageStatus.Success));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (index) => chars[math.Random().nextInt(chars.length)],
    ).join();
  }
}
