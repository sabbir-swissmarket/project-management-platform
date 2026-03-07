import 'package:dio/dio.dart';

import '../../../shared/data/models/task_model.dart';
import '../../../shared/domain/entities/task.dart';
import '../../domain/repositories/developer_repository.dart';

class DeveloperRepositoryImpl implements DeveloperRepository {
  DeveloperRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Task>> fetchAssignedTasks() async {
    final response = await _dio.get('/tasks/my-tasks');

    return (response.data as List<dynamic>)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> submitTask({
    required String taskId,
    required double hours,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'hours_logged': hours,
      'file': await MultipartFile.fromFile(filePath),
    });

    await _dio.patch('/tasks/$taskId/submit', data: formData);
  }

  @override
  Future<void> updateStatus(String taskId, String newStatus) async {
    await _dio.patch(
      '/tasks/$taskId/status',
      queryParameters: {'new_status': newStatus},
    );
  }
}
