library time_entry;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'time_entry.g.dart';

typedef BookingId = String;

abstract class TimeEntry implements Built<TimeEntry, TimeEntryBuilder> {
  String get id;
  Task? get task;
  DateTime get start;
  DateTime get end;
  Activity? get activity;
  BookingId? get bookingId;
  String get comment;

  TimeEntry._();

  factory TimeEntry([void Function(TimeEntryBuilder) updates]) = _$TimeEntry;

  Duration get duration => end.difference(start);

  String toJson() {
    return json.encode(serializers.serializeWith(TimeEntry.serializer, this));
  }

  static TimeEntry? fromJson(String jsonString) {
    return serializers.deserializeWith(TimeEntry.serializer, json.decode(jsonString));
  }

  static Serializer<TimeEntry> get serializer => _$timeEntrySerializer;
}
