import 'dart:async';

import 'package:family_health/domain/usecases/watch_auth_status_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'global_auth_cubit.freezed.dart';
part 'global_auth_state.dart';

@lazySingleton
class GlobalAuthCubit extends BaseCubit<GlobalAuthState> {
  GlobalAuthCubit(this._watchAuthStatusUseCase) : super(const GlobalAuthState());

  final WatchAuthStatusUseCase _watchAuthStatusUseCase;
  StreamSubscription? _authSubscription;
  bool _wasLoggedIn = false;

  void init() {
    _authSubscription?.cancel();
    _authSubscription = _watchAuthStatusUseCase.call(null).listen((user) {
      if (_wasLoggedIn && user == null) {
        emit(state.copyWith(sessionStatus: SessionStatus.expired));
      } else if (user != null) {
        emit(state.copyWith(sessionStatus: SessionStatus.authenticated));
      } else {
        emit(state.copyWith(sessionStatus: SessionStatus.unauthenticated));
      }
      _wasLoggedIn = user != null;
    });
  }

  void acknowledgeLogout() {
    emit(state.copyWith(sessionStatus: SessionStatus.loggedOut));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
