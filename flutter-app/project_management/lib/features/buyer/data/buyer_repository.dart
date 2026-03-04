import 'package:dio/dio.dart';

import '../domain/project_model.dart';
import '../domain/task_model.dart';
import '../domain/developer_model.dart';

class BuyerRepository {
  final Dio dio;

  BuyerRepository(this.dio);

  Future<List<Project>> fetchProjects() async {
    final response = await dio.get("/projects");

    return (response.data as List).map((e) => Project.fromJson(e)).toList();
  }

  Future<List<Task>> fetchTasks(String projectId) async {
    final response = await dio.get("/projects/$projectId/tasks");

    return (response.data as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<void> createProject(String title, String description) async {
    await dio.post(
      "/projects",
      data: {"title": title, "description": description},
    );
  }

  Future<List<Developer>> fetchDevelopers() async {
    final response = await dio.get("/developers");

    return (response.data as List)
        .map((e) => Developer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required double hourlyRate,
    required String developerId,
  }) async {
    await dio.post(
      "/tasks",
      data: {
        "project_id": projectId,
        "title": title,
        "description": description,
        "hourly_rate": hourlyRate,
        "assigned_developer_id": developerId,
      },
    );
  }

  Future<void> payForTask(String taskId) async {
    await dio.post("/payments/$taskId");
  }

  Future<void> downloadSolution(String taskId) async {
    await dio.get(
      "/tasks/$taskId/download",
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
