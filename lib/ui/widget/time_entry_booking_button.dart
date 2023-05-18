import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/booking_cubit.dart';
import 'package:syntrack/model/common/time_entry.dart';

class TimeEntryBookingButton extends StatelessWidget {
  final TimeEntry entry;
  final Function(Object? error)? onBooked;

  const TimeEntryBookingButton({
    Key? key,
    required this.entry,
    this.onBooked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isBooking(context)) {
      return IconButton.filled(
        icon: Icon(
          entry.bookingId == null ? Icons.bookmark : Icons.bookmark_added,
        ),
        onPressed: () {
          _bookOrDeleteBooking(context, entry);
        },
      );
    }

    return const CircularProgressIndicator();
  }

  void _bookOrDeleteBooking(BuildContext context, TimeEntry entry) async {
    try {
      if (entry.bookingId == null) {
        await context.read<BookingCubit>().book(entry);
      } else {
        await context.read<BookingCubit>().deleteBooking(entry);
      }
      onBooked?.call(null);
    } catch (e) {
      if (onBooked == null) {
        rethrow;
      }

      onBooked?.call(e);
/*      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Work Interface not found'),
          backgroundColor: Colors.red,
        ),
      );*/
      // TODO
      /*final config = await context.router.push(WorkInterfaceSelectorRoute());
      if (config is RedmineConfig) {
        final updatedEntry = entry.rebuild((b) => b..task.workInterfaceId = config.id);
        context.read<TimeEntriesCubit>().update(
              entry.id,
              updatedEntry,
            );

        _bookOrDeleteBooking(context, updatedEntry);
      }*/
    }
  }

  bool isBooking(BuildContext context) => context.watch<BookingCubit>().isBooking(entry);
}
