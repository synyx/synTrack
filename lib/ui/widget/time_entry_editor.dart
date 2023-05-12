import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/ui/widget/date_selector.dart';
import 'package:syntrack/ui/widget/error_display.dart';
import 'package:syntrack/ui/widget/task_search_field.dart';
import 'package:syntrack/ui/widget/time_entry_actions.dart';
import 'package:syntrack/ui/widget/time_entry_activity_selector.dart';
import 'package:syntrack/ui/widget/time_entry_comment_edit_field.dart';
import 'package:syntrack/ui/widget/time_selector.dart';

class TimeEntryEditor extends StatefulWidget {
  final TimeEntry entry;

  const TimeEntryEditor({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  State<TimeEntryEditor> createState() => _TimeEntryEditorState();
}

class _TimeEntryEditorState extends State<TimeEntryEditor> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.entry.task?.name ?? '<NO TASK>',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.entry.task != null && widget.entry.bookingId == null) ...[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _deleteTask(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('DELETE TASK'),
                ),
              ],
              if (widget.entry.task == null) ...[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _showTaskSearchField(context),
                  icon: const Icon(Icons.search),
                  label: const Text('SEARCH TASK'),
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: TimeEntryCommentEditField(
                entry: widget.entry,
                readOnly: false,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Date:'),
          DateSelector(
            entry: widget.entry,
            readOnly: false,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          const Text('Time:'),
          TimeSelector(
            entry: widget.entry,
            readOnly: false,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          if (widget.entry.bookingId == null && widget.entry.task?.availableActivities != null) ...[
            const Text('Activity:'),
            TimeEntryActivitySelector(entry: widget.entry),
            const SizedBox(height: 16),
          ],
          if (widget.entry.bookingId != null) ...[
            const Text('Activity:'),
            Text(widget.entry.activity?.name ?? ''),
            const SizedBox(height: 16),
          ],
          const Text('Actions:'),
          TimeEntryActions(
            entry: widget.entry,
            hideActivitySelector: true,
            onBooked: (e) {
              setState(() {
                _errorMessage = e?.toString();
              });
            },
            onTrack: () => context.router.pop(),
            onDelete: () => context.router.pop(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            ErrorDisplay(
              errorMessage: _errorMessage,
            ),
          ]
        ],
      ),
    );
  }

  Future<void> _showTaskSearchField(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Task'),
          content: ConstrainedBox(
            constraints: const BoxConstraints.expand(
              width: 1000,
              height: 120,
            ),
            child: TaskSearchTextField(
              autofocus: true,
              onSuggestionSelected: (suggestion) {
                context.read<TimeEntriesCubit>().update(
                      widget.entry.id,
                      widget.entry.rebuild(
                        (b) => b
                          ..task = suggestion.task.toBuilder()
                          ..activity = suggestion.task.availableActivities[0].toBuilder(),
                      ),
                    );

                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  void _deleteTask(BuildContext context) {
    context.read<TimeEntriesCubit>().update(
          widget.entry.id,
          widget.entry.rebuild(
            (b) => b
              ..task = null
              ..activity = null,
          ),
        );
  }
}
