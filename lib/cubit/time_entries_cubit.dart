import 'dart:convert';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:uuid/uuid.dart';

class TimeEntriesCubit extends HydratedCubit<List<TimeEntry>> {
  TimeEntriesCubit() : super([]);

  final uuid = const Uuid();

  void newTrackedTimeEntry({
    required Task? task,
    required Activity? activity,
    required String comment,
    required DateTime start,
    required DateTime end,
  }) {
    final timeEntry = TimeEntry(
      (b) => b
        ..id = uuid.v4()
        ..task = task?.toBuilder()
        ..activity = activity?.toBuilder()
        ..comment = comment
        ..start = start
        ..end = end,
    );

    store(timeEntry);
  }

  @override
  void emit(List<TimeEntry> state) {
    _sort();
    super.emit([...state]);
  }

  void store(TimeEntry timeEntry) {
    state.add(timeEntry);
    emit(state);
  }

  void delete(String id) {
    final newList = [...state];
    newList.removeWhere((element) => element.id == id);
    emit(newList);
  }

  void update(String id, TimeEntry newTimeEntry) {
    final index = state.indexWhere((entry) => entry.id == id);
    state.replaceRange(index, index + 1, [newTimeEntry]);
    emit(state);
  }

  void copyToNextDay(TimeEntry entry) {
    copyTo(
      entry,
      (entry) => [entry.start.add(const Duration(days: 1))],
    );
  }

  void copyToPreviousDay(TimeEntry entry) {
    copyTo(
      entry,
      (entry) => [entry.start.subtract(const Duration(days: 1))],
    );
  }

  void copyTo(TimeEntry entry, Iterable<DateTime> Function(TimeEntry entry) newDateTimes) {
    final newEntries = newDateTimes(entry).map((newStart) {
      final newEnd = newStart.add(entry.duration);

      return entry.rebuild(
        (entryBuilder) => entryBuilder
          ..start = newStart
          ..end = newEnd
          ..bookingId = null
          ..id = uuid.v4(),
      );
    });

    state.addAll(newEntries);
    emit(state);
  }

  void _sort() => _sortTimeEntryList(state);
  void _sortTimeEntryList(List<TimeEntry> entries) => entries.sort((a, b) => b.start.compareTo(a.start));

  @override
  List<TimeEntry>? fromJson(Map<String, dynamic> json) {
    final timeEntries = json['timeEntries'] as List<dynamic>;

    final list = timeEntries.map((e) => TimeEntry.fromJson(jsonEncode(e))!).toList();
    _sortTimeEntryList(list);
    return list;
  }

  @override
  Map<String, dynamic>? toJson(List<TimeEntry> state) {
    return {'timeEntries': state.map((e) => jsonDecode(e.toJson())).toList()};
  }
}
