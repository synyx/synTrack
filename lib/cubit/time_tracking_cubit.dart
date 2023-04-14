import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/cubit/time_tracking_state.dart';
import 'package:syntrack/model/common/activity.dart';

class TimeTrackingCubit extends HydratedCubit<TimeTrackingState> {
  final TimeEntriesCubit timeEntriesCubit;

  TimeTrackingCubit(this.timeEntriesCubit) : super(TimeTrackingState.idle());

  void removeTask() {
    emit(state.rebuild(
      (b) => b
        ..activity = null
        ..task = null,
    ));
  }

  void setComment(String comment) {
    emit(state.rebuild((b) => b..comment = comment.trim()));
  }

  void setActivity(Activity? activity) {
    final state = this.state;
    emit(
      state.rebuild((b) => b..activity = activity?.toBuilder()),
    );
  }

  void setStartTime(TimeOfDay time) {
    final start = _getStartFrom(state);
    final newStart = DateTime(start.year, start.month, start.day, time.hour, time.minute).toUtc();

    if (DateTime.now().isBefore(newStart)) {
      throw Exception('new start time is in the future');
    }

    emit(
      state.rebuild((b) => b..start = newStart),
    );
  }

  void track({
    Function(TimeTrackingStateBuilder)? updates,
    bool stopCurrent = true,
    bool setTimeToNow = true,
  }) {
    if (state.isTracking && stopCurrent) {
      stop();
    }

    var newTimeTrackingState = updates != null ? state.rebuild(updates) : state;
    if (setTimeToNow) {
      newTimeTrackingState = newTimeTrackingState.rebuild(
        (b) => b..start = DateTime.now().toUtc(),
      );
    }

    emit(newTimeTrackingState);
  }

  void stop() {
    final now = DateTime.now();

    timeEntriesCubit.newTrackedTimeEntry(
      task: state.task,
      activity: state.activity,
      comment: state.comment,
      start: _getStartFrom(state),
      end: DateTime(now.year, now.month, now.day, now.hour, now.minute).toUtc(),
    );
    emit(TimeTrackingState.idle());
  }

  DateTime _getStartFrom(TimeTrackingState state) {
    final stateStart = state.start; // this way we get nullsafety features below the if statement
    if (stateStart == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, now.hour, now.minute).toUtc();
    }

    return DateTime.utc(stateStart.year, stateStart.month, stateStart.day, stateStart.hour, stateStart.minute);
  }

  void discard() {
    emit(TimeTrackingState.idle());
  }

  @override
  TimeTrackingState? fromJson(Map<String, dynamic> json) {
    try {
      return TimeTrackingState.fromJson(jsonEncode(json));
    } catch (e) {
      print(e);
      return TimeTrackingState.idle();
    }
  }

  @override
  Map<String, dynamic>? toJson(TimeTrackingState state) {
    if (state is TimeTrackingState) {
      return jsonDecode(state.toJson());
    }
    return <String, dynamic>{};
  }
}
