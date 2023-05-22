import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:isoweek/isoweek.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:syntrack/cubit/booking_cubit.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/ui/widget/time_entry_list_tile.dart';
import 'package:syntrack/util/date_time_extension.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');

class TimeEntriesList extends StatelessWidget {
  const TimeEntriesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allEntries = context.watch<TimeEntriesCubit>().state;

    final entriesByWeek = groupBy(allEntries, (entry) => Week.fromDate(entry.start.startOfDay));

    return CustomScrollView(
      slivers: entriesByWeek.entries.map((mapEntry) {
        final week = mapEntry.key;

        final weekStartFormatted = _dateFormat.format(week.days.first);
        final weekEndFormatted = _dateFormat.format(week.days.last);

        final entries = mapEntry.value;
        final totalHours = entries.map((e) => e.duration.inMinutes / 60).sum.toStringAsFixed(2);

        final anyNotBooked =
            entries.firstWhereOrNull((element) => element.task != null && element.bookingId == null) != null;

        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 30,
              title: DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$weekStartFormatted - $weekEndFormatted',
                    ),
                    Text(
                      'W${week.weekNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalHours}h',
                    ),
                  ],
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              automaticallyImplyLeading: false,
              actions: [
                if (!anyNotBooked)
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: IconButton.outlined(
                      onPressed: null,
                      icon: Icon(Icons.bookmark_added),
                      iconSize: 12,
                    ),
                  ),
                if (anyNotBooked)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton.outlined(
                      tooltip: 'Book Week #${week.weekNumber}',
                      onPressed: () {
                        context.read<BookingCubit>().bookMany(context, entries);
                      },
                      icon: const Icon(Icons.bookmark),
                      iconSize: 12,
                    ),
                  ),
              ],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = entries[index];
                  return TimeEntryListTile(
                    key: Key('TimeEntryListTile-${entry.id}'),
                    entry: entry,
                  );
                },
                childCount: entries.length,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
