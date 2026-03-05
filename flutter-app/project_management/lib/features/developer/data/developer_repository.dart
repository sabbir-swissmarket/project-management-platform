import 'package:dio/dio.dart';

import '../../buyer/domain/task_model.dart';

class DeveloperRepository {
  final Dio dio;

  DeveloperRepository(this.dio);

  Future<List<Task>> fetchAssignedTasks() async {
    final response = await dio.get("/tasks/my-tasks");

    return (response.data as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<void> updateStatus(String taskId, String newStatus) async {
    await dio.patch(
      "/tasks/$taskId/status",
      queryParameters: {"new_status": newStatus},
    );
  }

  Future<void> submitTask({
    required String taskId,
    required double hours,
    required String filePath,
  }) async {
    FormData formData = FormData.fromMap({
      "hours_logged": hours,
      "file": await MultipartFile.fromFile(filePath),
    });

    await dio.patch("/tasks/$taskId/submit", data: formData);
  }
}
