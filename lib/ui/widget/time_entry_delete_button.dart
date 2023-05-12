import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';

class TimeEntryDeleteButton extends StatelessWidget {
  final TimeEntry entry;
  final Function()? onDelete;

  const TimeEntryDeleteButton({
    Key? key,
    required this.entry,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entry.bookingId != null) {
      throw Exception('invalid TimeEntry');
    }

    return TextButton(
      child: const Icon(
        Icons.delete,
        color: Colors.grey,
      ),
      onPressed: () {
        onDelete?.call();
        context.read<TimeEntriesCubit>().delete(entry.id);
      },
    );
  }
}
