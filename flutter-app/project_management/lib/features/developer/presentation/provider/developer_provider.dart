import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../buyer/domain/task_model.dart';
import '../../data/developer_repository.dart';

final developerProvider =
    StateNotifierProvider<DeveloperNotifier, AsyncValue<List<Task>>>((ref) {
      final dio = DioProvider.createDio();
      return DeveloperNotifier(DeveloperRepository(dio));
    });

class DeveloperNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final DeveloperRepository repository;

  DeveloperNotifier(this.repository) : super(const AsyncLoading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
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

      await loadTasks();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
