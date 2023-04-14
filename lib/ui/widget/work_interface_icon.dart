import 'package:flutter/material.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/common/task_search_result.dart';

class WorkInterfaceIcon extends StatelessWidget {
  final TaskSearchResult taskSearchResult;

  const WorkInterfaceIcon({
    Key? key,
    required this.taskSearchResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (taskSearchResult.origin) {
      case TaskSearchOrigin.redmine:
        return Image.asset('assets/redmine_logo.png');
      case TaskSearchOrigin.latestBookings:
        return Icon(Icons.history);
      default:
        return Container();
    }
  }
}
