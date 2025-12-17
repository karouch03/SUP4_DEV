import 'package:flutter/foundation.dart';
import '../services/project_service.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  Project? _currentProject;
  bool _isLoading = false;

  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  bool get isLoading => _isLoading;

  // Charger les projets de l'utilisateur
  void loadUserProjects(String userId) {
    _isLoading = true;
    notifyListeners();

    try {
      _projectService.getUserProjects(userId).listen((projects) {
        _projects = projects;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erreur lors du chargement des projets : $e');
    }
  }

  // Créer un nouveau projet
  Future<bool> createProject({
    required String name,
    required String description,
    required String ownerId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      Project newProject = await _projectService.createProject(
        name: name,
        description: description,
        ownerId: ownerId,
      );

      _projects.add(newProject);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erreur lors de la création du projet : $e');
      return false;
    }
  }

  // Définir le projet courant
  void setCurrentProject(Project project) {
    _currentProject = project;
    notifyListeners();
  }

  // Mettre à jour un projet
  Future<bool> updateProject(Project project) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.updateProject(project);

      // Mettre à jour dans la liste locale
      int index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erreur lors de la mise à jour du projet : $e');
      return false;
    }
  }

  // Supprimer un projet - CORRIGÉ
  Future<bool> deleteProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _projectService.deleteProject(projectId);

      // Retirer de la liste locale
      _projects.removeWhere((project) => project.id == projectId);

      // Si le projet courant est celui supprimé, le réinitialiser
      if (_currentProject?.id == projectId) {
        _currentProject = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erreur lors de la suppression du projet : $e');
      return false;
    }
  }

  // Obtenir un projet par son ID
  Future<Project?> getProjectById(String projectId) async {
    try {
      return await _projectService.getProjectById(projectId);
    } catch (e) {
      print('Erreur lors de la récupération du projet : $e');
      return null;
    }
  }

  // Inviter un membre
  Future<bool> inviteMember(String projectId, String userId) async {
    try {
      await _projectService.inviteMember(projectId, userId);
      return true;
    } catch (e) {
      print('Erreur lors de l\'invitation du membre : $e');
      return false;
    }
  }

  // Retirer un membre
  Future<bool> removeMember(String projectId, String userId) async {
    try {
      await _projectService.removeMember(projectId, userId);
      return true;
    } catch (e) {
      print('Erreur lors du retrait du membre : $e');
      return false;
    }
  }

  // Réinitialiser le provider
  void clear() {
    _projects = [];
    _currentProject = null;
    notifyListeners();
  }
}
