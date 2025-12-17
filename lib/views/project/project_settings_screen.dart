import 'package:flutter/material.dart';

class ProjectSettingsScreen extends StatelessWidget {
  final String projectId;

  const ProjectSettingsScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: const Center(child: Text('Paramètres du projet')),
    );
  }
}
