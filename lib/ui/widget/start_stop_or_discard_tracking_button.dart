import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';

class StartStopOrDiscardTrackingButton extends StatelessWidget {
  const StartStopOrDiscardTrackingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTracking = context.watch<TimeTrackingCubit>().state.isTracking;

    return Row(
      children: [
        if (!isTracking)
          ElevatedButton(
            onPressed: () => context.read<TimeTrackingCubit>().track(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.play_arrow),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),
          ),
        if (isTracking)
          ElevatedButton(
            onPressed: () => context.read<TimeTrackingCubit>().stop(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.stop),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: isTracking ? () => context.read<TimeTrackingCubit>().discard() : null,
            child: Icon(Icons.delete),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
