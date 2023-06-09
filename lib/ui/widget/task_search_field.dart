import 'dart:async';

import 'package:async/async.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:syntrack/cubit/task_search_cubit.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/ui/widget/work_interface_icon.dart';
import 'package:syntrack/util/accumulating_stream.dart';

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
                        if (query != null && query.trim().isNotEmpty) {
                          final stream =
                              AccumulatingStream(context.read<TaskSearchCubit>().searchStream(query).listenAndBuffer());

                          return StreamBuilder(
                            stream: stream,
                            builder: (context, snapshot) {
                              final searchResults = snapshot.data;

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

                              if (searchResults == null) {
                                return const LinearProgressIndicator();
                              }

                              if (snapshot.connectionState == ConnectionState.done && searchResults.isEmpty) {
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
                                        title: Text(suggestion.displayText.isNotEmpty
                                            ? suggestion.displayText
                                            : '<NO COMMENT>'),
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
                        } else {
                          return ListTile(
                            leading: const Icon(Icons.search),
                            title: const Text('Start typing to search for a Task'),
                            subtitle: const Text('Hint: Try \$me or #[TicketID]'),
                            onTap: () {
                              controller.closeView(null);
                              widget.onSubmitted?.call('');
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
