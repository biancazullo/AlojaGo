import '../../domain/models/project.dart';
import '../services/project_service.dart';

abstract class ProjectRepository {
  Stream<List<AlojaProject>> watchUserProjects(String userId);
  Future<AlojaProject> createProject({
    required String ownerId,
    required String name,
    required String description,
  });
  Future<void> updateProject(AlojaProject project);
  Future<void> deleteProject(String projectId);
}

class FirestoreProjectRepository implements ProjectRepository {
  FirestoreProjectRepository({ProjectService? projectService})
    : _projectService = projectService ?? FirestoreProjectService();

  final ProjectService _projectService;

  @override
  Stream<List<AlojaProject>> watchUserProjects(String userId) {
    return _projectService.watchProjectsForUser(userId);
  }

  @override
  Future<AlojaProject> createProject({
    required String ownerId,
    required String name,
    required String description,
  }) {
    final project = AlojaProject(
      id: '',
      ownerId: ownerId,
      name: name.trim(),
      description: description.trim(),
      memberIds: [ownerId],
    );
    return _projectService.createProject(project);
  }

  @override
  Future<void> updateProject(AlojaProject project) {
    return _projectService.updateProject(project);
  }

  @override
  Future<void> deleteProject(String projectId) {
    return _projectService.deleteProject(projectId);
  }
}
