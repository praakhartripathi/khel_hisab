import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Khel Hisab'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khel Hisab',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Version: v0.1.0-beta',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Khel Hisab is a simple volleyball scorecard app designed for village and local matches. It helps players keep score easily without pen and paper. This is a beta version created for testing and feedback.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Developer: Prakhar Tripathi',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Built using Flutter',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Open Source License: MIT License',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
