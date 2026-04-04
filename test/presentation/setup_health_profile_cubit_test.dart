import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/check_auth_status_usecase.dart';
import 'package:family_health/domain/usecases/save_health_profile_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/view/pages/setup_health_profile/setup_health_profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([SaveHealthProfileUseCase, CheckAuthStatusUseCase])
import 'setup_health_profile_cubit_test.mocks.dart';

void main() {
  late SetupHealthProfileCubit cubit;
  late MockSaveHealthProfileUseCase mockSaveHealthProfileUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;

  setUp(() {
    mockSaveHealthProfileUseCase = MockSaveHealthProfileUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();

    cubit = SetupHealthProfileCubit(
      mockSaveHealthProfileUseCase,
      mockCheckAuthStatusUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('SetupHealthProfileCubit', () {
    test('Initial state is correct', () {
      expect(cubit.state.pageStatus, PageStatus.Uninitialized);
      expect(cubit.state.height, '');
    });

    test('successfully submits health profile', () async {
      when(mockCheckAuthStatusUseCase(params: anyNamed('params')))
          .thenAnswer((_) async => const UserEntity(uid: 'test-uid'));
      when(mockSaveHealthProfileUseCase(params: anyNamed('params')))
          .thenAnswer((_) async => {});

      cubit.updateHeight('175');
      cubit.updateWeight('70');
      cubit.selectBloodType('O');
      final result = await cubit.submitForm();

      expect(result, true);
      verify(mockSaveHealthProfileUseCase(
          params: argThat(
        isA<SaveHealthProfileParams>()
            .having((p) => p.profile.height, 'height', '175'),
        named: 'params',
      ),),).called(1);
    });

    test('Validation fails for invalid height/weight', () async {
      cubit.updateHeight('500'); // Invalid
      cubit.updateWeight('0'); // Invalid
      cubit.selectBloodType('O');
      final result = await cubit.submitForm();
      expect(result, false);
      expect(cubit.state.isFormValid, false);
    });
  });
}
