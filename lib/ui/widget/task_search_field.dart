import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:syntrack/cubit/task_search_cubit.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/ui/widget/search_icon.dart';
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

  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _commentSub?.cancel().catchError((e) => print(e));
    _commentSub = context.watch<TimeTrackingCubit>().stream.listen((event) {
      if (event.comment.trim().isEmpty) {
        setState(() {
          _textController.text = '';
        });
      }
    });
  }*/

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
            child: TypeAheadField<TaskSearchResult>(
              suggestionsBoxController: _suggestionBoxController,
              debounceDuration: const Duration(milliseconds: 750),
              minCharsForSuggestions: 2,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _textController,
                autofocus: widget.autofocus,
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                    ),
                decoration: const InputDecoration(
                  prefixIcon: SearchIcon(),
                  border: OutlineInputBorder(),
                ),
                onChanged: widget.onTextChange,
                onSubmitted: (value) {
                  _suggestionBoxController.close();
                  widget.onSubmitted?.call(value);
                },
              ),
              noItemsFoundBuilder: (context) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No Tasks found! Try \$me or #[TicketID]',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                );
              },
              suggestionsStreamCallback: (pattern) async* {
                yield* context.read<TaskSearchCubit>().searchStream(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 25, maxHeight: 25, minWidth: 25, minHeight: 25),
                    child: WorkInterfaceIcon(origin: suggestion.origin),
                  ),
                  title: Text(suggestion.displayText),
                  subtitle: Text('#${suggestion.task.id}'),
                );
              },
              onSuggestionSelected: (suggestion) {
                widget.onSuggestionSelected?.call(suggestion);
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
