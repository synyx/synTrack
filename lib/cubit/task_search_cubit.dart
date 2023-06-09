import 'dart:async';


import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_debounce_it/just_debounce_it.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/repository/work_repository.dart';

part 'task_search_state.dart';

class TaskSearchCubit extends Cubit<TaskSearchState> {
  final WorkRepository workRepository;
  String _prevQuery = '';

  TaskSearchCubit(this.workRepository) : super(const Done([]));

  Future<void> searchWithDebounce(String query) async {
    if (query == _prevQuery) {
      return;
    }

    _prevQuery = query;

    emit(const Searching([]));
    Debounce.milliseconds(1000, search, [query]);
  }

  Future<Done> search(String query) async {
    emit(const Searching([]));

    final searchStream = workRepository.search(query);
    await searchStream.forEach((element) {
      emit(Searching([...state.results, element]));
    });

    final done = Done(state.results);
    emit(done);
    return done;
  }

  Stream<TaskSearchResult> searchStream(String query) async* {
    emit(const Searching([]));

    await for (final searchResult in workRepository.search(query)) {
      emit(Searching([...state.results, searchResult]));
      yield searchResult;
    }

    final done = Done(state.results);
    emit(done);
  }
}
