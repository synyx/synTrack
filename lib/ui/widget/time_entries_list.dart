import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/ui/widget/time_entry_list_tile.dart';

class TimeEntriesList extends StatelessWidget {
  const TimeEntriesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<TimeEntriesCubit>().state;

    return ListView.separated(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 8.0,
        right: 8.0,
      ),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == entries.length) {
          return const SizedBox(height: 100);
        }

        final entry = entries[index];
        return TimeEntryListTile(
          key: Key('TimeEntryListTile-${entry.id}'),
          entry: entry,
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }
}
