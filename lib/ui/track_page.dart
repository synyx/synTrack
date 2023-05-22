import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:syntrack/cubit/booking_cubit.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/cubit/time_entries_filter_cubit.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';
import 'package:syntrack/exception/work_interface_not_found.dart';
import 'package:syntrack/router.gr.dart';
import 'package:syntrack/ui/widget/time_entries_filter_bar.dart';
import 'package:syntrack/ui/widget/time_entries_list.dart';
import 'package:syntrack/ui/widget/time_tracking_header.dart';

@RoutePage()
class TrackPage extends StatelessWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'synTrack',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.router.push(const SettingsRoute()),
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size(double.infinity, 110),
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: TimeTrackingHeader(),
          ),
        ),
      ),
      floatingActionButton:
          context.watch<TimeTrackingCubit>().state.start != null && SizerUtil.deviceType == DeviceType.mobile
              ? FloatingActionButton(
                  // backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () => context.read<TimeTrackingCubit>().stop(),
                  child: const Icon(Icons.stop),
                )
              : FloatingActionButton(
                  // backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Icon(Icons.bookmark),
                  onPressed: () => _bookAll(context),
                ),
      body: const TimeEntriesList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: const TimeEntriesFilterBar(),
    );
  }

  _bookAll(BuildContext context) async {
    try {
      final notBooked = context.read<TimeEntriesCubit>().state.where((element) => element.bookingId == null).toList();
      final notBookedFiltered = context.read<TimeEntriesFilterCubit>().filter(notBooked);

      await context.read<BookingCubit>().bookMany(
            context,
            notBookedFiltered.toList(),
          );
    } on WorkInterfaceNotFound {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Work Interface/s not found',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }
}
