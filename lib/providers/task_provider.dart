import 'package:flutter/foundation.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  List<Task> _todoTasks = [];
  List<Task> _inProgressTasks = [];
  List<Task> _doneTasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  List<Task> get todoTasks => _todoTasks;
  List<Task> get inProgressTasks => _inProgressTasks;
  List<Task> get doneTasks => _doneTasks;
  bool get isLoading => _isLoading;

  // Charger les tâches d'un projet
  void loadProjectTasks(String projectId) {
    _isLoading = true;
    notifyListeners();

    try {
      // Toutes les tâches
      _taskService.getProjectTasks(projectId).listen((tasks) {
        _tasks = tasks;
        _categorizeTasks(tasks);
        _isLoading = false;
        notifyListeners();
      });

      // Tâches par statut (pour Kanban)
      _taskService.getTasksByStatus(projectId, 'todo').listen((tasks) {
        _todoTasks = tasks;
        notifyListeners();
      });

      _taskService.getTasksByStatus(projectId, 'inProgress').listen((tasks) {
        _inProgressTasks = tasks;
        notifyListeners();
      });

      _taskService.getTasksByStatus(projectId, 'done').listen((tasks) {
        _doneTasks = tasks;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erreur lors du chargement des tâches: $e');
    }
  }

  // Catégoriser les tâches par statut
  void _categorizeTasks(List<Task> tasks) {
    _todoTasks = tasks.where((task) => task.status == 'todo').toList();
    _inProgressTasks =
        tasks.where((task) => task.status == 'inProgress').toList();
    _doneTasks = tasks.where((task) => task.status == 'done').toList();
  }

  // Créer une nouvelle tâche
  Future<bool> createTask({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    String assignedTo = '',
    DateTime? dueDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      Task newTask = await _taskService.createTask(
        projectId: projectId,
        title: title,
        description: description,
        createdBy: createdBy,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );

      _tasks.add(newTask);
      _categorizeTasks(_tasks);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erreur lors de la création de la tâche: $e');
      return false;
    }
  }

  // Mettre à jour le statut d'une tâche
  Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _taskService.updateTaskStatus(taskId, newStatus);

      // Mettre à jour localement
      int index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(status: newStatus);
        _categorizeTasks(_tasks);
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Erreur lors du changement de statut: $e');
      return false;
    }
  }

  // Assigner une tâche
  Future<bool> assignTask(String taskId, String userId) async {
    try {
      await _taskService.assignTask(taskId, userId);

      int index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(assignedTo: userId);
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Erreur lors de l\'assignation: $e');
      return false;
    }
  }

  // Supprimer une tâche
  Future<bool> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _taskService.deleteTask(taskId);

      _tasks.removeWhere((task) => task.id == taskId);
      _categorizeTasks(_tasks);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erreur lors de la suppression: $e');
      return false;
    }
  }

  // Effacer les données
  void clear() {
    _tasks = [];
    _todoTasks = [];
    _inProgressTasks = [];
    _doneTasks = [];
    notifyListeners();
  }
}

// Extension pour copier une tâche
extension TaskCopyWith on Task {
  Task copyWith({
    String? title,
    String? description,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
