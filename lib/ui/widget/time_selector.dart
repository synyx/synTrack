import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';

class TimeSelector extends StatelessWidget {
  final TimeEntry entry;
  final bool readOnly;
  final TextStyle? style;

  const TimeSelector({
    Key? key,
    required this.entry,
    this.readOnly = true,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        alwaysUse24HourFormat: true,
      ),
      child: _TimeSelector(
        entry: entry,
        readOnly: readOnly,
        style: style,
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  static final _formatterTime = DateFormat('HH:mm');

  const _TimeSelector({
    Key? key,
    required this.entry,
    required this.readOnly,
    required this.style,
  }) : super(key: key);

  final TimeEntry entry;
  final bool readOnly;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: entry.bookingId != null || readOnly
              ? null
              : () async {
                  final start = entry.start.toLocal();
                  final end = entry.end.toLocal();

                  final newStartTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(start),
                  );

                  if (newStartTime != null) {
                    final newStart =
                        DateTime(start.year, start.month, start.day, newStartTime.hour, newStartTime.minute).toUtc();

                    if (newStart.isAfter(end)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Invalid start time'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      throw Exception('invalid time: start after end');
                    }

                    context.read<TimeEntriesCubit>().update(
                          entry.id,
                          entry.rebuild(
                            (b) => b..start = newStart,
                          ),
                        );
                  }
                },
          child: Text(
            _formatterTime.format(entry.start.toLocal()),
            style: style,
          ),
        ),
        Text(
          ' - ',
          style: style,
        ),
        InkWell(
          onTap: entry.bookingId != null || readOnly
              ? null
              : () async {
                  final start = entry.start.toLocal();
                  final end = entry.end.toLocal();

                  final newEndTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(end),
                  );

                  if (newEndTime != null) {
                    final newEnd = DateTime(end.year, end.month, end.day, newEndTime.hour, newEndTime.minute).toUtc();

                    if (start.isAfter(newEnd)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Invalid end time'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                      throw Exception('invalid time: start after end');
                    }

                    context.read<TimeEntriesCubit>().update(
                          entry.id,
                          entry.rebuild(
                            (b) => b..end = newEnd,
                          ),
                        );
                  }
                },
          child: Text(
            _formatterTime.format(entry.end.toLocal()),
            style: style,
          ),
        ),
      ],
    );
  }
}
