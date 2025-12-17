import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project.dart';
import 'kanban_board.dart'; // Pour la section tâches
import 'project_members_screen.dart'; // Pour les membres
import 'project_settings_screen.dart'; // Pour les paramètres
import 'project_activity_screen.dart'; // Pour l'activité

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({Key? key, required this.project})
      : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _selectedIndex = 0;

  // Liste des écrans de la bottom navigation
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Initialiser les écrans
    _screens.addAll([
      _buildOverviewScreen(), // Vue d'ensemble (index 0)
      _buildTasksScreen(), // Tâches (index 1)
      _buildMembersScreen(), // Membres (index 2)
      _buildSettingsScreen(), // Paramètres (index 3)
      _buildActivityScreen(), // Activité (index 4)
    ]);
  }

  // Écran 0: Vue d'ensemble
  Widget _buildOverviewScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du projet
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.folder,
                          size: 36,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.project.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Créé le ${_formatDate(widget.project.createdAt)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.project.description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.project.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Statistiques
          const Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.people,
                value: widget.project.members.length.toString(),
                label: 'Membres',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.task,
                value: '0',
                label: 'Tâches',
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.check_circle,
                value: '0',
                label: 'Terminées',
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Actions rapides
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildQuickActionCard(
                title: 'Tableau Kanban',
                icon: Icons.dashboard,
                color: Colors.blue,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1; // Aller à l'onglet Tâches
                  });
                },
              ),
              _buildQuickActionCard(
                title: 'Inviter des membres',
                icon: Icons.person_add,
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2; // Aller à l'onglet Membres
                  });
                },
              ),
              _buildQuickActionCard(
                title: 'Paramètres',
                icon: Icons.settings,
                color: Colors.orange,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3; // Aller à l'onglet Paramètres
                  });
                },
              ),
              _buildQuickActionCard(
                title: 'Voir l\'activité',
                icon: Icons.history,
                color: Colors.purple,
                onTap: () {
                  setState(() {
                    _selectedIndex = 4; // Aller à l'onglet Activité
                  });
                },
              ),
            ],
          ),

          // Tâches récentes (exemple)
          const SizedBox(height: 32),
          const Text(
            'Tâches récentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildRecentTaskItem(
                    title: 'Configurer le projet',
                    status: 'À faire',
                    color: Colors.blue,
                  ),
                  const Divider(),
                  _buildRecentTaskItem(
                    title: 'Design de l\'interface',
                    status: 'Terminé',
                    color: Colors.green,
                  ),
                  const Divider(),
                  _buildRecentTaskItem(
                    title: 'Documentation',
                    status: 'En cours',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Écran 1: Tâches (Kanban)
  Widget _buildTasksScreen() {
    return KanbanBoardScreen(
      projectId: widget.project.id,
      projectName: widget.project.name,
    );
  }

  // Écran 2: Membres
  Widget _buildMembersScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membres du projet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: const Text('Vous'),
                    subtitle: const Text('Propriétaire'),
                    trailing: Chip(
                      label: const Text('Admin'),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ),
                  const Divider(),
                  // Liste des autres membres
                  for (int i = 0; i < widget.project.members.length; i++)
                    if (i >
                        0) // Commencer à 1 pour ne pas afficher le propriétaire deux fois
                      Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            title: Text('Membre ${i + 1}'),
                            subtitle: Text(widget.project.members[i]),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                _showMemberOptions(context, i);
                              },
                            ),
                          ),
                          if (i < widget.project.members.length - 1)
                            const Divider(),
                        ],
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _inviteMember(context);
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Inviter un membre'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  // Écran 3: Paramètres
  Widget _buildSettingsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres du projet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications par email'),
                  subtitle: const Text('Recevoir des notifications par email'),
                  value: true,
                  onChanged: (value) {},
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Membres peuvent inviter'),
                  subtitle: const Text(
                      'Autoriser les membres à inviter d\'autres personnes'),
                  value: false,
                  onChanged: (value) {},
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Archive automatique'),
                  subtitle: const Text(
                      'Archiver les tâches terminées après 30 jours'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zone dangereuse',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showDeleteDialog(context);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Supprimer le projet',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Écran 4: Activité
  Widget _buildActivityScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activité récente',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.task,
                    title: 'Tâche créée',
                    description: '"Configurer le projet" a été créée',
                    time: 'Il y a 2 heures',
                    color: Colors.blue,
                  ),
                  const Divider(),
                  _buildActivityItem(
                    icon: Icons.person_add,
                    title: 'Membre ajouté',
                    description: 'John Doe a rejoint le projet',
                    time: 'Il y a 1 jour',
                    color: Colors.green,
                  ),
                  const Divider(),
                  _buildActivityItem(
                    icon: Icons.edit,
                    title: 'Projet modifié',
                    description: 'Description du projet mise à jour',
                    time: 'Il y a 3 jours',
                    color: Colors.orange,
                  ),
                  const Divider(),
                  _buildActivityItem(
                    icon: Icons.check_circle,
                    title: 'Tâche terminée',
                    description: '"Design UI" marquée comme terminée',
                    time: 'Il y a 1 semaine',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Vue d\'ensemble',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tâches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Membres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Activité',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // Ajouter une tâche
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTaskScreen(
                      projectId: widget.project.id,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // Méthodes utilitaires
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTaskItem({
    required String title,
    required String status,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(
        status == 'Terminé' ? Icons.check_circle : Icons.circle,
        color: color,
      ),
      title: Text(title),
      subtitle: Text(status),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward),
        onPressed: () {
          setState(() {
            _selectedIndex = 1; // Aller à l'onglet Tâches
          });
        },
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }

  void _showMemberOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier le rôle'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle, color: Colors.red),
            title: const Text('Retirer du projet',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _inviteMember(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inviter un membre'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Email du membre',
            hintText: 'email@exemple.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Logique d'invitation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invitation envoyée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Inviter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text('Cette action est irréversible. Êtes-vous sûr ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retour au dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Projet supprimé'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// CLASSE CreateTaskScreen INTÉGRÉE DANS LE MÊME FICHIER
// ------------------------------------------------------------------
class CreateTaskScreen extends StatefulWidget {
  final String projectId;
  final String? initialStatus;

  const CreateTaskScreen({
    Key? key,
    required this.projectId,
    this.initialStatus,
  }) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _status = 'todo';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialStatus != null) {
      _status = widget.initialStatus!;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simuler un délai
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      // Retour à l'écran précédent
      Navigator.pop(context);

      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tâche créée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Tâche'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la tâche',
                  hintText: 'Entrez le titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description de la tâche',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              // Statut
              const Text('Statut:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('À faire'),
                    selected: _status == 'todo',
                    onSelected: (selected) {
                      setState(() {
                        _status = 'todo';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('En cours'),
                    selected: _status == 'inProgress',
                    onSelected: (selected) {
                      setState(() {
                        _status = 'inProgress';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Terminé'),
                    selected: _status == 'done',
                    onSelected: (selected) {
                      setState(() {
                        _status = 'done';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date d'échéance
              const Text('Date d\'échéance:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bouton
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _createTask,
                        child: const Text('Créer la tâche'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
