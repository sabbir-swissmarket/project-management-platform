import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:project_management/core/network/dio_provider.dart';

import '../../data/buyer_repository.dart';
import '../../domain/task_model.dart';

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
      final dio = DioProvider.createDio();
      return TaskNotifier(BuyerRepository(dio));
    });

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final BuyerRepository repository;

  TaskNotifier(this.repository) : super(const AsyncData([]));

  Future<void> loadTasks(String projectId) async {
    try {
      state = const AsyncLoading();
      final tasks = await repository.fetchTasks(projectId);
      state = AsyncData(tasks);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refresh(String projectId) async {
    await loadTasks(projectId);
  }
}
