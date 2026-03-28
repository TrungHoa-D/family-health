import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/sign_out_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/utils/logger.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit(this._authRepository, this._signOutUseCase)
      : super(const HomeState());

  final AuthRepository _authRepository;
  final SignOutUseCase _signOutUseCase;

  Future<void> loadData() async {
    final UserEntity? currentUser = _authRepository.getCurrentUser();
    emit(state.copyWith(
      pageStatus: PageStatus.Loaded,
      user: currentUser,
    ));
  }

  Future<void> signOut() async {
    try {
      showLoading();
      await _signOutUseCase.call(params: null);
      hideLoading();
    } catch (e) {
      hideLoading();
      logger.e('Sign out failed: $e');
    }
  }
}
