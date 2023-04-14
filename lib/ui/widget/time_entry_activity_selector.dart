import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/ui/widget/activity_selector.dart';

class TimeEntryActivitySelector extends StatelessWidget {
  final TimeEntry entry;

  const TimeEntryActivitySelector({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entry.bookingId != null) return Container();

    return ActivitySelector(
      selectedActivity: entry.activity!,
      activities: entry.task!.availableActivities.toList(),
      onSelect: (activity) => context.read<TimeEntriesCubit>().update(
            entry.id,
            entry.rebuild((b) => b..activity = activity!.toBuilder()),
          ),
    );
  }
}
