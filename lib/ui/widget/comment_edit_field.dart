import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';

class CommentEditField extends StatefulWidget {
  const CommentEditField({Key? key}) : super(key: key);

  @override
  State<CommentEditField> createState() => _CommentEditFieldState();
}

class _CommentEditFieldState extends State<CommentEditField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _controller.text = getInitialComment(context);
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Comment',
      focusNode: _focusNode,
      controller: _controller,
      trailing: [
        IconButton(
          onPressed: () {
            _controller.clear();
            context.read<TimeTrackingCubit>().setComment('');
          },
          icon: const Icon(
            Icons.close,
          ),
        ),
      ],
      onChanged: (value) {
        context.read<TimeTrackingCubit>().setComment(value);
      },
    );
  }

  String getInitialComment(BuildContext context) {
    final state = context.read<TimeTrackingCubit>().state;
    return state.comment;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
