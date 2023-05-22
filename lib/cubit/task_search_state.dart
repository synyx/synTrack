part of 'task_search_cubit.dart';

@immutable
abstract class TaskSearchState extends Equatable {
  final List<TaskSearchResult> results;

  const TaskSearchState(this.results);

  @override
  List<Object?> get props => [results];
}

class Searching extends TaskSearchState {
  const Searching(List<TaskSearchResult> results) : super(results);
}

class Done extends TaskSearchState {
  const Done(List<TaskSearchResult> results) : super(results);
}
