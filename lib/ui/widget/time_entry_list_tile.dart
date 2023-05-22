import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:syntrack/cubit/booking_cubit.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/ui/widget/date_selector.dart';
import 'package:syntrack/ui/widget/error_display.dart';
import 'package:syntrack/ui/widget/time_entry_actions.dart';
import 'package:syntrack/ui/widget/time_entry_comment_edit_field.dart';
import 'package:syntrack/ui/widget/time_entry_editor.dart';
import 'package:syntrack/ui/widget/time_selector.dart';
import 'package:syntrack/util/date_time_extension.dart';

class TimeEntryListTile extends StatefulWidget {
  final TimeEntry entry;

  const TimeEntryListTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  State<TimeEntryListTile> createState() => _TimeEntryListTileState();
}

class _TimeEntryListTileState extends State<TimeEntryListTile> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final listTile = _buildTile(context);

    if (_isBooking(context)) {
      return IgnorePointer(
        ignoring: true,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          child: listTile,
        ),
      );
    }

    return listTile;
  }

  Widget _buildTile(BuildContext context) {
    final entry = widget.entry;

    return InkWell(
      onTap: () => _showDetails(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 150),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateSelector(
                      entry: entry,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      readOnly: SizerUtil.deviceType == DeviceType.mobile,
                    ),
                    Text(
                        '${(entry.end.difference(entry.start).inMinutes / 60).toStringAsFixed(2)}h ${entry.activity?.name ?? '<NO ACTIVITY>'}'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimeEntryCommentEditField(
                    entry: entry,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(entry.task != null ? '#${entry.task!.id} ${entry.task!.name}' : '<NO TASK>'),
                  TimeSelector(
                    entry: entry,
                    readOnly: SizerUtil.deviceType == DeviceType.mobile,
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              ErrorDisplay(
                errorMessage: _errorMessage,
                dense: true,
              ),
            if (SizerUtil.deviceType != DeviceType.mobile)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TimeEntryActions(
                  entry: entry,
                  onBooked: (e) {
                    setState(() {
                      _errorMessage = e?.toString();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => BlocBuilder<TimeEntriesCubit, List<TimeEntry>>(
        builder: (context, state) {
          try {
            final entry = state.firstWhere((element) => element.id == widget.entry.id);
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: TimeEntryEditor(entry: entry),
            );
          } catch (e) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  Text(
                    e.toString(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  bool _isBooking(BuildContext context) => context.watch<BookingCubit>().isBooking(widget.entry);
}
