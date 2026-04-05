import 'package:bloc_test/bloc_test.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/watch_medications_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  WatchMedicationsUseCase,
  GetUserUseCase,
  FirebaseAuth,
  User,
])
import 'meds_cubit_test.mocks.dart';

void main() {
  late MedsCubit cubit;
  late MockWatchMedicationsUseCase mockWatchMedicationsUseCase;
  late MockGetUserUseCase mockGetUserUseCase;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockWatchMedicationsUseCase = MockWatchMedicationsUseCase();
    mockGetUserUseCase = MockGetUserUseCase();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');

    cubit = MedsCubit(
      mockWatchMedicationsUseCase,
      mockGetUserUseCase,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  group('MedsCubit', () {
    final meds = [
      Medication(
        id: '1',
        name: 'Aspirin',
        dosageStandard: '1 pill',
        familyId: 'family456',
        categories: ['BỔ SUNG'],
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<MedsCubit, MedsState>(
      'successfully loads and maps medications',
      build: () {
        when(mockGetUserUseCase.call(params: anyNamed('params')))
            .thenAnswer((_) async => const UserEntity(uid: 'test-uid', familyId: 'family456'));
        when(mockWatchMedicationsUseCase.call('family456'))
            .thenAnswer((_) => Stream.value(meds));
        return cubit;
      },
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<MedsState>().having((s) => s.pageStatus, 'status', PageStatus.Loading),
        isA<MedsState>().having((s) => s.pageStatus, 'status', PageStatus.Loaded),
      ],
      verify: (cubit) {
        expect(cubit.state.medications.length, 1);
        final model = cubit.state.medications.first;
        expect(model.name, 'Aspirin');
        expect(model.tag, 'BỔ SUNG');
        expect(model.textColor.toARGB32(), 0xFF00796B);
      },
    );

    blocTest<MedsCubit, MedsState>(
      'handles error in medication stream',
      build: () {
        when(mockGetUserUseCase.call(params: anyNamed('params')))
            .thenAnswer((_) async => const UserEntity(uid: 'test-uid', familyId: 'family456'));
        when(mockWatchMedicationsUseCase.call('family456'))
            .thenAnswer((_) => Stream.error('Error loading meds'));
        return cubit;
      },
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<MedsState>().having((s) => s.pageStatus, 'status', PageStatus.Loading),
        isA<MedsState>()
            .having((s) => s.pageStatus, 'status', PageStatus.Error)
            .having((s) => s.pageErrorMessage, 'error', 'Error loading meds'),
      ],
    );
  });
}
