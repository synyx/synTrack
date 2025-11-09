import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/cubit/work_interface_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/ui/widget/work_interface_icon.dart';

class TimeEntryCommentEditField extends StatelessWidget {
  final TimeEntry entry;
  final TextStyle? style;
  final bool readOnly;

  const TimeEntryCommentEditField({
    Key? key,
    required this.entry,
    this.readOnly = true,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entry.bookingId != null || readOnly) {
      return Row(
        children: [
          if (entry.task != null)
            Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.only(right: 4),
              child: WorkInterfaceIcon(
                origin: context.read<WorkInterfaceCubit>().getOriginFor(entry.task!.workInterfaceId),
              ),
            ),
          if (Device.screenType == ScreenType.mobile)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                entry.bookingId == null ? Icons.bookmark : Icons.bookmark_added,
              ),
            ),
          Expanded(
            child: Tooltip(
              waitDuration: const Duration(seconds: 1),
              message: _getCommentDisplayText(entry.comment),
              child: Text(
                _getCommentDisplayText(entry.comment),
                style: style,
                overflow: TextOverflow.ellipsis,
                textAlign: entry.bookingId == null || readOnly ? null : TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return TextFormField(
      key: ValueKey(entry.id),
      initialValue: entry.comment,
      decoration: const InputDecoration(
        hintText: 'Comment',
      ),
      style: style,
      onChanged: (value) {
        context.read<TimeEntriesCubit>().update(
              entry.id,
              entry.rebuild((b) => b..comment = value),
            );
      },
    );
  }

  String _getCommentDisplayText(String comment) => comment.isEmpty ? '<NO COMMENT>' : comment;
}
