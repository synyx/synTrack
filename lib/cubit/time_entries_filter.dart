library time_entries_filter;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/common/task.dart';

part 'time_entries_filter.g.dart';

abstract class TimeEntriesFilter implements Built<TimeEntriesFilter, TimeEntriesFilterBuilder> {
  String? get query;
  DateTime? get filterStart;
  DateTime? get filterEnd;
  Duration? get filterDuration;
  bool? get filterBooked;
  int? get filterWeekday;
  Task? get filterTask;
  List<String?> get filterWorkInterfaceId;
  List<String?> get filterActivityNames;

  TimeEntriesFilter._();

  factory TimeEntriesFilter([void Function(TimeEntriesFilterBuilder) updates]) = _$TimeEntriesFilter;
}
