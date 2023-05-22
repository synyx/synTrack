import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:syntrack/cubit/task_search_cubit.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/ui/widget/work_interface_icon.dart';

class TaskSearchTextField extends StatefulWidget {
  const TaskSearchTextField({
    Key? key,
    this.onSuggestionSelected,
    this.onTextChange,
    this.onSubmitted,
    this.onAbort,
    this.autofocus = false,
  }) : super(key: key);

  final Function(TaskSearchResult)? onSuggestionSelected;
  final Function(String)? onTextChange;
  final Function(String)? onSubmitted;
  final Function()? onAbort;
  final bool autofocus;

  @override
  State<TaskSearchTextField> createState() => _TaskSearchTextFieldState();
}

class _TaskSearchTextFieldState extends State<TaskSearchTextField> {
  final _textController = TextEditingController();
  final _suggestionBoxController = SuggestionsBoxController();
  final _focusNode = FocusNode();
  var _completer = Completer<String>();

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event.physicalKey == PhysicalKeyboardKey.escape) {
          _suggestionBoxController.close();
          widget.onAbort?.call();
        }
      },
      child: Row(
        children: [
          Expanded(
            child: SearchAnchor.bar(
              suggestionsBuilder: (context, controller) {
                if (_completer.isCompleted) {
                  _completer = Completer();
                }

                EasyDebounce.debounce(
                  'task-search-debounce',
                  const Duration(milliseconds: 750),
                  () {
                    _completer.complete(controller.text);
                  },
                );

                return [
                  FutureBuilder<String>(
                    future: _completer.future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final query = snapshot.data;
                        if (query != null) {
                          final searchResults = <TaskSearchResult>[];

                          return StreamBuilder(
                            stream: context.read<TaskSearchCubit>().searchStream(query),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return ListTile(
                                  leading: const Icon(Icons.error),
                                  title: const Text('An unexpected Error occured!'),
                                  subtitle: Text('Error: ${snapshot.error.toString()}'),
                                  onTap: () {
                                    controller.closeView(null);
                                  },
                                );
                              }

                              if (snapshot.connectionState == ConnectionState.done && searchResults.isEmpty) {
                                if (query.trim().isEmpty) {
                                  return const ListTile(
                                    leading: Icon(Icons.search),
                                    title: Text('Start typing to search for a Task'),
                                    subtitle: Text('Hint: Try \$me or #[TicketID]'),
                                  );
                                }

                                return ListTile(
                                  leading: const Icon(Icons.play_arrow),
                                  title: Text('Start tracking "$query" and set the Task later'),
                                  subtitle: const Text('Hint: Try \$me or #[TicketID]'),
                                  onTap: () {
                                    controller.closeView(null);
                                    widget.onSubmitted?.call(query);
                                  },
                                );
                              }

                              if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
                                final data = snapshot.data!;
                                searchResults.add(data);
                              }

                              return Stack(
                                children: [
                                  if (snapshot.connectionState == ConnectionState.active) ...[
                                    const LinearProgressIndicator()
                                  ],
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: searchResults.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final suggestion = searchResults[index];
                                      return ListTile(
                                        leading: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 25,
                                            maxHeight: 25,
                                            minWidth: 25,
                                            minHeight: 25,
                                          ),
                                          child: WorkInterfaceIcon(origin: suggestion.origin),
                                        ),
                                        title: Text(suggestion.displayText),
                                        subtitle: Text('#${suggestion.task?.id ?? "<No Task>"}'),
                                        onTap: () {
                                          controller.closeView(null);
                                          widget.onSuggestionSelected?.call(suggestion);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
