import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:project_management/features/shared/domain/entities/project.dart';
import 'package:project_management/features/shared/domain/entities/developer.dart';
import '../../domain/repositories/buyer_repository.dart';
import 'buyer_repository_provider.dart';

final buyerProvider =
    StateNotifierProvider<BuyerNotifier, AsyncValue<List<Project>>>((ref) {
      final repository = ref.read(buyerRepositoryProvider);
      return BuyerNotifier(repository);
    });

class BuyerNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final BuyerRepository repository;

  BuyerNotifier(
    this.repository, {
    bool autoLoad = true,
  }) : super(const AsyncLoading()) {
    if (autoLoad) {
      loadProjects();
    }
  }

  Future<void> loadProjects() async {
    try {
      final projects = await repository.fetchProjects();
      state = AsyncData(projects);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> createProject(String title, String description) async {
    try {
      await repository.createProject(title, description);
      await loadProjects();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<List<Developer>> fetchDevelopers() {
    return repository.fetchDevelopers();
  }

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required double rate,
    required String developerId,
  }) async {
    try {
      await repository.createTask(
        projectId: projectId,
        title: title,
        description: description,
        hourlyRate: rate,
        developerId: developerId,
      );

      await loadProjects();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
