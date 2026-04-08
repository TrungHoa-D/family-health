import 'package:family_health/domain/entities/family_group.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/family_repository_interface.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/usecases/fetch_family_usecase.dart';
import 'package:family_health/domain/usecases/get_family_members_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'family_management_cubit.freezed.dart';
part 'family_management_state.dart';

@injectable
class FamilyManagementCubit extends BaseCubit<FamilyManagementState> {
  FamilyManagementCubit(
    this._fetchFamilyUseCase,
    this._getFamilyMembersUseCase,
    this._familyRepository,
    this._userRepository,
    this._firebaseAuth,
  ) : super(const FamilyManagementState());

  final FetchFamilyUseCase _fetchFamilyUseCase;
  final GetFamilyMembersUseCase _getFamilyMembersUseCase;
  final FamilyRepository _familyRepository;
  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;

  Future<void> loadData() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userEntity = await _userRepository.getUser(user.uid);
      final familyId = userEntity?.familyId;

      if (familyId == null) {
        emit(state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: 'Bạn chưa tham gia nhóm gia đình nào.',
        ));
        return;
      }

      final family = await _fetchFamilyUseCase.call(params: familyId);
      if (family == null) throw Exception('Không tìm thấy dữ liệu gia đình.');

      final members =
          await _getFamilyMembersUseCase.call(params: family.memberIds);

      emit(state.copyWith(
        pageStatus: PageStatus.Loaded,
        family: family,
        members: members,
        isAdmin: family.adminId == user.uid,
      ));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> leaveFamily() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));
    try {
      final user = _firebaseAuth.currentUser;
      final family = state.family;
      if (user == null || family == null) return;

      final updatedMembers = List<String>.from(family.memberIds)
        ..remove(user.uid);
      await _familyRepository
          .updateFamilyGroup(family.copyWith(memberIds: updatedMembers));

      final userEntity = await _userRepository.getUser(user.uid);
      if (userEntity != null) {
        await _userRepository.syncUser(userEntity.copyWith(familyId: null));
      }

      emit(state.copyWith(pageStatus: PageStatus.Loaded, isLeaved: true));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> disbandGroup() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));
    try {
      final family = state.family;
      if (family == null) return;

      for (final memberId in family.memberIds) {
        final u = await _userRepository.getUser(memberId);
        if (u != null) {
          await _userRepository.syncUser(u.copyWith(familyId: null));
        }
      }

      await _familyRepository.deleteFamilyGroup(family.familyId);

      emit(state.copyWith(pageStatus: PageStatus.Loaded, isLeaved: true));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }
}
