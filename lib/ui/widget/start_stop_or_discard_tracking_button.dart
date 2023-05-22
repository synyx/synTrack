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
          FilledButton.tonal(
            onPressed: () => context.read<TimeTrackingCubit>().track(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.play_arrow,
              ),
            ),
          ),
        if (isTracking)
          FilledButton.tonal(
            onPressed: () => context.read<TimeTrackingCubit>().stop(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.stop,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            color: Theme.of(context).colorScheme.onPrimary,
            disabledColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
            onPressed: isTracking ? () => context.read<TimeTrackingCubit>().discard() : null,
            icon: const Icon(Icons.delete),
          ),
        ),
      ],
    );
  }
}
