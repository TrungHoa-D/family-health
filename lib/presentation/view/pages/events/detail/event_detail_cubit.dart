import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/save_medical_event_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'event_detail_cubit.freezed.dart';
part 'event_detail_state.dart';

@injectable
class EventDetailCubit extends BaseCubit<EventDetailState> {
  EventDetailCubit(
    this._saveMedicalEventUseCase,
    this._getUserUseCase,
    this._authRepository,
  ) : super(EventDetailState(
        event: MedicalEvent(
          id: '', familyId: '', title: '', eventType: 'OTHER', 
          startTime: DateTime.now(), endTime: DateTime.now(), location: '', status: 'UPCOMING'
        ),
      ));

  final SaveMedicalEventUseCase _saveMedicalEventUseCase;
  final GetUserUseCase _getUserUseCase;
  final AuthRepository _authRepository;

  Future<void> init(MedicalEvent event) async {
    final currentUser = _authRepository.getCurrentUser();
    emit(state.copyWith(
      event: event, 
      pageStatus: PageStatus.Loading,
      currentUserId: currentUser?.uid,
    ));
    
    try {
      final participants = <UserEntity>[];
      for (final id in event.participantIds) {
        final u = await _getUserUseCase.call(params: id);
        if (u != null) {
          participants.add(u);
        }
      }
      emit(state.copyWith(pageStatus: PageStatus.Loaded, participants: participants));
    } catch (e) {
      emit(state.copyWith(pageStatus: PageStatus.Loaded));
    }
  }

  Future<void> changeStatus(String newStatus) async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));
    try {
      final updatedEvent = state.event.copyWith(status: newStatus);
      await _saveMedicalEventUseCase.call(params: updatedEvent);
      emit(state.copyWith(pageStatus: PageStatus.Loaded, event: updatedEvent));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  /// Đánh dấu sự kiện là hoàn thành (finished = true)
  Future<void> markAsFinished() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));
    try {
      final updatedEvent = state.event.copyWith(finished: true);
      await _saveMedicalEventUseCase.call(params: updatedEvent);
      emit(state.copyWith(pageStatus: PageStatus.Loaded, event: updatedEvent));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  /// Mở lại sự kiện (finished = false)
  Future<void> markAsUnfinished() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));
    try {
      final updatedEvent = state.event.copyWith(finished: false, status: 'UPCOMING');
      await _saveMedicalEventUseCase.call(params: updatedEvent);
      emit(state.copyWith(pageStatus: PageStatus.Loaded, event: updatedEvent));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }
}
