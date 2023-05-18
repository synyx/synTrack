import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/ui/widget/time_entry_activity_selector.dart';
import 'package:syntrack/ui/widget/time_entry_booking_button.dart';
import 'package:syntrack/ui/widget/time_entry_delete_button.dart';
import 'package:syntrack/util/date_time_range_extension.dart';

class TimeEntryActions extends StatelessWidget {
  final TimeEntry entry;
  final Function(Object? error)? onBooked;
  final Function()? onTrack;
  final Function()? onDelete;
  final bool hideActivitySelector;

  const TimeEntryActions({
    Key? key,
    required this.entry,
    this.onBooked,
    this.onTrack,
    this.onDelete,
    this.hideActivitySelector = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (entry.activity != null && !hideActivitySelector)
          TimeEntryActivitySelector(
            entry: entry,
          ),
        if (entry.task != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TimeEntryBookingButton(
              entry: entry,
              onBooked: onBooked,
            ),
          ),
        IconButton.filled(
          icon: const Icon(
            Icons.play_arrow,
          ),
          onPressed: () {
            onTrack?.call();
            context.read<TimeTrackingCubit>().track(
                  updates: (b) => b
                    ..task = entry.task?.toBuilder()
                    ..activity = entry.activity?.toBuilder()
                    ..comment = entry.comment,
                );
          },
        ),
        if (entry.bookingId == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TimeEntryDeleteButton(
              entry: entry,
              onDelete: onDelete,
            ),
          ),
        PopupMenuButton(
          itemBuilder: (context) => <PopupMenuEntry>[
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy - next day'),
              ),
              onTap: () => context.read<TimeEntriesCubit>().copyToNextDay(entry),
            ),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy - previous day'),
              ),
              onTap: () => context.read<TimeEntriesCubit>().copyToPreviousDay(entry),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Copy - select date'),
              ),
              onTap: () {
                // This is needed because pop up calls navigator pop...
                // see: https://stackoverflow.com/a/69569276
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final timeEntriesCubit = context.read<TimeEntriesCubit>();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: entry.start,
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: entry.start.add(const Duration(days: 99999)),
                  );

                  debugPrint('selected date: $date');
                  if (date != null) {
                    debugPrint('date is utc: ${date.isUtc}');

                    timeEntriesCubit.copyTo(
                        entry,
                        (entry) => [
                              date
                                  .copyWith(
                                    hour: entry.start.toLocal().hour,
                                    minute: entry.start.toLocal().minute,
                                    second: entry.start.toLocal().second,
                                    millisecond: entry.start.toLocal().millisecond,
                                  )
                                  .toUtc()
                            ]);
                  }
                });
              },
            ),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text('Copy - date range'),
              ),
              onTap: () {
                // This is needed because pop up calls navigator pop...
                // see: https://stackoverflow.com/a/69569276
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final timeEntriesCubit = context.read<TimeEntriesCubit>();
                  final dateRange = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(start: entry.start, end: entry.end),
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: entry.start.add(const Duration(days: 99999)),
                  );

                  debugPrint('selected date range: $dateRange');

                  if (dateRange != null) {
                    timeEntriesCubit.copyTo(
                      entry,
                      (entry) => dateRange.getAllDays().map(
                            (e) => e
                                .copyWith(
                                  hour: entry.start.toLocal().hour,
                                  minute: entry.start.toLocal().minute,
                                  second: entry.start.toLocal().second,
                                  millisecond: entry.start.toLocal().millisecond,
                                )
                                .toUtc(),
                          ),
                    );
                  }
                });
              },
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              child: ListTile(
                textColor: Colors.red[700],
                leading: const Icon(Icons.delete_forever),
                title: const Text('Force delete entry'),
              ),
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final timeEntriesCubit = context.read<TimeEntriesCubit>();

                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Force delete: ${entry.comment}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      content: const Text('''This action deletes the time entry directly out of the database.
If the time entry is booked, the booking will remain.

Are you sure that you want to force delete this entry?'''),
                      actions: [
                        TextButton.icon(
                          icon: Icon(
                            Icons.delete_forever,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          label: Text(
                            'Yes, delete',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No, dont delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != null && confirm) {
                    onDelete?.call();
                    timeEntriesCubit.delete(entry.id);
                  }
                });
              },
            ),
          ],
        )
      ],
    );
  }
}
