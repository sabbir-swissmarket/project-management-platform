import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:project_management/features/shared/domain/entities/task.dart';

import '../../domain/repositories/buyer_repository.dart';
import 'buyer_repository_provider.dart';

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
      final repository = ref.read(buyerRepositoryProvider);
      return TaskNotifier(repository);
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
