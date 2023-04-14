import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntrack/cubit/task_search_cubit.dart';

class SearchIcon extends StatelessWidget {
  const SearchIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 50, maxHeight: 50, minWidth: 50, minHeight: 50),
      child: Stack(
        children: [
          Positioned.fill(child: Icon(Icons.search)),
          if (context.watch<TaskSearchCubit>().state is Searching)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
