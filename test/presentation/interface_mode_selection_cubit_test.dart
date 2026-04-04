import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/view/pages/interface_mode_selection/interface_mode_selection_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserRepository, FirebaseAuth, User])
import 'interface_mode_selection_cubit_test.mocks.dart';

void main() {
  late InterfaceModeSelectionCubit cubit;
  late MockUserRepository mockUserRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');

    cubit = InterfaceModeSelectionCubit(mockUserRepository, mockFirebaseAuth);
  });

  tearDown(() {
    cubit.close();
  });

  group('InterfaceModeSelectionCubit', () {
    test('Initial state is correct', () {
      expect(cubit.state.pageStatus, PageStatus.Uninitialized);
      expect(cubit.state.selectedMode, InterfaceMode.standard);
    });

    test('selectMode updates state', () {
      cubit.selectMode(InterfaceMode.simplified);
      expect(cubit.state.selectedMode, InterfaceMode.simplified);
    });

    test('successfully submits form and syncs user', () async {
      when(mockUserRepository.getUser('test-uid'))
          .thenAnswer((_) async => const UserEntity(uid: 'test-uid'));
      when(mockUserRepository.syncUser(any)).thenAnswer((_) async => {});

      cubit.selectMode(InterfaceMode.simplified);
      final result = await cubit.submitForm();

      expect(result, true);
      verify(mockUserRepository.getUser('test-uid')).called(1);
      verify(mockUserRepository.syncUser(argThat(
        isA<UserEntity>()
            .having((u) => u.uiPreference, 'uiPreference', 'simplified'),
      ),),).called(1);
    });

    test('handles error during submitForm', () async {
      when(mockUserRepository.getUser('test-uid'))
          .thenThrow(Exception('Sync error'));

      final result = await cubit.submitForm();

      expect(result, false);
      expect(cubit.state.pageStatus, PageStatus.Error);
    });

    group('InterfaceModeSelectionCubit - Stream', () {
      test('emits correct states in order during submitForm', () async {
        when(mockUserRepository.getUser('test-uid'))
            .thenAnswer((_) async => const UserEntity(uid: 'test-uid'));
        when(mockUserRepository.syncUser(any)).thenAnswer((_) async => {});

        expectLater(
          cubit.stream,
          emitsInOrder([
            isA<InterfaceModeSelectionState>()
                .having((s) => s.pageStatus, 'pageStatus', PageStatus.Loading),
            isA<InterfaceModeSelectionState>()
                .having((s) => s.pageStatus, 'pageStatus', PageStatus.Loaded),
          ]),
        );

        await cubit.submitForm();
      });
    });
  });
}
