import 'package:flutter/material.dart';

class ProjectMembersScreen extends StatelessWidget {
  final String projectId;

  const ProjectMembersScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membres')),
      body: const Center(child: Text('Gestion des membres')),
    );
  }
}
