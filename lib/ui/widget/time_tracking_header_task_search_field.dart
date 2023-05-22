import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';
import 'package:syntrack/ui/widget/task_search_field.dart';

class TaskTrackingHeaderTaskSearchField extends StatelessWidget {
  const TaskTrackingHeaderTaskSearchField({
    Key? key,
    this.onSearchDone,
  }) : super(key: key);

  final Function()? onSearchDone;

  @override
  Widget build(BuildContext context) {
    return TaskSearchTextField(
      autofocus: false,
      onSuggestionSelected: (suggestion) {
        final task = suggestion.task;
        final activity = suggestion.activity ?? task.availableActivities[0];
        final suggestionComment = suggestion.comment;

        final cubit = context.read<TimeTrackingCubit>();
        cubit.track(
          updates: (b) {
            b.comment = suggestionComment ?? b.comment;
            b.activity = activity.toBuilder();
            b.task = task.toBuilder();
          },
          setTimeToNow: !cubit.state.isTracking,
          stopCurrent: !cubit.state.isTracking,
        );

        onSearchDone?.call();
      },
      onAbort: onSearchDone,
      onTextChange: (search) {
        final cubit = context.read<TimeTrackingCubit>();

        if (!cubit.state.isTracking && search.trim().isNotEmpty) {
          cubit.setComment(search.trim());
        }
      },
      onSubmitted: (comment) {
        final cubit = context.read<TimeTrackingCubit>();

        if (!cubit.state.isTracking) {
          cubit.track(
            updates: (b) => b..comment = comment,
          );
        }
      },
    );
  }
}
