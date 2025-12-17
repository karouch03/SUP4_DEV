import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import 'create_task_screen.dart';

class KanbanBoardScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const KanbanBoardScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadProjectTasks(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau Kanban - ${widget.projectName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTaskScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne "À faire"
                _buildColumn(
                  title: 'À faire',
                  tasks: taskProvider.todoTasks,
                  color: Colors.blue.shade50,
                  status: 'todo',
                  icon: Icons.circle,
                  iconColor: Colors.blue,
                ),

                // Colonne "En cours"
                _buildColumn(
                  title: 'En cours',
                  tasks: taskProvider.inProgressTasks,
                  color: Colors.orange.shade50,
                  status: 'inProgress',
                  icon: Icons.circle,
                  iconColor: Colors.orange,
                ),

                // Colonne "Terminé"
                _buildColumn(
                  title: 'Terminé',
                  tasks: taskProvider.doneTasks,
                  color: Colors.green.shade50,
                  status: 'done',
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTaskScreen(
                projectId: widget.projectId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColumn({
    required String title,
    required List<Task> tasks,
    required Color color,
    required String status,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de colonne
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${tasks.length}'),
                      backgroundColor: iconColor.withOpacity(0.2),
                    ),
                  ],
                ),
              ),

              // Liste des tâches
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Aucune tâche',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildTaskCard(task, status);
                        },
                      ),
              ),

              // Bouton "Ajouter une tâche"
              if (status == 'todo')
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTaskScreen(
                            projectId: widget.projectId,
                            initialStatus: status,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter une tâche'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, String columnStatus) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Édition de tâche (à implémenter plus tard)
          _showTaskDetails(task);
        },
        onLongPress: () {
          // Changement de statut par drag & drop (simplifié pour l'instant)
          _showStatusMenu(task);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleTaskAction(task, value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],

              const SizedBox(height: 12),

              // Informations supplémentaires
              Row(
                children: [
                  // Date d'échéance
                  if (task.dueDate.isAfter(
                      DateTime.now().subtract(const Duration(days: 1))))
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'J-${task.dueDate.difference(DateTime.now()).inDays}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),

                  // Assigné à
                  if (task.assignedTo.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Assigné',
                        style: TextStyle(
                            fontSize: 10, color: Colors.blue.shade700),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.description.isNotEmpty) ...[
                const Text('Description:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 16),
              ],
              const Text('Informations:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailRow(
                  'Statut',
                  task.status == 'todo'
                      ? 'À faire'
                      : task.status == 'inProgress'
                          ? 'En cours'
                          : 'Terminé'),
              _buildDetailRow('Date d\'échéance',
                  '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}'),
              _buildDetailRow('Créée le',
                  '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label :',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showStatusMenu(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.circle, color: Colors.blue),
            title: const Text('Déplacer vers "À faire"'),
            onTap: () {
              Navigator.pop(context);
              _updateTaskStatus(task, 'todo');
            },
          ),
          ListTile(
            leading: const Icon(Icons.circle, color: Colors.orange),
            title: const Text('Déplacer vers "En cours"'),
            onTap: () {
              Navigator.pop(context);
              _updateTaskStatus(task, 'inProgress');
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Déplacer vers "Terminé"'),
            onTap: () {
              Navigator.pop(context);
              _updateTaskStatus(task, 'done');
            },
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(Task task, String newStatus) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.updateTaskStatus(task.id, newStatus);
  }

  void _handleTaskAction(Task task, String action) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    switch (action) {
      case 'edit':
        // À implémenter plus tard
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer la tâche'),
            content:
                const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  taskProvider.deleteTask(task.id);
                  Navigator.pop(context);
                },
                child: const Text('Supprimer',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        break;
    }
  }
}
