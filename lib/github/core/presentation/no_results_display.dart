import 'package:flutter/material.dart';

class NoResultsDisplay extends StatelessWidget {
  final String message;
  const NoResultsDisplay({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}
