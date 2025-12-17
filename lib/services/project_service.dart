import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer un nouveau projet
  Future<Project> createProject({
    required String name,
    required String description,
    required String ownerId,
  }) async {
    try {
      // Créer un identifiant unique pour le projet
      String projectId = _firestore.collection('projects').doc().id;

      Project newProject = Project(
        id: projectId,
        name: name,
        description: description,
        ownerId: ownerId,
        members: [ownerId], // Le propriétaire est membre automatiquement
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('projects')
          .doc(projectId)
          .set(newProject.toMap());

      return newProject;
    } catch (e) {
      print('Erreur lors de la création du projet : $e');
      rethrow;
    }
  }

  // Obtenir les projets de l'utilisateur
  Stream<List<Project>> getUserProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Obtenir un projet par ID
  Future<Project?> getProjectById(String projectId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('projects').doc(projectId).get();

      if (doc.exists) {
        return Project.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du projet : $e');
      return null;
    }
  }

  // Mettre à jour un projet
  Future<void> updateProject(Project project) async {
    try {
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(project.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour du projet : $e');
      rethrow;
    }
  }

  // Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du projet : $e');
      rethrow;
    }
  }

  // Inviter un membre au projet
  Future<void> inviteMember(String projectId, String userId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'members': FieldValue.arrayUnion([userId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de l’invitation du membre : $e');
      rethrow;
    }
  }

  // Retirer un membre du projet
  Future<void> removeMember(String projectId, String userId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'members': FieldValue.arrayRemove([userId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de la suppression du membre : $e');
      rethrow;
    }
  }

  // Rechercher des projets par nom
  Stream<List<Project>> searchProjects(String query, String userId) {
    return _firestore
        .collection('projects')
        .where('members', arrayContains: userId)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
