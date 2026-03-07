import '../../../shared/domain/entities/developer.dart';
import '../../../shared/domain/entities/project.dart';
import '../../../shared/domain/entities/task.dart';

abstract class BuyerRepository {
  Future<List<Project>> fetchProjects();
  Future<List<Task>> fetchTasks(String projectId);
  Future<void> createProject(String title, String description);
  Future<List<Developer>> fetchDevelopers();
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required double hourlyRate,
    required String developerId,
  });
  Future<void> payForTask(String taskId);
  Future<String> downloadSolution(String taskId);
}
