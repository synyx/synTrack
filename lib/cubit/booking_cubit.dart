import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/exception/work_interface_not_found.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/repository/work_repository.dart';

class BookingCubit extends Cubit<List<TimeEntry>> {
  final TimeEntriesCubit timeEntriesCubit;
  final WorkRepository workRepository;

  BookingCubit(this.timeEntriesCubit, this.workRepository) : super([]);

  Future<void> bookMany(BuildContext context, List<TimeEntry> timeEntries) async {
    await Future.forEach<TimeEntry>(timeEntries, (timeEntry) async {
      try {
        await book(timeEntry);
      } catch (e) {
        // TODO: extend Cubit State with booking errors?
        // BUG: when an error occured while booking a single time entry -> the ErrorDisplay persists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Buchung fehlgeschlagen ${timeEntry.task?.name} - ${timeEntry.comment}\nFehler: ${e.toString()}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }

  Future<void> book(TimeEntry timeEntry) async {
    try {
      if (timeEntry.bookingId != null) {
        // TODO: logger warn
        return;
      }

      if (timeEntry.task == null) {
        // TODO: logger warn
        return;
      }

      state.add(timeEntry);
      emit(state);

      final bookingResult = await workRepository.book(timeEntry);
      final newTimeEntry = timeEntry.rebuild(
        (b) => b
          ..bookingId = bookingResult.bookingId
          ..end = b.start?.add(bookingResult.duration),
      );

      timeEntriesCubit.update(timeEntry.id, newTimeEntry);

      state.remove(timeEntry);
      emit(state);
    } catch (e) {
      state.remove(timeEntry);
      emit(state);
      rethrow;
    }
  }

  @override
  void emit(List<TimeEntry> state) {
    super.emit([...state]);
  }

  bool isBooking(TimeEntry timeEntry) {
    return state.contains(timeEntry);
  }

  Future<void> deleteBooking(TimeEntry timeEntry) async {
    if (timeEntry.bookingId == null) {
      throw Exception('not booked');
    }

    try {
      state.add(timeEntry);
      emit(state);

      await workRepository.deleteBooking(timeEntry);
      final newTimeEntry = timeEntry.rebuild((b) => b..bookingId = null);

      timeEntriesCubit.update(timeEntry.id, newTimeEntry);

      state.remove(timeEntry);
      emit(state);
    } on WorkInterfaceNotFound {
      state.remove(timeEntry);
      emit(state);
      rethrow;
    } catch (e) {
      debugPrint('$e');
      state.remove(timeEntry);
      emit(state);
      rethrow;
    }
  }
}
