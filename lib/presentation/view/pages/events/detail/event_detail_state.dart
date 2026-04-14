part of 'event_detail_cubit.dart';

@freezed
class EventDetailState with _$EventDetailState implements BaseCubitState {
  const factory EventDetailState({
    @Default(PageStatus.Loaded) PageStatus pageStatus,
    String? pageErrorMessage,
    required MedicalEvent event,
    @Default([]) List<UserEntity> participants,
  }) = _EventDetailState;

  const EventDetailState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage,
    );
  }
}
