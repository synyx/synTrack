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
          TimeEntryBookingButton(
            entry: entry,
            onBooked: onBooked,
          ),
        TextButton(
          child: Icon(Icons.play_arrow),
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
          TimeEntryDeleteButton(
            entry: entry,
            onDelete: onDelete,
          ),
        PopupMenuButton(
          itemBuilder: (context) => <PopupMenuEntry>[
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy - next day'),
              ),
              onTap: () => context.read<TimeEntriesCubit>().copyToNextDay(entry),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy - previous day'),
              ),
              onTap: () => context.read<TimeEntriesCubit>().copyToPreviousDay(entry),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Copy - select date'),
              ),
              onTap: () {
                // This is needed because pop up calls navigator pop...
                // see: https://stackoverflow.com/a/69569276
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: entry.start,
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: entry.start.add(Duration(days: 99999)),
                  );

                  debugPrint('selected date: $date');
                  if (date != null) {
                    debugPrint('date is utc: ${date.isUtc}');

                    context.read<TimeEntriesCubit>().copyTo(
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
              child: ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text('Copy - date range'),
              ),
              onTap: () {
                // This is needed because pop up calls navigator pop...
                // see: https://stackoverflow.com/a/69569276
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(start: entry.start, end: entry.end),
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: entry.start.add(Duration(days: 99999)),
                  );

                  debugPrint('selected date range: $dateRange');

                  if (dateRange != null) {
                    context.read<TimeEntriesCubit>().copyTo(
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
            PopupMenuDivider(),
            PopupMenuItem(
              child: ListTile(
                textColor: Colors.red[700],
                leading: Icon(Icons.delete_forever),
                title: Text('Force delete entry'),
              ),
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Force delete: ${entry.comment}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      content: Text('''This action deletes the time entry directly out of the database.
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
                          child: Text('No, dont delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != null && confirm) {
                    onDelete?.call();
                    context.read<TimeEntriesCubit>().delete(entry.id);
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
