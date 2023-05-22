import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';
import 'package:syntrack/ui/widget/activity_selector.dart';
import 'package:syntrack/ui/widget/comment_edit_field.dart';
import 'package:syntrack/ui/widget/start_stop_or_discard_tracking_button.dart';
import 'package:syntrack/ui/widget/time_tracking_header_task_search_field.dart';
import 'package:syntrack/ui/widget/time_tracking_watch.dart';

class TimeTrackingHeader extends StatefulWidget {
  const TimeTrackingHeader({Key? key}) : super(key: key);

  @override
  State<TimeTrackingHeader> createState() => _TimeTrackingHeaderState();
}

class _TimeTrackingHeaderState extends State<TimeTrackingHeader> {
  bool _searchingTask = false;

  @override
  Widget build(BuildContext context) {
    final trackingState = context.watch<TimeTrackingCubit>().state;

    final padding = SizerUtil.deviceType == DeviceType.mobile ? 4.0 : 8.0;
    final spacing = SizerUtil.deviceType == DeviceType.mobile ? 8.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            if (trackingState.isTracking)
              Container(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    if (trackingState.task == null && trackingState.isTracking)
                      Padding(
                        padding: EdgeInsets.only(right: padding),
                        child: FilledButton.tonalIcon(
                          onPressed: () => setState(() {
                            _searchingTask = !_searchingTask;
                          }),
                          icon: Icon(_searchingTask ? Icons.close : Icons.search),
                          label: Text(_searchingTask ? 'Cancel search' : 'Search Task'),
                        ),
                      ),
                    if (trackingState.task != null)
                      Chip(
                        label: Text('Task: ${trackingState.task?.name}'),
                        onDeleted: () => context.read<TimeTrackingCubit>().removeTask(),
                      ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: trackingState.isTracking && !_searchingTask
                      ? const CommentEditField()
                      : TaskTrackingHeaderTaskSearchField(
                          onSearchDone: () {
                            setState(() {
                              _searchingTask = false;
                            });
                          },
                        ),
                ),
                if (trackingState.isTracking) ...[
                  SizedBox(width: spacing),
                  if (trackingState.isTracking &&
                      trackingState.task != null &&
                      SizerUtil.deviceType != DeviceType.mobile) ...[
                    ActivitySelector(
                      selectedActivity: trackingState.activity,
                      activities: trackingState.task!.availableActivities.toList(),
                      onSelect: context.read<TimeTrackingCubit>().setActivity,
                    ),
                    SizedBox(width: spacing),
                  ],
                  Container(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: const Center(
                      child: TimeTrackingWatch(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (SizerUtil.deviceType != DeviceType.mobile) const StartStopOrDiscardTrackingButton(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
