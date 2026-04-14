import 'dart:async';

import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/watch_medical_events_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/view/pages/events/list/event_list_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class EventListCubit extends BaseCubit<EventListState> {
  EventListCubit(
    this._watchMedicalEventsUseCase,
    this._getUserUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const EventListState());

  final WatchMedicalEventsUseCase _watchMedicalEventsUseCase;
  final GetUserUseCase _getUserUseCase;
  final FirebaseAuth _firebaseAuth;

  StreamSubscription? _eventsSubscription;

  void init() {
    _init();
  }

  Future<void> _init() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: 'User not logged in',
        ));
        return;
      }

      final userEntity = await _getUserUseCase.call(params: user.uid);
      final familyId = userEntity?.familyId;

      if (familyId == null) {
        emit(state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: 'Family not found',
        ));
        return;
      }

      await _eventsSubscription?.cancel();
      _eventsSubscription = _watchMedicalEventsUseCase(familyId).listen(
        (events) {
          emit(state.copyWith(
            pageStatus: PageStatus.Loaded,
            allEvents: events,
          ));
        },
        onError: (e) {
          emit(state.copyWith(
            pageStatus: PageStatus.Error,
            pageErrorMessage: e.toString(),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateDateRange(DateTimeRange? range) {
    emit(state.copyWith(dateRange: range));
  }

  void updateStatusFilter(String? status) {
    emit(state.copyWith(statusFilter: status));
  }

  void clearFilters() {
    emit(state.copyWith(
      searchQuery: '',
      dateRange: null,
      statusFilter: null,
    ));
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}
