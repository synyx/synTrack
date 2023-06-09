import 'package:flutter/material.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/work/erpnext/erpnext_config.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';

class WorkInterfaceIcon extends StatelessWidget {
  final TaskSearchOrigin? origin;
  final double borderRadius;
  final EdgeInsets padding;

  const WorkInterfaceIcon({
    Key? key,
    required this.origin,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 0,
  }) : super(key: key);

  factory WorkInterfaceIcon.fromConfig(
    dynamic workInterfaceConfig, {
    EdgeInsets padding = EdgeInsets.zero,
    double borderRadius = 0,
  }) =>
      switch (workInterfaceConfig) {
        ErpNextConfig() => WorkInterfaceIcon(
            origin: TaskSearchOrigin.erpNext,
            padding: padding,
            borderRadius: borderRadius,
          ),
        RedmineConfig() => WorkInterfaceIcon(
            origin: TaskSearchOrigin.redmine,
            padding: padding,
            borderRadius: borderRadius,
          ),
        _ => throw Exception('no work interface for $workInterfaceConfig'),
      };

  @override
  Widget build(BuildContext context) {
    if (origin == null) return Container();

    final icon = _getIcon();

    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        child: icon,
      ),
    );
  }

  Widget _getIcon() {
    switch (origin) {
      case TaskSearchOrigin.redmine:
        return Image.asset('assets/redmine_logo.png');
      case TaskSearchOrigin.erpNext:
        return Image.asset('assets/erpnext_logo.png');
      case TaskSearchOrigin.latestBookings:
        return const Icon(Icons.history);
      default:
        return Container();
    }
  }
}
