enum ProjectStatus { draft, active, paused, completed }

class AlojaProject {
  const AlojaProject({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.status = ProjectStatus.draft,
    this.memberIds = const [],
  });

  final String id;
  final String ownerId;
  final String name;
  final String description;
  final ProjectStatus status;
  final List<String> memberIds;

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'status': status.name,
      'memberIds': memberIds,
    };
  }

  factory AlojaProject.fromMap(String id, Map<String, dynamic> map) {
    return AlojaProject(
      id: id,
      ownerId: (map['ownerId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      status: ProjectStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ProjectStatus.draft,
      ),
      memberIds: List<String>.from(map['memberIds'] ?? const []),
    );
  }
}
