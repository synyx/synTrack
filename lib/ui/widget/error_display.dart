import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    Key? key,
    required this.errorMessage,
    this.dense = false,
  }) : super(key: key);

  final String? errorMessage;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: errorMessage,
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        if (!dense) ...[
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              'Fehler: $errorMessage',
              softWrap: true,
            ),
          ),
        ],
      ],
    );
  }
}
