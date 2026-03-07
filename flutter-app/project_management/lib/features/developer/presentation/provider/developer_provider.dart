import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_provider.dart';
import 'package:project_management/features/shared/domain/entities/task.dart';
import '../../data/repositories/developer_repository_impl.dart';
import '../../domain/repositories/developer_repository.dart';

final developerProvider =
    StateNotifierProvider<DeveloperNotifier, AsyncValue<List<Task>>>((ref) {
      final dio = DioProvider.createDio();
      return DeveloperNotifier(DeveloperRepositoryImpl(dio));
    });

class DeveloperNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final DeveloperRepository repository;

  DeveloperNotifier(
    this.repository, {
    bool autoLoad = true,
  }) : super(const AsyncLoading()) {
    if (autoLoad) {
      loadTasks();
    }
  }

  Future<void> loadTasks({bool showLoading = true}) async {
    try {
      if (showLoading) {
        state = const AsyncLoading();
      }

      final tasks = await repository.fetchAssignedTasks();
      state = AsyncData(tasks);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> submitTask({
    required String taskId,
    required double hours,
    required String filePath,
  }) async {
    try {
      state = const AsyncLoading();

      await repository.submitTask(
        taskId: taskId,
        hours: hours,
        filePath: filePath,
      );

      await loadTasks(showLoading: false);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String newStatus,
  }) async {
    await repository.updateStatus(taskId, newStatus);
    await loadTasks(showLoading: false);
  }
}
