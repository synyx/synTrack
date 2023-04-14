part of 'task_search_cubit.dart';

@immutable
abstract class TaskSearchState extends Equatable {
  final List<TaskSearchResult> results;

  TaskSearchState(this.results);

  @override
  List<Object?> get props => [results];
}

class Searching extends TaskSearchState {
  Searching(List<TaskSearchResult> results) : super(results);
}

class Done extends TaskSearchState {
  Done(List<TaskSearchResult> results) : super(results);
}
