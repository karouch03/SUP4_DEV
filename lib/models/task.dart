class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String status; // 'todo', 'inProgress', 'done'
  final String assignedTo;
  final DateTime dueDate;
  final DateTime createdAt;
  final String createdBy;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.assignedTo,
    required this.dueDate,
    required this.createdAt,
    required this.createdBy,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'todo',
      assignedTo: map['assignedTo'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status,
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
