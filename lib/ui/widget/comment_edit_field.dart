import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/time_tracking_cubit.dart';

class CommentEditField extends StatelessWidget {
  const CommentEditField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: getInitialComment(context),
      autofocus: true,
      style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: 20,
          ),
      decoration: InputDecoration(
        hintText: 'Comment',
        border: const OutlineInputBorder(),
        prefixIcon: Container(
          constraints: const BoxConstraints(maxWidth: 50, maxHeight: 50, minWidth: 50, minHeight: 50),
          child: const Icon(Icons.access_time),
        ),
        /*TODO: suffixIcon: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => null,
        ),*/
      ),
      onChanged: (value) {
        context.read<TimeTrackingCubit>().setComment(value);
      },
      toolbarOptions: const ToolbarOptions(
        copy: true,
        cut: true,
        paste: true,
        selectAll: true,
      ),
    );
  }

  String getInitialComment(BuildContext context) {
    final state = context.read<TimeTrackingCubit>().state;
    return state.comment;
  }
}
