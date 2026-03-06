import '../../../shared/domain/entities/task.dart';

abstract class DeveloperRepository {
  Future<List<Task>> fetchAssignedTasks();
  Future<void> submitTask({
    required String taskId,
    required double hours,
    required String filePath,
  });
  Future<void> updateStatus(String taskId, String newStatus);
}
