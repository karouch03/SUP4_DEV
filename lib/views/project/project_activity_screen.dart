import 'package:flutter/material.dart';

class ProjectActivityScreen extends StatelessWidget {
  final String projectId;

  const ProjectActivityScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activité')),
      body: const Center(child: Text('Historique d\'activité')),
    );
  }
}
