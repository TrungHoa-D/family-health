import 'package:family_health/domain/entities/family_group.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/family_repository_interface.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/view/pages/family_setup/family_setup_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FamilyRepository, UserRepository, FirebaseAuth, User])
import 'family_setup_cubit_test.mocks.dart';

void main() {
  late FamilySetupCubit cubit;
  late MockFamilyRepository mockFamilyRepository;
  late MockUserRepository mockUserRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockFamilyRepository = MockFamilyRepository();
    mockUserRepository = MockUserRepository();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');

    cubit = FamilySetupCubit(
      mockFamilyRepository,
      mockUserRepository,
      mockFirebaseAuth,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('FamilySetupCubit', () {
    test('Initial state is correct', () {
      expect(cubit.state.pageStatus, PageStatus.Uninitialized);
      expect(cubit.state.selectedOption, FamilySetupOption.create);
    });

    test('successfully creates family group', () async {
      when(mockFamilyRepository.createFamilyGroup(any))
          .thenAnswer((_) async => {});
      when(mockUserRepository.getUser('test-uid'))
          .thenAnswer((_) async => const UserEntity(uid: 'test-uid'));
      when(mockUserRepository.syncUser(any)).thenAnswer((_) async => {});

      cubit.updateGroupName('My Family');
      final result = await cubit.submitForm();

      expect(result, true);
      verify(mockFamilyRepository.createFamilyGroup(argThat(
        isA<FamilyGroup>().having((f) => f.familyName, 'familyName', 'My Family'),
      ),),).called(1);
    });

    test('successfully joins family group', () async {
      when(mockFamilyRepository.joinFamilyGroup('test-uid', 'INVITE'))
          .thenAnswer((_) async => {});
      when(mockFamilyRepository.getFamilyByInviteCode('INVITE')).thenAnswer(
          (_) async => FamilyGroup(
                familyId: 'fid',
                familyName: 'Joinee',
                invitationCode: 'INVITE',
                adminId: 'admin-id',
                memberIds: [],
                createdAt: DateTime.now(),),);
      when(mockUserRepository.getUser('test-uid'))
          .thenAnswer((_) async => const UserEntity(uid: 'test-uid'));
      when(mockUserRepository.syncUser(any)).thenAnswer((_) async => {});

      cubit.selectOption(FamilySetupOption.join);
      cubit.updateInviteCode('INVITE');
      final result = await cubit.submitForm();

      expect(result, true);
      verify(mockFamilyRepository.joinFamilyGroup('test-uid', 'INVITE'))
          .called(1);
    });

    test('Validation fails for empty group name on create', () async {
      cubit.selectOption(FamilySetupOption.create);
      cubit.updateGroupName('');
      final result = await cubit.submitForm();
      expect(result, false);
      expect(cubit.state.isFormValid, false);
    });
  });
}
