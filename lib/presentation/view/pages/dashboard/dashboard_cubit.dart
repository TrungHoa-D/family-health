import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'dashboard_cubit.freezed.dart';
part 'dashboard_state.dart';

@injectable
class DashboardCubit extends BaseCubit<DashboardState> {
  DashboardCubit(this._authRepository) : super(const DashboardState());
  final AuthRepository _authRepository;

  Future<void> loadData() async {
    final user = _authRepository.getCurrentUser();
    emit(
      state.copyWith(
        pageStatus: PageStatus.Loaded,
        user: user,
      ),
    );
  }
}
