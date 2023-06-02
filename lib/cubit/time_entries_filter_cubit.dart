import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_entries_filter.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/util/date_time_extension.dart';

class TimeEntriesFilterCubit extends Cubit<TimeEntriesFilter> {
  TimeEntriesFilterCubit()
      : super((TimeEntriesFilterBuilder()
              ..filterActivityNames = {}
              ..filterWorkInterfaceId = {}
              ..filterWeekday = {})
            .build());

  Iterable<TimeEntry> filter(List<TimeEntry> timeEntries) {
    final TimeEntriesFilter(
      query: query,
      filterActivityNames: filterActivityNames,
      filterBooked: filterBooked,
      filterTask: filterTask,
      filterDuration: filterDuration,
      filterWeekday: filterWeekday,
      filterWorkInterfaceId: filterWorkInterfaceId,
      filterStart: filterStart,
      filterEnd: filterEnd,
    ) = state;

    if (query == null &&
        filterActivityNames.isEmpty &&
        filterBooked == null &&
        filterTask == null &&
        filterDuration == null &&
        filterWeekday.isEmpty &&
        filterWorkInterfaceId.isEmpty &&
        filterStart == null &&
        filterEnd == null) {
      return timeEntries;
    }

    return timeEntries
        .where(
          (element) => query != null
              ? [
                  element.comment.trim().isEmpty ? '<NO COMMENT>' : element.comment.trim(),
                  element.task?.name ?? '<NO TASK>',
                  element.activity?.name ?? '<NO ACTIVITY>',
                ].join('').toLowerCase().contains(query.trim().toLowerCase())
              : true,
        )
        .where(
          (element) => filterActivityNames.isNotEmpty ? filterActivityNames.contains(element.activity?.name) : true,
        )
        .where(
          (element) => filterBooked != null
              ? filterBooked
                  ? element.bookingId != null
                  : element.bookingId == null
              : true,
        )
        .where(
          (element) => filterTask != null ? element.task?.id == filterTask.id : true,
        )
        .where(
          (element) => filterWeekday.isNotEmpty ? filterWeekday.contains(element.start.weekday) : true,
        )
        .where(
          (element) =>
              filterWorkInterfaceId.isNotEmpty ? filterWorkInterfaceId.contains(element.task?.workInterfaceId) : true,
        )
        .where(
          (element) => filterStart != null ? element.start.startOfDay == filterStart.startOfDay : true,
        )
        .where(
          (element) => filterEnd != null ? element.end.startOfDay == filterEnd.startOfDay : true,
        )
        .where(
          (element) => filterDuration != null ? filterDuration.inSeconds <= element.duration.inSeconds : true,
        );
  }

  void debouncedFilters(Function(TimeEntriesFilterBuilder) updates) {
    EasyDebounce.debounce('time_entries_filter_cubit.debouncedFilters', const Duration(milliseconds: 500), () {
      setFilters(updates);
    });
  }

  void setFilters(Function(TimeEntriesFilterBuilder) updates) {
    emit(state.rebuild(updates));
  }

  void clearFilters() {
    emit(state.rebuild((p0) => p0
      ..filterActivityNames = const {}
      ..filterBooked = null
      ..filterTask = null
      ..filterDuration = null
      ..filterWeekday = const {}
      ..filterWorkInterfaceId = const {}
      ..filterStart = null
      ..filterEnd = null));
  }

  void debouncedQuery(String? query) {
    EasyDebounce.debounce(
      'time_entries_filter_cubit.debouncedQuery',
      const Duration(milliseconds: 750),
      () {
        immediateQuery(query);
      },
    );
  }

  void immediateQuery(String? query) {
    emit(state.rebuild((state) => state..query = query));
  }
}
