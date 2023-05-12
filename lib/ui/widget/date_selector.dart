import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';

class DateSelector extends StatelessWidget {
  static final _formatterDate = DateFormat('EEE dd.MM.yyyy');

  final TimeEntry entry;
  final bool readOnly;
  final TextStyle? style;

  const DateSelector({
    Key? key,
    required this.entry,
    this.readOnly = true,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: entry.bookingId != null || readOnly
          ? null
          : () async {
              final timeEntriesCubit = context.read<TimeEntriesCubit>();
              final start = entry.start.toLocal();
              final end = entry.end.toLocal();

              final newDate = await showDatePicker(
                context: context,
                initialDate: start,
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now().add(
                  const Duration(days: 365),
                ),
              );

              if (newDate != null) {
                final newStart = DateTime(newDate.year, newDate.month, newDate.day, start.hour, start.minute).toUtc();
                final newEnd = DateTime(newDate.year, newDate.month, newDate.day, end.hour, end.minute).toUtc();

                timeEntriesCubit.update(
                  entry.id,
                  entry.rebuild((b) => b
                    ..start = newStart
                    ..end = newEnd),
                );
              }
            },
      child: Text(
        _formatterDate.format(entry.start.toLocal()),
        style: style,
      ),
    );
  }
}
