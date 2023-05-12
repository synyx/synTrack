import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:syntrack/cubit/booking_cubit.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';
import 'package:syntrack/exception/work_interface_not_found.dart';
import 'package:syntrack/router.gr.dart';
import 'package:syntrack/ui/widget/time_entries_list.dart';
import 'package:syntrack/ui/widget/time_tracking_header.dart';

@RoutePage()
class TrackPage extends StatelessWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('synTrack'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 120),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: TimeTrackingHeader(),
          ),
        ),
      ),
      floatingActionButton:
          context.watch<TimeTrackingCubit>().state.start != null && SizerUtil.deviceType == DeviceType.mobile
              ? FloatingActionButton(
                  child: const Icon(Icons.stop),
                  backgroundColor: Colors.red,
                  onPressed: () => context.read<TimeTrackingCubit>().stop(),
                )
              : FloatingActionButton(
                  child: const Icon(Icons.book),
                  onPressed: () => _bookAll(context),
                ),
      body: const TimeEntriesList(),
    );
  }

  _bookAll(BuildContext context) async {
    try {
      final notBooked = context.read<TimeEntriesCubit>().state.where((element) => element.bookingId == null).toList();
      await context.read<BookingCubit>().bookMany(
            context,
            notBooked,
          );
    } on WorkInterfaceNotFound {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work Interface/s not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
