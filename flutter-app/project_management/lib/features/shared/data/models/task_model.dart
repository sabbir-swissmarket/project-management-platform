import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.hourlyRate,
    required super.hoursLogged,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      hoursLogged: (json['hours_logged'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'hourly_rate': hourlyRate,
      'hours_logged': hoursLogged,
    };
  }
}
