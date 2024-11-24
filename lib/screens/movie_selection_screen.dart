import 'package:flutter/material.dart';

class MovieSelectionScreen extends StatelessWidget {
  final String sessionId;

  const MovieSelectionScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Selection',
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
            )),
        backgroundColor: const Color.fromARGB(84, 0, 0, 0),
      ),
      body: Center(
        child: Text('Session ID: $sessionId'),
      ),
    );
  }
}
