import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer une nouvelle tâche
  Future<Task> createTask({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    String assignedTo = '',
    DateTime? dueDate,
  }) async {
    try {
      String taskId = _firestore.collection('tasks').doc().id;

      Task newTask = Task(
        id: taskId,
        projectId: projectId,
        title: title,
        description: description,
        status: 'todo', // todo, inProgress, done
        assignedTo: assignedTo,
        dueDate: dueDate ?? DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );

      await _firestore.collection('tasks').doc(taskId).set(newTask.toMap());

      return newTask;
    } catch (e) {
      print('Erreur lors de la création de la tâche: $e');
      rethrow;
    }
  }

  // Obtenir les tâches d'un projet
  Stream<List<Task>> getProjectTasks(String projectId) {
    return _firestore
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtenir les tâches par statut
  Stream<List<Task>> getTasksByStatus(String projectId, String status) {
    return _firestore
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Mettre à jour une tâche
  Future<void> updateTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour de la tâche: $e');
      rethrow;
    }
  }

  // Changer le statut d'une tâche
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Erreur lors du changement de statut: $e');
      rethrow;
    }
  }

  // Assigner une tâche à un utilisateur
  Future<void> assignTask(String taskId, String userId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': userId,
      });
    } catch (e) {
      print('Erreur lors de l\'assignation: $e');
      rethrow;
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      rethrow;
    }
  }
}
