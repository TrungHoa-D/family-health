import 'package:bloc_test/bloc_test.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/save_medication_usecase.dart';
import 'package:family_health/domain/usecases/save_schedule_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/view/pages/meds/add_medication/add_medication_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  SaveMedicationUseCase,
  SaveScheduleUseCase,
  GetUserUseCase,
  FirebaseAuth,
  User,
])
import 'add_medication_cubit_test.mocks.dart';

void main() {
  late AddMedicationCubit cubit;
  late MockSaveMedicationUseCase mockSaveMedicationUseCase;
  late MockSaveScheduleUseCase mockSaveScheduleUseCase;
  late MockGetUserUseCase mockGetUserUseCase;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockSaveMedicationUseCase = MockSaveMedicationUseCase();
    mockSaveScheduleUseCase = MockSaveScheduleUseCase();
    mockGetUserUseCase = MockGetUserUseCase();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');

    cubit = AddMedicationCubit(
      mockSaveMedicationUseCase,
      mockSaveScheduleUseCase,
      mockGetUserUseCase,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  group('AddMedicationCubit', () {
    blocTest<AddMedicationCubit, AddMedicationState>(
      'successfully saves medication and schedule',
      build: () {
        when(mockGetUserUseCase.call(params: anyNamed('params')))
            .thenAnswer((_) async => const UserEntity(uid: 'test-uid', familyId: 'family-123'));
        when(mockSaveMedicationUseCase.call(params: anyNamed('params')))
            .thenAnswer((_) async => {});
        when(mockSaveScheduleUseCase.call(params: anyNamed('params')))
            .thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) async {
        cubit.updateDrugName('Aspirin');
        cubit.updateDosage('1 pill');
        await cubit.save();
      },
      expect: () => [
        isA<AddMedicationState>().having((p0) => p0.drugName, 'name', 'Aspirin'),
        isA<AddMedicationState>().having((p0) => p0.dosage, 'dosage', '1 pill'),
        isA<AddMedicationState>().having((p0) => p0.pageStatus, 'status', PageStatus.Loading),
        isA<AddMedicationState>()
            .having((p0) => p0.pageStatus, 'status', PageStatus.Loaded)
            .having((p0) => p0.isSaved, 'saved', true),
      ],
      verify: (_) {
        verify(mockSaveMedicationUseCase.call(params: anyNamed('params'))).called(1);
        verify(mockSaveScheduleUseCase.call(params: anyNamed('params'))).called(1);
      },
    );

    blocTest<AddMedicationCubit, AddMedicationState>(
      'fails validation if drug name is empty',
      build: () => cubit,
      act: (cubit) async {
        cubit.updateDrugName('');
        cubit.updateDosage('1 pill');
        await cubit.save();
      },
      expect: () => [
        isA<AddMedicationState>().having((p0) => p0.drugName, 'name', ''),
        isA<AddMedicationState>().having((p0) => p0.dosage, 'dosage', '1 pill'),
        isA<AddMedicationState>().having((p0) => p0.drugNameError, 'error', isNotNull),
      ],
      verify: (cubit) {
        expect(cubit.state.isSaved, false);
        verifyNever(mockSaveMedicationUseCase.call(params: anyNamed('params')));
      },
    );
  });
}
