import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/project.dart';

abstract class ProjectService {
  Stream<List<AlojaProject>> watchProjectsForUser(String userId);
  Future<AlojaProject> createProject(AlojaProject project);
  Future<void> updateProject(AlojaProject project);
  Future<void> deleteProject(String projectId);
}

class FirestoreProjectService implements ProjectService {
  FirestoreProjectService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection('projects');

  @override
  Stream<List<AlojaProject>> watchProjectsForUser(String userId) {
    return _projects
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AlojaProject.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<AlojaProject> createProject(AlojaProject project) async {
    final doc = await _projects.add(project.toMap());
    return AlojaProject(
      id: doc.id,
      ownerId: project.ownerId,
      name: project.name,
      description: project.description,
      status: project.status,
      memberIds: project.memberIds,
    );
  }

  @override
  Future<void> updateProject(AlojaProject project) {
    return _projects.doc(project.id).update(project.toMap());
  }

  @override
  Future<void> deleteProject(String projectId) {
    return _projects.doc(projectId).delete();
  }
}
