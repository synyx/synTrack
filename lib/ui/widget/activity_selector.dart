import 'package:flutter/material.dart';
import 'package:syntrack/model/common/activity.dart';

class ActivitySelector extends StatelessWidget {
  final Activity? selectedActivity;
  final List<Activity> activities;
  final Function(Activity? activity) onSelect;

  const ActivitySelector({
    Key? key,
    required this.selectedActivity,
    required this.activities,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(1000),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: DropdownButton<Activity>(
        onChanged: onSelect,
        value: selectedActivity,
        items: activities
            .map(
              (e) => DropdownMenuItem<Activity>(
                value: e,
                child: Text(e.name),
              ),
            )
            .toList(),
      ),
    );
  }
}
