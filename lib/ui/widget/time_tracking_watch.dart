import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';
import 'package:syntrack/cubit/time_tracking_state.dart';

class TimeTrackingWatch extends StatefulWidget {
  const TimeTrackingWatch({Key? key}) : super(key: key);

  @override
  State<TimeTrackingWatch> createState() => _TimeTrackingWatchState();
}

class _TimeTrackingWatchState extends State<TimeTrackingWatch> {
  late final Timer _timer;
  Duration _currentDuration = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimeTrackingCubit>().stream.listen((event) {
        _handeTimeTrackingState(event);
      });
      _handeTimeTrackingState(context.read<TimeTrackingCubit>().state);

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_startTime != null) {
            _currentDuration = DateTime.now().difference(_startTime!);
          } else {
            _currentDuration = Duration.zero;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimeTrackingCubit>().state;

    return Container(
      width: 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(1000),
      ),
      padding: const EdgeInsets.all(8),
      child: IgnorePointer(
        ignoring: !state.isTracking,
        child: InkWell(
          onTap: () => _selectStartTime(context),
          child: Text(
            '$hours:$minutes:$seconds',
            style: TextStyle(
              fontSize: 25,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final state = context.read<TimeTrackingCubit>().state;

    if (state.isTracking) {
      final timeTrackingCubit = context.read<TimeTrackingCubit>();

      final newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(state.start!.toLocal()),
      );

      if (newTime != null) {
        timeTrackingCubit.setStartTime(newTime);
      }
    }
  }

  String get hours => '${_currentDuration.inHours}'.padLeft(2, '0');
  String get minutes => '${_currentDuration.inMinutes % 60}'.padLeft(2, '0');
  String get seconds => '${_currentDuration.inSeconds % 60}'.padLeft(2, '0');

  void _handeTimeTrackingState(TimeTrackingState state) {
    if (state.isTracking) {
      _startTime = state.start;
    } else {
      _startTime = null;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
