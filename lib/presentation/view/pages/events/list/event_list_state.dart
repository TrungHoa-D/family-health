import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_list_state.freezed.dart';

@freezed
class EventListState with _$EventListState implements BaseCubitState {
  const factory EventListState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default('') String searchQuery,
    DateTimeRange? dateRange,
    String? statusFilter, // UPCOMING, COMPLETED, CANCELLED or null for ALL
    @Default([]) List<MedicalEvent> allEvents,
  }) = _EventListState;

  const EventListState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage ?? this.pageErrorMessage,
    );
  }

  List<MedicalEvent> get filteredEvents {
    var filtered = List<MedicalEvent>.from(allEvents);

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.location.toLowerCase().contains(query) ||
            (e.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter by date range
    if (dateRange != null) {
      filtered = filtered.where((e) {
        return e.startTime.isAfter(dateRange!.start) &&
            e.startTime.isBefore(dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by status
    if (statusFilter != null) {
      filtered = filtered.where((e) => e.status == statusFilter).toList();
    }

    // Sort by time descending (newest first)
    filtered.sort((a, b) => b.startTime.compareTo(a.startTime));

    return filtered;
  }
}
